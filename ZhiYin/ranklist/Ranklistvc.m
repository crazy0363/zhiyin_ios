//
//  Ranklistvc.m
//  ZhiYin
//
//  Created by pro on 2018/10/9.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "Ranklistvc.h"
#import <AFHTTPSessionManager+Synchronous.h>
#import "zyprotocol.h"
#import "MJRefresh.h"
#import "RanklistCell.h"
#import "globalvar.h"
#import "commom_utils.h"
#import <MagicalRecord/MagicalRecord.h>
#import "SupportM+CoreDataClass.h"
#import "Tianyavc.h"
#import "complaintvc.h"
#import "BlacklistM+CoreDataClass.h"

@interface Ranklistvc ()
{
    dispatch_source_t _speak_timer;
    BOOL _supportdirty;
}
@property(nonatomic, strong)NSArray* audiolist;
@property(nonatomic, strong)AVPlayer* avplayer;
@property(nonatomic, assign)NSInteger curplayingitem;
@property(nonatomic, assign)NSInteger speak_img_index;
@property(nonatomic, strong)NSIndexPath* lastselectindexpath;
@end

@implementation Ranklistvc

-(void)request_ranklist_audio {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    NSString* url = [zyprotocol_ranklist_audio ranklist_url];
    NSDictionary* param = [zyprotocol_ranklist_audio ranklist_param:20 Period:25];
    NSError *error = nil;
    NSDictionary *result = [manager syncPOST:url
                                  parameters:param
                                        task:NULL
                                       error:&error];
    protocol_ranklist_audio_info* ranklist_audio = [zyprotocol_ranklist_audio token_response:result];
    BOOL ret = NO;
    if (ranklist_audio.IsSuccess) {
        NSLog(@"request ranklist_audio successful");
        self.audiolist = ranklist_audio.audio_info_list;
        ret = YES;
    }
    else {
        NSLog(@"request ranklist_audio error");
        self.audiolist = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self showEmptyViewWithText:@"未能加载到数据" detailText:@"请保持网络畅通，点击下方按钮重新加载" buttonTitle:@"重新加载" buttonAction:@selector(loadtianya:)];
        });
    }
    
    // blacklist
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray* items = [BlacklistM MR_findAllInContext:localContext];
        NSMutableArray* blackitems = [NSMutableArray arrayWithCapacity:30];
        for (NSInteger i = 0; i < (NSInteger)[items count]; i ++) {
            blackiteminfo* info = [[blackiteminfo alloc]init];
            BlacklistM* item = (BlacklistM*)items[i];
            info.userid = item.userid;
            info.nickname = item.nickname;
            [blackitems addObject:info];
        }
        if ([blackitems count] > 0) {
            BOOL change = NO;
            NSMutableArray* arr = [NSMutableArray arrayWithArray:self.audiolist];
            for (NSInteger i = 0; i < (NSInteger)[self.audiolist count]; i ++) {
                protocol_audio_info* ainfo = self.audiolist[i];
                BOOL got = NO;
                for (NSInteger j = 0; j < (NSInteger)[blackitems count]; j ++) {
                    blackiteminfo* it = blackitems[j];
                    if ([ainfo.clientid isEqualToString:it.userid]) {
                        got = YES;
                        break;
                    }
                }
                if (got) {
                    [arr removeObject:ainfo];
                    change = YES;
                }
            }
            if (change) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.audiolist = [NSArray arrayWithArray:arr];
                    [self.ranklisttv reloadData];
                });
            }
        }
    } completion:^(BOOL success, NSError *error) {
        NSLog(@"magicalrecord find: %d, err:%@", success, error);
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ret == YES) {
            // 是否有语音被点赞
            for (int i = 0; i < [self.audiolist count]; i++) {
                protocol_audio_info* ainfo = self.audiolist[i];
                SupportM* item = [SupportM MR_findFirstByAttribute:@"audioid" withValue:ainfo.audioid];
                if (item) {
                    ainfo.pre_support_type = ainfo.now_support_type = 1;
                }
            }
            [self hideEmptyView];
        }
        [self.ranklisttv reloadData];
        [self.ranklisttv.mj_header endRefreshing];
        [self.ranklisttv.mj_footer endRefreshing];
        self.lastselectindexpath = nil;
    });
}

-(void)request_playcount:(NSString*)audioid {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    NSString* url = [zyprotocol_sendplay sendplay_url];
    NSDictionary* param = [zyprotocol_sendplay sendplay_param:audioid];
    NSError *error = nil;
    NSDictionary *result = [manager syncPOST:url
                                  parameters:param
                                        task:NULL
                                       error:&error];
    protocol_sendplay_info* retinfo = [zyprotocol_sendplay token_response:result];
    BOOL ret = NO;
    if (retinfo.IsSuccess) {
        NSLog(@"request sendplay successful");
        ret = YES;
    }
    else {
        NSLog(@"request sendplay error");
    }
}

-(void)loadtianya:(id)btn {
    [self showEmptyViewWithLoading:YES image:nil text:@"人气榜正在加载的路上..." detailText:nil buttonTitle:nil buttonAction:nil];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self request_ranklist_audio];
    });
}

// call must NOT on main thread
- (void)refresh_support {
    if (_supportdirty) {
        NSMutableArray* support_yes = [NSMutableArray arrayWithCapacity:30];
        NSMutableArray* support_no = [NSMutableArray arrayWithCapacity:30];
        for (int i=0; i<[self.audiolist count]; i++) {
            protocol_audio_info* ainfo = self.audiolist[i];
            if (ainfo.now_support_type != ainfo.pre_support_type) {
                if (ainfo.now_support_type == 1) {
                    [support_yes addObject:ainfo.audioid];
                }
                else if (ainfo.now_support_type == 0) {
                    [support_no addObject:ainfo.audioid];
                }
            }
        }
        if ([support_yes count] > 0) {
            // 网络请求
            [self request_support:support_yes];
            // 数据库添加
            for (int i=0; i<[support_yes count]; i++) {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                    NSString* audioid = support_yes[i];
                    SupportM* item = [SupportM MR_createEntityInContext:localContext];
                    item.audioid = audioid;
                    [localContext MR_saveToPersistentStoreAndWait];
                } completion:^(BOOL success, NSError *error) {
                    NSLog(@"magicalrecord add: %d, err:%@", success, error);
                }];
            }
        }
        if ([support_no count] > 0) {
            // 网络请求
            [self request_diss_support:support_no];
            // 数据库删除
            for (int i=0; i<[support_no count]; i++) {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                    NSString* audioid = support_no[i];
                    SupportM* item = [SupportM MR_findFirstByAttribute:@"audioid" withValue:audioid inContext:localContext];
                    if (item) {
                        [item MR_deleteEntityInContext:localContext];
                        [localContext MR_saveToPersistentStoreAndWait];
                    }
                } completion:^(BOOL success, NSError *error) {
                    NSLog(@"magicalrecord delete: %d, err:%@", success, error);
                }];
                
            }
        }
        [globalvar shareglobalvar].ranklist_support_dirty = _supportdirty;
        _supportdirty = NO;
    }
}

-(void)request_support:(NSArray*)audioids {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    NSString* url = [zyprotocol_audio_support support_url];
    NSDictionary* param = [zyprotocol_audio_support support_param:audioids];
    NSError *error = nil;
    NSDictionary *result = [manager syncPOST:url
                                  parameters:param
                                        task:NULL
                                       error:&error];
    protocol_audio_support_info* retinfo = [zyprotocol_audio_support token_response:result];
    BOOL ret = NO;
    if (retinfo.IsSuccess) {
        NSLog(@"request audio_support successful");
        ret = YES;
    }
    else {
        NSLog(@"request audio_support error");
    }
}

-(void)request_diss_support:(NSArray*)audioids {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    NSString* url = [zyprotocol_audio_diss_support diss_support_url];
    NSDictionary* param = [zyprotocol_audio_diss_support diss_support_param:audioids];
    NSError *error = nil;
    NSDictionary *result = [manager syncPOST:url
                                  parameters:param
                                        task:NULL
                                       error:&error];
    protocol_audio_diss_support_info* retinfo = [zyprotocol_audio_diss_support token_response:result];
    BOOL ret = NO;
    if (retinfo.IsSuccess) {
        NSLog(@"request audio_diss_support successful");
        ret = YES;
    }
    else {
        NSLog(@"request audio_diss_support error");
    }
}

- (void)settableview {
    MJRefreshNormalHeader* header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        NSLog(@"refresh ranklist audio");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self refresh_support];
            [self request_ranklist_audio];
        });
    }];
    header.automaticallyChangeAlpha = YES;
    [header setTitle:@"请再用力拉一下" forState:MJRefreshStateIdle];
    [header setTitle:@"松手就刷新数据" forState:MJRefreshStatePulling];
    [header setTitle:@"人气榜语音正在路上..." forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.ranklisttv.mj_header = header;
    
    MJRefreshBackNormalFooter* footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        NSLog(@"refresh ranklist audio, at footer");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self request_ranklist_audio];
        });
    }];
    footer.automaticallyChangeAlpha = YES;
    [footer setTitle:@"请再用力拉一下" forState:MJRefreshStateIdle];
    [footer setTitle:@"松手就刷新数据" forState:MJRefreshStatePulling];
    [footer setTitle:@"人气榜语音正在路上..." forState:MJRefreshStateRefreshing];
    self.ranklisttv.mj_footer = footer;
    
    self.ranklisttv.delegate = self;
    self.ranklisttv.dataSource = self;
    
    // 没有数据的cell隐藏分隔线
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.ranklisttv.tableFooterView = view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.audiolist count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 50;
    UIImage* image = [UIImage imageNamed:@"respose"]; // 48*48
    if (image) {
        UIImageView* view = [[UIImageView alloc]initWithImage:image];
        height = view.qmui_width * 3.5;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        RanklistCell* cell = [RanklistCell cellwithTableview:tableView];
        protocol_audio_info* audioinfo = self.audiolist[indexPath.row];
        cell.nickname.text = audioinfo.nickname;
        cell.duration.text = [NSString stringWithFormat:@"%d\"", (int)audioinfo.audioduration];
        cell.time.text = [commom_utils howlonginfo:audioinfo.createtime];
        [cell.play setImage:[UIImage imageNamed:@"tianya_speak0"]];
        if (audioinfo.now_support_type == 1) {
            [cell.supportbtn setImage:[UIImage imageNamed:@"support_yes"] forState:UIControlStateNormal];
        }
        else {
            [cell.supportbtn setImage:[UIImage imageNamed:@"support_no"] forState:UIControlStateNormal];
        }
        [cell.supportbtn addTarget:self action:@selector(supportaction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.isaybtn setImage:[UIImage imageNamed:@"respose"] forState:UIControlStateNormal];
        [cell.isaybtn addTarget:self action:@selector(isayaction:) forControlEvents:UIControlEventTouchUpInside];
        NSString* scount = [NSString stringWithFormat:@"%d票", (int)audioinfo.supportcount];
        cell.supportcount.text = scount;
        cell.supportcount.transform =CGAffineTransformMakeRotation(M_PI*(-25.0/180));
        [cell.complain_audio setImage:[UIImage imageNamed:@"tianya_complaint_audio"] forState:UIControlStateNormal];
        [cell.complain_audio addTarget:self action:@selector(complain_action:) forControlEvents:UIControlEventTouchUpInside];
        cell.playcount.text = [NSString stringWithFormat:@"%d次播放", (int)audioinfo.playcount];
        
        return cell;
    }
    return nil;
}

-(void)complain_action:(UIButton*)complainbtn {
    NSIndexPath* ip =  [self.ranklisttv qmui_indexPathForRowAtView:complainbtn];
    if (ip) {
        protocol_audio_info* audioinfo = self.audiolist[ip.row];
        if ([audioinfo.clientid isEqualToString:[globalvar shareglobalvar].clientID]) {
            [QMUITips showInfo:@"请不要投诉自己，对自己好一点，不要发布不良内容就可以了。" inView:self.view hideAfterDelay:3];
            return;
        }
        complaintvc* cvc = [[UIStoryboard storyboardWithName:@"complaint" bundle:nil]instantiateViewControllerWithIdentifier:@"complaint"];
        [cvc complaint_who:audioinfo.clientid nickname:audioinfo.nickname audioid:audioinfo.audioid onvcindex:TAB_INDEX_RANK];
        [[globalvar shareglobalvar].tabbarcontroller changevc_overrank:cvc title:@"寡人怒了"];
    }
}

-(void)supportaction:(UIButton*)supportbtn {
    NSIndexPath* ip =  [self.ranklisttv qmui_indexPathForRowAtView:supportbtn];
    if (ip) {
        protocol_audio_info* audioinfo = self.audiolist[ip.row];
        NSInteger t = audioinfo.now_support_type;
        audioinfo.now_support_type = t ^ 1;
        if (audioinfo.now_support_type == 1) {
            audioinfo.supportcount ++;
        }
        else {
            audioinfo.supportcount --;
        }
        [self.ranklisttv reloadRowsAtIndexPaths:[NSArray arrayWithObjects:ip, nil] withRowAnimation:UITableViewRowAnimationNone];
        _supportdirty = YES;
    }
}

-(void)isayaction:(UIButton*)isaybtn {
    NSLog(@"isaybtn clicked");
    NSIndexPath* ip =  [self.ranklisttv qmui_indexPathForRowAtView:isaybtn];
    if (ip) {
        protocol_audio_info* audioinfo = self.audiolist[ip.row];
        if ([audioinfo.clientid isEqualToString:[globalvar shareglobalvar].clientID]) {
            [QMUITips showInfo:@"请选择有共鸣的语音来回复，但请不要自言自语（回复自己）。" inView:self.view hideAfterDelay:3];
            return;
        }
        [globalvar shareglobalvar].towhere = TO_WHERE_SOMEONE;
        [globalvar shareglobalvar].toclientid = audioinfo.clientid;
        [globalvar shareglobalvar].tonickname = audioinfo.nickname;
        UITabBarController* rootvc = (UITabBarController*)[UIApplication sharedApplication].delegate.window.rootViewController;
        rootvc.selectedIndex = 1;
        [globalvar shareglobalvar].current_tab = 1;
    }
}

- (void)reset_lastaudioimage {
    NSIndexPath* selindexpath = self.lastselectindexpath;
    if (selindexpath) {
        RanklistCell* cell = (RanklistCell*)[self.ranklisttv cellForRowAtIndexPath:selindexpath];
        UIImage* image = [UIImage imageNamed:@"tianya_speak0"];
        [cell.play setImage:image];
    }
}

- (void)setcurplayitem:(NSInteger)index {
    _curplayingitem = index;
}

-(void)setspeakimage {
    if (self.speak_img_index >= 4) {
        self.speak_img_index = 1;
    }
    NSIndexPath* selindexpath = self.ranklisttv.indexPathForSelectedRow;
    if (selindexpath) {
        RanklistCell* cell = (RanklistCell*)[self.ranklisttv cellForRowAtIndexPath:selindexpath];
        NSString* imagename = [NSString stringWithFormat:@"tianya_speak%d", (int)self.speak_img_index];
        UIImage* image = [UIImage imageNamed:imagename];
        [cell.play setImage:image];
        self.speak_img_index ++;
    }
}

-(void)disposespeaktimer {
    if (_speak_timer) {
        dispatch_source_cancel(_speak_timer);
        _speak_timer = NULL;
    }
}

- (void)initPlaySession
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _curplayingitem) {
        [self.avplayer pause];
        [self disposespeaktimer];
        [self reset_lastaudioimage];
        [self setcurplayitem:-1];
    }
    else {
        protocol_audio_info* audioinfo = self.audiolist[indexPath.row];
        if (audioinfo.audiourl) {
            [self reset_lastaudioimage];
            NSURL* url = [NSURL URLWithString:audioinfo.audiourl];
            [self initPlaySession];
            self.avplayer = [[AVPlayer alloc]initWithURL:url];
            [self.avplayer play];
            [self setcurplayitem:indexPath.row];
            
            [self disposespeaktimer];
            _speak_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
            dispatch_source_set_timer(_speak_timer, DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
            __weak __typeof(self) weakSelf = self;
            self.speak_img_index = 1;
            dispatch_source_set_event_handler(_speak_timer, ^{
                __strong __typeof(weakSelf) _self = weakSelf;
                [_self setspeakimage];
            });
            dispatch_resume(_speak_timer);
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self request_playcount:audioinfo.audioid];
            });
        }
    }
    self.lastselectindexpath = indexPath;
}

- (void)playbackFinished:(NSNotification *)notice {
    NSLog(@"播放完成");
    [self disposespeaktimer];
    [self reset_lastaudioimage];
    [self setcurplayitem:-1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showEmptyViewWithLoading:YES image:nil text:@"人气榜正在加载的路上..." detailText:nil buttonTitle:nil buttonAction:nil];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self request_ranklist_audio];
    });
    [self settableview];
    [self setcurplayitem:-1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    NSString* normaltip = @"最受欢迎的声音是什么样的？（下拉刷新）";
    NSString* notreachtip = @"网络连接不通";
    AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    BOOL rea = afNetworkReachabilityManager.reachable;
    if (rea) {
        self.tiplabel.text = normaltip;
        self.tiplabel.textColor = [UIColor darkGrayColor];
    }
    else {
        self.tiplabel.text = notreachtip;
        self.tiplabel.textColor = [UIColor redColor];
    }
    [afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:{
                self.tiplabel.text = notreachtip;
                self.tiplabel.textColor = [UIColor redColor];
                NSLog(@"网络不通：%@",@(status) );
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                self.tiplabel.text = normaltip;
                self.tiplabel.textColor = [UIColor darkGrayColor];
                NSLog(@"网络通过WIFI连接：%@",@(status));
                break;
            }
            default:
                break;
        }
    }];
    [afNetworkReachabilityManager startMonitoring];
}

- (void)handleEnteredBackground:(id)param {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self refresh_support];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self refresh_support];
    });
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    if ([globalvar shareglobalvar].tianya_support_dirty) {
        NSArray* tianya_audiolist = [(Tianyavc*)[globalvar shareglobalvar].taiyavc tianya_audiolist];
        BOOL needfresh = NO;
        if ([tianya_audiolist count] > 0) {
            for (int i = 0; i < [self.audiolist count]; i ++) {
                protocol_audio_info* ainfo = self.audiolist[i];
                for (int j = 0; j < [tianya_audiolist count]; j ++) {
                    protocol_audio_info* ainfo2 = tianya_audiolist[j];
                    if ([ainfo.audioid isEqualToString:ainfo2.audioid]) {
                        if (ainfo.now_support_type != ainfo2.now_support_type) {
                            ainfo.now_support_type = ainfo2.now_support_type;
                            needfresh = YES;
                        }
                        break;
                    }
                }
            }
        }
        if (needfresh) {
            [self.ranklisttv reloadData];
        }
        [globalvar shareglobalvar].tianya_support_dirty = NO;
    }
    [super viewDidAppear:animated];
}

-(NSArray*)ranklist_audiolist {
    return self.audiolist;
}

@end

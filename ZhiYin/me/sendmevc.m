//
//  sendmevc.m
//  ZhiYin
//
//  Created by freejet on 2018/10/11.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "sendmevc.h"
#import <AFHTTPSessionManager+Synchronous.h>
#import "zyprotocol.h"
#import "globalvar.h"
#import "commom_utils.h"
#import <MagicalRecord/MagicalRecord.h>
#import "SupportM+CoreDataClass.h"
#import "MJRefresh.h"
#import "sendmecell.h"
#import "MsglasttimeM+CoreDataClass.h"
#import "complaintvc.h"
#import "BlacklistM+CoreDataClass.h"

@interface sendmevc ()
{
    dispatch_source_t _speak_timer;
}
@property(nonatomic, strong)NSArray* audiolist;
@property(nonatomic, strong)AVPlayer* avplayer;
@property(nonatomic, assign)NSInteger curplayingitem;
@property(nonatomic, assign)NSInteger speak_img_index;
@property(nonatomic, strong)NSIndexPath* lastselectindexpath;
@end

@implementation sendmevc

-(void)update_msglasttime:(NSString*)newmsgtime {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MsglasttimeM* item = [MsglasttimeM MR_findFirstInContext:localContext];
        if (!item) {
            item = [MsglasttimeM MR_createEntityInContext:localContext];
        }
        item.msglasttime = newmsgtime;
        [localContext MR_saveToPersistentStoreAndWait];
    } completion:^(BOOL success, NSError *error) {
        NSLog(@"magicalrecord udpate lasttime: %d, err:%@", success, error);
    }];
}

-(void)request_sendme_audio {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    NSString* url = [zyprotocol_sendme_audio sendme_url];
    NSDictionary* param = [zyprotocol_sendme_audio sendme_param:30];
    NSError *error = nil;
    NSDictionary *result = [manager syncPOST:url
                                  parameters:param
                                        task:NULL
                                       error:&error];
    protocol_sendme_audio_info* sendme_audio = [zyprotocol_sendme_audio token_response:result];
    BOOL ret = NO;
    if (sendme_audio.IsSuccess) {
        NSLog(@"request sendme_data successful");
        self.audiolist = sendme_audio.audio_info_list;
        ret = YES;
        if ([self.audiolist count] > 0) {
            protocol_audio_info* audioinfo = self.audiolist[0];
            [self update_msglasttime:audioinfo.createtime];
            
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
                            [self.sendmetv reloadData];
                        });
                    }
                }
            } completion:^(BOOL success, NSError *error) {
                NSLog(@"magicalrecord find: %d, err:%@", success, error);
            }];
        }
    }
    else {
        NSLog(@"request sendme_audio error");
        dispatch_sync(dispatch_get_main_queue(), ^{
            [QMUITips showError:@"未能加载到数据，请保持网络畅通，往下滑动界面进行重试。" inView:self.view hideAfterDelay:3];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideEmptyView];
        [self.sendmetv reloadData];
        [self.sendmetv.mj_header endRefreshing];
        [self.sendmetv.mj_footer endRefreshing];
        self.lastselectindexpath = nil;
    });
}

- (void)settableview {
    MJRefreshNormalHeader* header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        NSLog(@"refresh sendme audio");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self request_sendme_audio];
        });
    }];
    header.automaticallyChangeAlpha = YES;
    [header setTitle:@"请再用力拉一下" forState:MJRefreshStateIdle];
    [header setTitle:@"松手就刷新数据" forState:MJRefreshStatePulling];
    [header setTitle:@"有事启奏正在路上..." forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.sendmetv.mj_header = header;
    
    MJRefreshBackNormalFooter* footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        NSLog(@"refresh sendme audio, at footer");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self request_sendme_audio];
        });
    }];
    footer.automaticallyChangeAlpha = YES;
    [footer setTitle:@"请再用力拉一下" forState:MJRefreshStateIdle];
    [footer setTitle:@"松手就刷新数据" forState:MJRefreshStatePulling];
    [footer setTitle:@"有事启奏正在路上..." forState:MJRefreshStateRefreshing];
    self.sendmetv.mj_footer = footer;
    
    self.sendmetv.delegate = self;
    self.sendmetv.dataSource = self;
    
    // 没有数据的cell隐藏分隔线
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.sendmetv.tableFooterView = view;
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
        sendmecell* cell = [sendmecell cellwithTableview:tableView];
        protocol_audio_info* audioinfo = self.audiolist[indexPath.row];
        cell.duration.text = [NSString stringWithFormat:@"%d\"", (int)audioinfo.audioduration];
        cell.time.text = [commom_utils howlonginfo:audioinfo.createtime];
        [cell.play setImage:[UIImage imageNamed:@"tianya_speak0"]];
        NSString* info = [NSString stringWithFormat:@"(来自)%@", audioinfo.nickname];
        cell.nickname.text = info;
        [cell.isaybtn setImage:[UIImage imageNamed:@"respose"] forState:UIControlStateNormal];
        [cell.isaybtn addTarget:self action:@selector(isayaction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.complain_audio setImage:[UIImage imageNamed:@"tianya_complaint_audio"] forState:UIControlStateNormal];
        [cell.complain_audio addTarget:self action:@selector(complain_action:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    return nil;
}

-(void)complain_action:(UIButton*)complainbtn {
    NSIndexPath* ip =  [self.sendmetv qmui_indexPathForRowAtView:complainbtn];
    if (ip) {
        protocol_audio_info* audioinfo = self.audiolist[ip.row];
        if ([audioinfo.clientid isEqualToString:[globalvar shareglobalvar].clientID]) {
            [QMUITips showInfo:@"请不要投诉自己，对自己好一点，不要发布不良内容就可以了。" inView:self.view hideAfterDelay:3];
            return;
        }
        [globalvar shareglobalvar].sendmevc = self;
        complaintvc* cvc = [[UIStoryboard storyboardWithName:@"complaint" bundle:nil]instantiateViewControllerWithIdentifier:@"complaint"];
        [cvc complaint_who:audioinfo.clientid nickname:audioinfo.nickname audioid:audioinfo.audioid onvcindex:TAB_INDEX_SEND_ME];
        [[globalvar shareglobalvar].tabbarcontroller changevc_oversendme:cvc title:@"寡人怒了"];
    }
}

- (void)reset_lastaudioimage {
    NSIndexPath* selindexpath = self.lastselectindexpath;
    if (selindexpath) {
        sendmecell* cell = (sendmecell*)[self.sendmetv cellForRowAtIndexPath:selindexpath];
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
    NSIndexPath* selindexpath = self.sendmetv.indexPathForSelectedRow;
    if (selindexpath) {
        sendmecell* cell = (sendmecell*)[self.sendmetv cellForRowAtIndexPath:selindexpath];
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
    [self showEmptyViewWithLoading:YES image:nil text:@"有事启奏正在加载的路上..." detailText:nil buttonTitle:nil buttonAction:nil];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self request_sendme_audio];
    });
    [self settableview];
    [self setcurplayitem:-1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.returnbtn setImage:[UIImage imageNamed:@"me_returnbtn"] forState:UIControlStateNormal];
    [self.returnbtn addTarget:self action:@selector(returnaction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)isayaction:(UIButton*)isaybtn {
    NSLog(@"isaybtn clicked");
    NSIndexPath* ip =  [self.sendmetv qmui_indexPathForRowAtView:isaybtn];
    if (ip) {
        protocol_audio_info* audioinfo = self.audiolist[ip.row];
        [globalvar shareglobalvar].towhere = TO_WHERE_SOMEONE;
        [globalvar shareglobalvar].toclientid = audioinfo.clientid;
        [globalvar shareglobalvar].tonickname = audioinfo.nickname;
        UITabBarController* rootvc = (UITabBarController*)[UIApplication sharedApplication].delegate.window.rootViewController;
        rootvc.selectedIndex = 1;
        [globalvar shareglobalvar].current_tab = 1;
    }
}

- (void)returnaction:(UIButton*)btn {
    [[globalvar shareglobalvar].tabbarcontroller resetmevc];
}

@end

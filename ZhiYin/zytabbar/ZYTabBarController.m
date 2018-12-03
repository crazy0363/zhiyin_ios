//
//  ZYTabBarController.m
//  ZhiYin
//
//  Created by pro on 2018/9/20.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "ZYTabBarController.h"
#import <QMUIKit/QMUIKit.h>
#import "AudioRecorderMgr.h"
#import "MeViewController.h"
#import <AFHTTPSessionManager+Synchronous.h>
#import "zyprotocol.h"
#import "globalvar.h"
#import "Tianyavc.h"
#import "Mizhiyinvc.h"
#import "Ranklistvc.h"
#import "ASIFormDataRequest.h"
#import "changevoicevc.h"
#import "topicvc.h"

@interface ZYTabBarController() <AudioRecorderMgrDelegate, ASIHTTPRequestDelegate>
{
    QMUIPopupContainerView* popTipsView;
    BOOL _upInButton;
    BOOL _recording;
    BOOL _shouldSendRecord;
}
@property (nonatomic, strong) NSString *recordfilepath;
@property(nonatomic, assign)NSInteger recordduration;
@end

@implementation ZYTabBarController

#define QUICK_RECORD_MAX_LEN 60
#define QUICK_RECORD_MIN_LEN 2

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _tabbarCenterBtn = [[TabBarCenterBtn alloc] init];
//    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(centerBtnLongPress:)];
//    longPress.minimumPressDuration = 0.2;
//    [_tabbarCenterBtn.centerBtn addGestureRecognizer:longPress];
//    [_tabbarCenterBtn.centerBtn addTarget:self action:@selector(cneterBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self setValue:_tabbarCenterBtn forKeyPath:@"tabBar"];
    
    self.delegate = self;
    
    [self addChildVCs];
    
    popTipsView = [[QMUIPopupContainerView alloc]init];
    popTipsView.automaticallyHidesWhenUserTap = YES;
    
    [self send_onlinecount];
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(send_onlinecount) userInfo:nil repeats:YES];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSLog(@"tabbar:%d", (int)item.tag);
    if (item.tag == 1) {
        // mizhiyin
        if ([globalvar shareglobalvar].current_tab != item.tag) {
            [globalvar shareglobalvar].towhere = TO_WHERE_TIANYA;
            [globalvar shareglobalvar].toclientid = @"";
            [globalvar shareglobalvar].tonickname = @"";
        }
    }
    [globalvar shareglobalvar].current_tab = item.tag;
}

- (void)showRecordingPopTips {
    [popTipsView showWithAnimated:YES];
    // 汽泡的颜色
    popTipsView.backgroundColor = [UIColor darkGrayColor];
//    popTipsView.backgroundColor = UIColorMakeWithRGBA(200,200,200,0.15);
    // 蒙层的颜色
    popTipsView.maskViewBackgroundColor = UIColorMakeWithRGBA(0,0,0,0.15);
}

- (void)hideRecordingPopTips {
    [popTipsView hideWithAnimated:YES];
}

- (void)setRecordingPopTipsTitle:(NSString*)title {
    popTipsView.textLabel.text = title;
    popTipsView.textLabel.font = [UIFont systemFontOfSize:13];
    popTipsView.textLabel.textColor = [UIColor whiteColor];
}

- (void)setRecordingPopTipsImage:(NSString*)imagename {
    UIImage* image = [UIImage imageNamed:imagename];
    popTipsView.imageView.image = image;
    [popTipsView layoutWithTargetRectInScreenCoordinate:CGRectMake(([UIScreen mainScreen].bounds.size.width - image.size.width)/2.0, ([UIScreen mainScreen].bounds.size.height - image.size.height)/2.0, image.size.width, image.size.height)];
}

-(void)centerBtnLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    BOOL hidePopTip = YES;
    _shouldSendRecord = NO;
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        NSLog(@"长按事件being");
        
        AudioRecorderMgr* recorderMgr = [AudioRecorderMgr shareAudioRecorderMgr];
        recorderMgr.recordDelegate = self;
        NSInteger status = [recorderMgr startRecord];
        if (status == 0) {
            [self setCenterViewTitle:@"松开发送"];
            [self showRecordingPopTips];
            [self setRecordingPopTipsTitle:@"手指上滑，取消发送"];
            [self setRecordingPopTipsImage:@"tabbar_recording_tips_0"];
            hidePopTip = NO;
            _upInButton = YES;
            _recording = YES;
        }
        else if (status == -1) {
            QMUIAlertController* alert = [QMUIAlertController alertControllerWithTitle:@"请您审批" message:@"请在 [设置-隐私-麦克风] 中允许本APP访问麦克风，然后重新录音。" preferredStyle:QMUIAlertControllerStyleAlert];
            [alert showWithAnimated:YES];
        }
        else if (status == -2) {
            [QMUITips showError:@"初始化麦克风时遇未明错误，请检查是否提供了访问的权限。" inView:self.view hideAfterDelay:3];
        }
        else if (status == -3) {
            [QMUITips showError:@"开始录音时遇未明错误，请检查麦克风是否正常可用，并重试。" inView:self.view hideAfterDelay:3];
        }
        else if (status == -4) {
            [QMUITips showError:@"创建录音器时遇未明错误，请检查是否提供了麦克风的访问权限。" inView:self.view hideAfterDelay:3];
        }
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (_recording) {
            CGPoint point = [gestureRecognizer locationInView:_tabbarCenterBtn.centerBtn];
            if ([_tabbarCenterBtn.centerBtn.layer containsPoint:point]) {
                NSLog(@"按钮内移动");
                [self setRecordingPopTipsTitle:@"手指上滑，取消发送"];
                [self setCenterViewTitle:@"松开发送"];
                _upInButton = YES;
            }
            else {
                NSLog(@"移出按钮");
                [self setRecordingPopTipsTitle:@"手指松开，取消发送"];
                [self setCenterViewTitle:@"松开取消"];
                _upInButton = NO;
            }
        }
        hidePopTip = NO;
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        NSLog(@"长按事件end");
        if (_recording) {
            if (_upInButton) {
                _shouldSendRecord = YES;
            }
            else {
                [QMUITips showInfo:@"已经取消发送，什么也没有做！" inView:self.view hideAfterDelay:1];
            }
            [[AudioRecorderMgr shareAudioRecorderMgr]stopRecord];
        }
        _recording = NO;
        [self setCenterViewTitle:@"一录发(长按)"];
    }
    else {
        NSLog(@"长按事件cancel/failed/..");
        [self setCenterViewTitle:@"一录发(长按)"];
        if (_recording) {
            [[AudioRecorderMgr shareAudioRecorderMgr]stopRecord];
        }
        _recording = NO;
    }
    
    if (hidePopTip) {
        [self hideRecordingPopTips];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"%@", responseString);
    
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    NSLog(@"%@", responseData);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@", error);
}

-(BOOL)request_sendaudio2 {
    NSString* requesturl = [zyprotocol_sendaudio sendaudio_url];
    NSData* audiodata = [NSData dataWithContentsOfFile:self.recordfilepath];
    NSDictionary* param = [zyprotocol_sendaudio sendaudio_parame:audiodata audiolen:self.recordduration towhere:TO_WHERE_TIANYA otherid:@""];
    NSURL *nsUrl = [NSURL URLWithString:requesturl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:nsUrl];
    for(id key in [param allKeys])
    {
        [request setPostValue:[param objectForKey:key] forKey:(NSString *)key];
    }
    [request buildPostBody];
    [request setDelegate:self];
    [request startAsynchronous];
    return YES;
}

- (BOOL)request_sendaudio {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    NSString* requesturl = [zyprotocol_sendaudio sendaudio_url];
    NSData* audiodata = [NSData dataWithContentsOfFile:self.recordfilepath];
    NSDictionary* param = [zyprotocol_sendaudio sendaudio_parame:audiodata audiolen:self.recordduration towhere:TO_WHERE_TIANYA otherid:@""];
    NSError *error = nil;
    NSDictionary *result = [manager syncPOST:requesturl
                                 parameters:param
                                       task:NULL
                                      error:&error];
    protocol_sendaudio_info* sendaudioinfo = [zyprotocol_sendaudio token_response:result];
    BOOL ret = NO;
    if (sendaudioinfo.IsSuccess) {
        NSLog(@"request sendaudio successful");
        dispatch_sync(dispatch_get_main_queue(), ^{
            [QMUITips showSucceed:@"已经发送到\"广场\"，可到\"寡人\"处查看发送记录或删除" inView:self.view hideAfterDelay:3];
            [(Tianyavc*)[globalvar shareglobalvar].taiyavc refresh_audiolist];
        });
        ret = YES;
    }
    else {
        NSLog(@"request sendaudio error");
        dispatch_sync(dispatch_get_main_queue(), ^{
            [QMUITips showError:@"发送遇阻，请确保网络畅通，再来一次吧。" inView:self.view hideAfterDelay:3];
        });
    }
    [[NSFileManager defaultManager] removeItemAtPath:self.recordfilepath error:nil];
    
    return ret;
}

- (void)setonlinecount:(NSInteger)oncount {
    NSString* ti = [NSString stringWithFormat:@"说话(%ld人在线)", (long)oncount];
    [globalvar shareglobalvar].mizhiyinvc.title = ti;
}

- (BOOL)request_onlinecount {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    NSString* requesturl = [zyprotocol_onlinecount onlinecount_url];
    NSDictionary* param = [zyprotocol_onlinecount onlinecount_param];
    NSError *error = nil;
    NSDictionary *result = [manager syncGET:requesturl
                                  parameters:param
                                        task:NULL
                                       error:&error];
    protocol_onlinecount_info* info = [zyprotocol_onlinecount token_response:result];
    BOOL ret = NO;
    if (info.IsSuccess) {
        NSLog(@"request onlinecount successful");
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self setonlinecount:info.onlinecount];
        });
        ret = YES;
    }
    else {
        NSLog(@"request onlinecount error");
    }
    
    return ret;
}

-(void)sendRecordfile {
    NSLog(@"send record, path:%@", self.recordfilepath);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self request_sendaudio];
        });
}

-(void)send_onlinecount {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self request_onlinecount];
    });
}

-(void)recordingCostTime:(NSInteger)lasttime {
    NSLog(@"录音用时：%d", (int)lasttime);
    if (_recording) {
        NSString* info = [NSString stringWithFormat:@"已录%d秒（最长%d秒）", (int)lasttime, QUICK_RECORD_MAX_LEN];
        [self setCenterViewTitle:info];
        if (lasttime >= QUICK_RECORD_MAX_LEN) {
            [[AudioRecorderMgr shareAudioRecorderMgr]stopRecord];
            _shouldSendRecord = YES;
        }
    }
}
-(void)recordFinish:(NSString*)savepath costtime:(NSUInteger)costtime {
    NSLog(@"录音结束：%@, costtime:%d", savepath, (int)costtime);
    _recording = NO;
    self.recordfilepath = savepath;
    self.recordduration = costtime;
    if (_shouldSendRecord) {
        NSLog(@"发送语音...");
        if (self.recordduration >= 2) {
            [self sendRecordfile];
//            changevoicevc* vc = [[UIStoryboard storyboardWithName:@"changevoice" bundle:nil]instantiateViewControllerWithIdentifier:@"changevoice"];
//            [UIApplication sharedApplication].delegate.window.rootViewController = vc;
        }
        else {
            [QMUITips showInfo:@"可以再多说两句吗？请不要短于两秒" inView:self.view hideAfterDelay:3];
        }
    }
}

-(void)recordCancel {
    NSLog(@"录音取消");
    self.recordfilepath = nil;
}

-(void)recordSpeakPower:(double)power {
//    NSLog(@"power:%f", power);
    int level = 1;
    if (power <= 0.15) {
        level = 1;
    }
    else if (power <= 0.39) {
        level = 2;
    }
    else if (power <= 0.63) {
        level = 3;
    }
    else if (power <= 0.87) {
        level = 4;
    }
    else {
        level = 5;
    }
    NSString* tipname = [NSString stringWithFormat:@"tabbar_recording_tips_%d", level];
    [self setRecordingPopTipsImage:tipname];
}

- (void)cneterBtnClicked:(UIButton *)button{
    [QMUITips showInfo:@"请按住说话，让世界听到您的声音" inView:self.view hideAfterDelay:1];
}

-(void)restvcs {
    NSArray* vcarrays = [NSArray arrayWithObjects:[globalvar shareglobalvar].taiyavc, [globalvar shareglobalvar].mizhiyinvc, [globalvar shareglobalvar].topicvc, [globalvar shareglobalvar].ranklistvc, [globalvar shareglobalvar].mevc, nil];
    self.viewControllers = vcarrays;
}

-(void)resetmevc {
    [self restvcs];
    self.selectedIndex = [self.viewControllers count]-1;
}

-(void)resettianya {
    [self restvcs];
    self.selectedIndex = TAB_INDEX_TAIYA;
}

-(void)resetrank {
    [self restvcs];
    self.selectedIndex = TAB_INDEX_RANK;
}

-(void)resetsendme {
    NSArray* vcarrays = [NSArray arrayWithObjects:[globalvar shareglobalvar].taiyavc, [globalvar shareglobalvar].mizhiyinvc, [globalvar shareglobalvar].topicvc, [globalvar shareglobalvar].ranklistvc, [globalvar shareglobalvar].sendmevc, nil];
    self.viewControllers = vcarrays;
    self.selectedIndex = [vcarrays count]-1;
}

-(void)resettopic {
    [self restvcs];
    self.selectedIndex = TAB_INDEX_TOPIC;
}

-(void)changevc_overme:(UIViewController*)newvc title:(NSString*)title {
    newvc.tabBarItem.tag = TAB_INDEX_ME;
    newvc.title = title;
    newvc.tabBarItem.image = [[UIImage imageNamed:@"tabbar_me"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    newvc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_me"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSArray* vcarrays = [NSArray arrayWithObjects:[globalvar shareglobalvar].taiyavc, [globalvar shareglobalvar].mizhiyinvc, [globalvar shareglobalvar].topicvc, [globalvar shareglobalvar].ranklistvc, newvc, nil];
    self.viewControllers = vcarrays;
    self.selectedIndex = [vcarrays count]-1;
}

-(void)changevc_overtianya:(UIViewController*)newvc title:(NSString*)title {
    newvc.tabBarItem.tag = TAB_INDEX_TAIYA;
    newvc.title = title;
    newvc.tabBarItem.image = [[UIImage imageNamed:@"tabbar_where"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    newvc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_where"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSArray* vcarrays = [NSArray arrayWithObjects:newvc, [globalvar shareglobalvar].mizhiyinvc, [globalvar shareglobalvar].topicvc, [globalvar shareglobalvar].ranklistvc, [globalvar shareglobalvar].mevc, nil];
    self.viewControllers = vcarrays;
    self.selectedIndex = TAB_INDEX_TAIYA;
}

-(void)changevc_overtopic:(UIViewController*)newvc title:(NSString*)title {
    newvc.tabBarItem.tag = TAB_INDEX_TOPIC;
    newvc.title = title;
    newvc.tabBarItem.image = [[UIImage imageNamed:@"tabbar_topic"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    newvc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_topic"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSArray* vcarrays = [NSArray arrayWithObjects:[globalvar shareglobalvar].taiyavc, [globalvar shareglobalvar].mizhiyinvc, newvc, [globalvar shareglobalvar].ranklistvc, [globalvar shareglobalvar].mevc, nil];
    self.viewControllers = vcarrays;
    self.selectedIndex = TAB_INDEX_TOPIC;
}

-(void)changevc_overrank:(UIViewController*)newvc title:(NSString*)title {
    newvc.tabBarItem.tag = TAB_INDEX_RANK;
    newvc.title = title;
    newvc.tabBarItem.image = [[UIImage imageNamed:@"tabbar_list"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    newvc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_list"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSArray* vcarrays = [NSArray arrayWithObjects:[globalvar shareglobalvar].taiyavc, [globalvar shareglobalvar].mizhiyinvc, [globalvar shareglobalvar].topicvc, newvc, [globalvar shareglobalvar].mevc, nil];
    self.viewControllers = vcarrays;
    self.selectedIndex = TAB_INDEX_RANK;
}

-(void)changevc_oversendme:(UIViewController*)newvc title:(NSString*)title {
    newvc.tabBarItem.tag = TAB_INDEX_SEND_ME;
    newvc.title = title;
    newvc.tabBarItem.image = [[UIImage imageNamed:@"tabbar_me"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    newvc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_me"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSArray* vcarrays = [NSArray arrayWithObjects:[globalvar shareglobalvar].taiyavc, [globalvar shareglobalvar].mizhiyinvc, [globalvar shareglobalvar].topicvc, [globalvar shareglobalvar].ranklistvc, newvc, nil];
    self.viewControllers = vcarrays;
    self.selectedIndex = [vcarrays count]-1;
}

- (void)addChildVCs{
    Tianyavc* tianvc = [[UIStoryboard storyboardWithName:@"tianya" bundle:nil]instantiateViewControllerWithIdentifier:@"tianya"];
    tianvc.tabBarItem.tag = TAB_INDEX_TAIYA;
    [self addChildVC:tianvc title:@"广场" imageName:@"tabbar_where" selectImage:@"tabbar_where"];
    [globalvar shareglobalvar].taiyavc = tianvc;
    
    Mizhiyinvc* mizhiyinvc = [[UIStoryboard storyboardWithName:@"mizhiyin" bundle:nil]instantiateViewControllerWithIdentifier:@"mizhiyin"];
    mizhiyinvc.tabBarItem.tag = TAB_INDEX_SPEAK;
    [self addChildVC:mizhiyinvc title:@"说话" imageName:@"tabbar_looking" selectImage:@"tabbar_looking"];
    [globalvar shareglobalvar].mizhiyinvc = mizhiyinvc;
    
    topicvc* tvc = [[UIStoryboard storyboardWithName:@"topic" bundle:nil]instantiateViewControllerWithIdentifier:@"topic"];
    tvc.tabBarItem.tag = TAB_INDEX_TOPIC;
    [self addChildVC:tvc title:@"今日话题" imageName:@"tabbar_topic" selectImage:@"tabbar_topic"];
    [globalvar shareglobalvar].topicvc = tvc;
    
    Ranklistvc* ranklistvc = [[UIStoryboard storyboardWithName:@"ranklist" bundle:nil]instantiateViewControllerWithIdentifier:@"ranklist"];
    tianvc.tabBarItem.tag = TAB_INDEX_RANK;
    [self addChildVC:ranklistvc title:@"人气榜" imageName:@"tabbar_list" selectImage:@"tabbar_list"];
    [globalvar shareglobalvar].ranklistvc = ranklistvc;
    
    MeViewController* mevc = [[UIStoryboard storyboardWithName:@"me" bundle:nil]instantiateViewControllerWithIdentifier:@"mevcstory"];
    mevc.tabBarItem.tag = TAB_INDEX_ME;
    [self addChildVC:mevc title:@"寡人" imageName:@"tabbar_me" selectImage:@"tabbar_me"];
    [globalvar shareglobalvar].mevc = mevc;
}

- (void)addChildVC:(UIViewController*)vc title:(NSString*)title imageName:(NSString*)imagename selectImage:(NSString*)selImageName {
    vc.title = title;
    vc.tabBarItem.image = [[UIImage imageNamed:imagename]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.selectedImage = [[UIImage imageNamed:selImageName]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self addChildViewController:vc];
}

- (void)setCenterViewTitle:(NSString*)title {
    self.viewControllers[2].title = title;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    if (tabBarController.selectedIndex == 2){
        // 点击中间按钮
        NSLog(@"centerbtn clicked");
    }
    else {
       
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

#define kBadgeViewTag 200  // 红点起始tag值
#define kBadgeWidth  6  // 红点宽高

@implementation UITabBar (Extend)

//显示小红点
- (void)showBadgeOnItemIndex:(NSInteger)index{
    [self removeBadgeOnItemIndex:index];
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = kBadgeViewTag + index;
    badgeView.layer.cornerRadius = kBadgeWidth / 2;
    badgeView.backgroundColor = [UIColor redColor];
    [self addSubview:badgeView];
    
    // 设置小红点的位置
    int i = 0;
    for (UIView* subView in self.subviews){
        if ([subView isKindOfClass:NSClassFromString(@"UITabBarButton")]){
            // 找到需要加小红点的view，根据frame设置小红点的位置
            if (i == index) {
                // 数字9为向右边的偏移量，可以根据具体情况调整
                CGFloat x = subView.frame.origin.x + subView.frame.size.width / 2 + 9;
                CGFloat y = 6;
                badgeView.frame = CGRectMake(x, y, kBadgeWidth, kBadgeWidth);
                break;
            }
            i++;
        }
    }
}

//显示小红点
- (void)showLastBadgeOnItemIndex:(NSInteger)index{
    [self removeBadgeOnItemIndex:index];
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = kBadgeViewTag + index;
    badgeView.layer.cornerRadius = kBadgeWidth / 2;
    badgeView.backgroundColor = [UIColor redColor];
    [self addSubview:badgeView];
    
    // 设置小红点的位置
    CGFloat lastx = 0.;
    CGFloat lastw = 0.;
    for (UIView* subView in self.subviews){
        if ([subView isKindOfClass:NSClassFromString(@"UITabBarButton")]){
            if (lastx < subView.frame.origin.x) {
                lastx = subView.frame.origin.x;
                lastw = subView.frame.size.width;
            }
        }
    }
    CGFloat x = lastx + lastw / 2 + 9;
    CGFloat y = 6;
    badgeView.frame = CGRectMake(x, y, kBadgeWidth, kBadgeWidth);
}

// 隐藏小红点
- (void)hideBadgeOnItemIndex:(NSInteger)index{
    [self removeBadgeOnItemIndex:index];
}

// 移除小红点
- (void)removeBadgeOnItemIndex:(NSInteger)index{
    // 根据tag的值移除
    for (UIView *subView in self.subviews) {
        if (subView.tag == kBadgeViewTag + index) {
            [subView removeFromSuperview];
        }
    }
}

@end

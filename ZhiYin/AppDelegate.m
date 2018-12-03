//
//  AppDelegate.m
//  ZhiYin
//
//  Created by pro on 2018/9/18.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "AppDelegate.h"
#import <QMUIKit/QMUIKit.h>
#import "zytabbar/ZYTabBarController.h"
#import "utils/globalvar.h"
#import "utils/UQID/YDDevice.h"
#import "AFNetworking.h"
#import <AFHTTPSessionManager+Synchronous.h>
#import "protocol/zyprotocol.h"
#import <MagicalRecord/MagicalRecord.h>
#import "MsglasttimeM+CoreDataClass.h"
#import "utils/commom_utils.h"
#import "me/MeViewController.h"

@interface AppDelegate ()

@property(nonatomic, strong)UITabBarController* tabbarcontroller;

@end

@implementation AppDelegate

- (BOOL)requestnickname {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    NSString* nickurl = [zyprotocol_nickname nickname_url];
    NSDictionary* param = [zyprotocol_nickname nickname_parame];
    NSError *error = nil;
    NSDictionary *result = [manager syncGET:nickurl
                           parameters:param
                                 task:NULL
                                error:&error];
    NSLog(@"data type:%@", [result class]);
    protocol_nickname_info* nicknameinfo = [zyprotocol_nickname token_response:result];
    BOOL ret = NO;
    if (nicknameinfo.IsSuccess) {
        NSLog(@"request nikname successful");
        [globalvar shareglobalvar].nickname = nicknameinfo.NickName;
        ret = YES;
    }
    else {
        NSLog(@"request nickname error");
    }
    
    return ret;
}

- (void)createnicknameTimer
{
    dispatch_source_t nickname_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(nickname_timer, DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
    
    __weak __typeof(self) weakSelf = self;
    
    dispatch_source_set_event_handler(nickname_timer, ^{
        __strong __typeof(weakSelf) _self = weakSelf;
        dispatch_suspend(nickname_timer);
        if ([_self requestnickname]) {
            dispatch_resume(nickname_timer);
            dispatch_source_cancel(nickname_timer);
        }
        else {
            dispatch_resume(nickname_timer);
        }
    });
    
    dispatch_resume(nickname_timer);
}

-(void)newmsg_uiflag {
    UITabBarController* tbvc = [globalvar shareglobalvar].tabbarcontroller;
    [tbvc.tabBar showLastBadgeOnItemIndex:TAB_INDEX_ME];
    MeViewController* mevc = (MeViewController*)[globalvar shareglobalvar].mevc;
    [mevc refreshtableview];
}

-(void)requestLastmsg {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    NSString* url = [zyprotocol_sendme_audio sendme_url];
    NSDictionary* param = [zyprotocol_sendme_audio sendme_param:1];
    NSError *error = nil;
    NSDictionary *result = [manager syncPOST:url
                                  parameters:param
                                        task:NULL
                                       error:&error];
    protocol_sendme_audio_info* sendme_audio = [zyprotocol_sendme_audio token_response:result];
    if (sendme_audio.IsSuccess) {
        if ([sendme_audio.audio_info_list count] > 0) {
            protocol_audio_info* audioinfo = sendme_audio.audio_info_list[0];
            NSString* msgtime = audioinfo.createtime;
            
            BOOL newmsg = YES;
            MsglasttimeM* item = [MsglasttimeM MR_findFirst];
            if (item) {
                NSString* local_lasttime = item.msglasttime;
                int more = [commom_utils compareDate:local_lasttime withDate:msgtime];
                if (more != 1) {
                    newmsg = NO;
                }
            }
            if (newmsg) {
                [globalvar shareglobalvar].newmsg_sendtome = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self newmsg_uiflag];
                });
            }
        }
    }
}

-(void)start_requestLastmsg {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self requestLastmsg];
    });
}

- (void)createnewmsgTimer
{
    [self start_requestLastmsg];
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(start_requestLastmsg) userInfo:nil repeats:YES];
}

- (void)firstseeAPP {
    NSString *key = @"isFirst";
    BOOL isFirst = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (!isFirst) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
        
        QMUIAlertAction* action = [QMUIAlertAction actionWithTitle:@"知道了" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            
        }];
        NSString* info = @"如果您使用了本APP进行了录音，并发送了语音，则表示您同意了本APP以下的使用条款，请您仔细阅读：\n\n1. 杜绝发送不良语音。不良语音包括但不限于：不当政治言论、涉黄涉黑、辱骂他人、广告干扰、违反社会道德底线等内容。\n\n2. 您发送了语音，则意味着授权对语音内容进行审核，这如同文章的发表。\n\n3. 本APP的服务端进行语音审核，任何不良语音都将被删除，发布不良语音者将被拉入黑名单而无法再次发布语音。\n\n4. 请遵纪守法，做一个有道德修养的人。";
        QMUIAlertController* alertvc = [[QMUIAlertController alloc]initWithTitle:@"使用条款" message:info preferredStyle:QMUIAlertControllerStyleAlert];
        [alertvc addAction:action];
        [alertvc showWithAnimated:YES];
    }
    else {
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [globalvar shareglobalvar];
    [self createnicknameTimer];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"zhiyi.sqlite"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createTabbar];
        [self firstseeAPP];
    });

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

-(void)setwindowRootviewcontroller:(UIViewController*)vc {
    self.window.rootViewController = vc;
}

-(void)resetwindowRootviewcontroller {
    self.window.rootViewController = self.tabbarcontroller;
    [self.window makeKeyAndVisible];
}

- (void)createTabbar {
    self.window.backgroundColor = [UIColor whiteColor];
    UITabBarController* tabbarvc = [[ZYTabBarController alloc]init];
    self.tabbarcontroller = tabbarvc;
//    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:tabbarvc];
    self.window.rootViewController = tabbarvc;
    [self.window makeKeyAndVisible];
    [globalvar shareglobalvar].tabbarcontroller = (ZYTabBarController*)tabbarvc;
    
    [self createnewmsgTimer];
    
//    UIViewController *c1=[[UIViewController alloc]init];
//    c1.view.backgroundColor=[UIColor whiteColor];
//    c1.tabBarItem.title=@"天涯何处";
//    c1.tabBarItem.image=[UIImage imageNamed:@"tabbar_where"];
//
//    UIViewController *c2=[[UIViewController alloc]init];
//    c2.view.backgroundColor=[UIColor brownColor];
//    c2.tabBarItem.title=@"觅知音";
//    c2.tabBarItem.image=[UIImage imageNamed:@"tabbar_looking"];
//
//    UIViewController *c3=[[UIViewController alloc]init];
//    c3.view.backgroundColor = [UIColor yellowColor];
//    c3.tabBarItem.title=@"风云榜";
//    c3.tabBarItem.image=[UIImage imageNamed:@"tabbar_list"];
//
//    UIViewController *c4=[[UIViewController alloc]init];
//    c4.view.backgroundColor = [UIColor blackColor];
//    c4.tabBarItem.title=@"寡人";
//    c4.tabBarItem.image=[UIImage imageNamed:@"tabbar_me"];
//    c4.tabBarItem.badgeValue = @"33";
//
//    tabbarvc.viewControllers=@[c1,c2,c3,c4];

    
	
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


@end

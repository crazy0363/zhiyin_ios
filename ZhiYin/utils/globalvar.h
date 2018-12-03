//
//  globalvar.h
//  ZhiYin
//
//  Created by pro on 2018/9/26.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZYTabBarController.h"

NS_ASSUME_NONNULL_BEGIN

@interface globalvar : NSObject

@property(nonatomic, copy)NSString* clientID;
@property(nonatomic, copy)NSString* nickname;
@property(nonatomic, copy)NSString* ostype;
@property(nonatomic, copy)NSString* osver;
@property(nonatomic, copy)NSString* appname;
@property(nonatomic, copy)NSString* appver;
@property(nonatomic, copy)NSString* signkey;
@property(nonatomic, assign)NSInteger towhere;
@property(nonatomic, copy)NSString* toclientid;
@property(nonatomic, copy)NSString* tonickname;
@property(nonatomic, strong)UIViewController* taiyavc;
@property(nonatomic, strong)UIViewController* mizhiyinvc;
@property(nonatomic, strong)UIViewController* topicvc;
@property(nonatomic, strong)UIViewController* nowsendvc;
@property(nonatomic, strong)UIViewController* ranklistvc;
@property(nonatomic, strong)UIViewController* mevc;
@property(nonatomic, strong)UIViewController* sendmevc;
@property(nonatomic, assign)BOOL tianya_support_dirty;
@property(nonatomic, assign)BOOL ranklist_support_dirty;
@property(nonatomic, strong)ZYTabBarController* tabbarcontroller;
@property(nonatomic, assign)float autoSizeScaleX;
@property(nonatomic, assign)float autoSizeScaleY;
@property(nonatomic, assign)NSInteger current_tab;
@property(nonatomic, assign)BOOL newmsg_sendtome;
@property(nonatomic, strong)NSString* topicid;

+ (globalvar *)shareglobalvar;

@end

NS_ASSUME_NONNULL_END

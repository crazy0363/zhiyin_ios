//
//  AppDelegate.h
//  ZhiYin
//
//  Created by pro on 2018/9/18.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void)setwindowRootviewcontroller:(UIViewController*)vc;
-(void)resetwindowRootviewcontroller;
@end


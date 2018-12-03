//
//  ZYTabBarController.h
//  ZhiYin
//
//  Created by pro on 2018/9/20.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TabBarCenterBtn.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum  {
    TAB_INDEX_TAIYA = 0,
    TAB_INDEX_SPEAK = 1,
    TAB_INDEX_TOPIC = 2,
    TAB_INDEX_RANK = 3,
    TAB_INDEX_ME = 4,
    TAB_INDEX_SEND_ME = 5,
}TAB_INDEX;

@interface ZYTabBarController : UITabBarController<UITabBarControllerDelegate>
@property (nonatomic, strong) TabBarCenterBtn* tabbarCenterBtn;
-(void)resetmevc;
-(void)resettianya;
-(void)resetrank;
-(void)resetsendme;
-(void)resettopic;
-(void)changevc_overme:(UIViewController*)newvc title:(NSString*)title;
-(void)changevc_overtianya:(UIViewController*)newvc title:(NSString*)title;
-(void)changevc_overrank:(UIViewController*)newvc title:(NSString*)title;
-(void)changevc_oversendme:(UIViewController*)newvc title:(NSString*)title;
-(void)changevc_overtopic:(UIViewController*)newvc title:(NSString*)title;
@end

@interface UITabBar (Extend)

- (void)showLastBadgeOnItemIndex:(NSInteger)index;
- (void)showBadgeOnItemIndex:(NSInteger)index; // 显示小红点
- (void)hideBadgeOnItemIndex:(NSInteger)index; // 隐藏小红点


@end

NS_ASSUME_NONNULL_END

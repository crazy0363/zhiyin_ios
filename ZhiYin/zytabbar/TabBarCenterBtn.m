//
//  TabBarCenterBtn.m
//  ZhiYin
//
//  Created by pro on 2018/9/20.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "TabBarCenterBtn.h"

@implementation TabBarCenterBtn

- (instancetype)init{
    if (self = [super init]){
        [self initView];
    }
    return self;
}

- (void)initView{
    _centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *normalImage = [UIImage imageNamed:@"tabbar_send_now"];
    UIImage *pressImage = [UIImage imageNamed:@"tabbar_send_now"];
    [_centerBtn setImage:normalImage forState:UIControlStateNormal];
    [_centerBtn setImage:pressImage forState:UIControlStateHighlighted];
    _centerBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - normalImage.size.width)/2.0, - normalImage.size.height/2.0, normalImage.size.width, normalImage.size.height);
    [self addSubview:_centerBtn];
}

// 使按钮超出tarbar的那部分也能点击生效
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    CGPoint tempPoint = [self.centerBtn convertPoint:point fromView:self];
    if (CGRectContainsPoint(self.centerBtn.bounds, tempPoint)){
        return _centerBtn;
    }
    else {
        return [super hitTest:point withEvent:event];
    }
}

@end

//
//  globalvar.m
//  ZhiYin
//
//  Created by pro on 2018/9/26.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "globalvar.h"
#import "cryptotool.h"
#import "UQID/YDDevice.h"

@implementation globalvar

+ (globalvar *)shareglobalvar
{
    static globalvar *shareglobalvar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareglobalvar = [[self alloc] init];
        shareglobalvar.clientID = [YDDevice getUQID];
        shareglobalvar.ostype = @"iOS";
        shareglobalvar.osver = [UIDevice currentDevice].systemVersion;
        shareglobalvar.appname = @"zhiyi";
        shareglobalvar.appver = @"1.0.0";
        shareglobalvar.signkey = @"这个key是错误的，请向作者索要，或者接入您自己的服务器来使用，因为框架都是可行的";
        
        // 320 * 480 --iphone4s
        // 320 * 568 --iphoneSE
        shareglobalvar.autoSizeScaleX = [[UIScreen mainScreen]bounds].size.width/320.f;
        shareglobalvar.autoSizeScaleY = [[UIScreen mainScreen]bounds].size.height/568.f;
    });
    return shareglobalvar;
}

@end

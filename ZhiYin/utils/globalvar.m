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
        NSString* tmp = [NSString stringWithFormat:@"%@_%@_%@_%@_%@_666666", shareglobalvar.ostype,
                         shareglobalvar.osver, shareglobalvar.appname, shareglobalvar.appver, shareglobalvar.clientID];
        shareglobalvar.signkey = [cryptotool md5EncodeFromStr:tmp];
        
        // 320 * 480 --iphone4s
        // 320 * 568 --iphoneSE
        shareglobalvar.autoSizeScaleX = [[UIScreen mainScreen]bounds].size.width/320.f;
        shareglobalvar.autoSizeScaleY = [[UIScreen mainScreen]bounds].size.height/568.f;
    });
    return shareglobalvar;
}

@end

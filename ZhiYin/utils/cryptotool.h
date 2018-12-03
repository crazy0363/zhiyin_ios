//
//  cryptotool.h
//  ZhiYin
//
//  Created by pro on 2018/9/27.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface cryptotool : NSObject

+ (NSString *)md5EncodeFromStr:(NSString *)str;
+ (NSString *)base64EncodeWithData:(NSData *)sourceData;

@end

NS_ASSUME_NONNULL_END

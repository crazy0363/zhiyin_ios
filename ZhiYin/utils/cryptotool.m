//
//  cryptotool.m
//  ZhiYin
//
//  Created by pro on 2018/9/27.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "cryptotool.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation cryptotool

+ (NSString *)md5EncodeFromStr:(NSString *)str {
    if (str.length == 0) {
        return nil;
    }
    const char* original_str = (const char *)[str cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    CC_MD5(original_str, (uint)strlen(original_str), digist);
    NSMutableString* outPutStr = [[NSMutableString alloc]initWithCapacity:32];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [outPutStr appendFormat:@"%02x",digist[i]];
    }
    return outPutStr;
}

+ (NSString *)md5EncodeFromData:(NSData *)data {
    if (!data) {
        return nil;
    }
    //需要MD5变量并且初始化
    CC_MD5_CTX  md5;
    CC_MD5_Init(&md5);
    //开始加密(第一个参数：对md5变量去地址，要为该变量指向的内存空间计算好数据，第二个参数：需要计算的源数据，第三个参数：源数据的长度)
    CC_MD5_Update(&md5, data.bytes, (CC_LONG)data.length);
    //声明一个无符号的字符数组，用来盛放转换好的数据
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //将数据放入result数组
    CC_MD5_Final(result, &md5);
    //将result中的字符拼接为OC语言中的字符串，以便我们使用。
    NSMutableString *resultString = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02X",result[i]];
    }
    NSLog(@"resultString=========%@",resultString);
    return resultString;
}

+ (NSString *)base64EncodeWithData:(NSData *)sourceData {
    if (!sourceData) {
        return nil;
    }
    NSString *resultStr = [sourceData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return resultStr;
}

@end

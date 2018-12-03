//
//  commom_utils.h
//  ZhiYin
//
//  Created by freejet on 2018/10/4.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface commom_utils : NSObject
+ (NSString *)howlonginfo:(NSString *)createtime;
+(int)compareDate:(NSString*)startDate withDate:(NSString*)endDate;
@end

@interface blackiteminfo : NSObject
@property(nonatomic, strong)NSString* userid;
@property(nonatomic, strong)NSString* nickname;
@end


NS_ASSUME_NONNULL_END

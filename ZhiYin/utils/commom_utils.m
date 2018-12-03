//
//  commom_utils.m
//  ZhiYin
//
//  Created by freejet on 2018/10/4.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "commom_utils.h"

@implementation blackiteminfo

@end

@implementation commom_utils
+ (NSString *)howlonginfo:(NSString *)createtime
{
    NSString* ct = [createtime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *timeDate = [dateFormatter dateFromString:ct];
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:timeDate];
    long temp = 0;
    NSString *result;
    if (timeInterval/60 < 1)
    {
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld分钟前",temp];
    }
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%ld小时前",temp];
    }
    else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%ld天前",temp];
    }
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%ld月前",temp];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld年前",temp];
    }
    return  result;
}

+(int)compareDate:(NSString*)startDate withDate:(NSString*)endDate{
    NSString* sd = [startDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSString* ed = [endDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    int comparisonResult;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate* date1 = [formatter dateFromString:sd];
    NSDate* date2 = [formatter dateFromString:ed];
    NSComparisonResult result = [date1 compare:date2];
    switch (result)
    {
            //date02比date01大
        case NSOrderedAscending:
            comparisonResult = 1;
            break;
            //date02比date01小
        case NSOrderedDescending:
            comparisonResult = -1;
            break;
            //date02=date01
        case NSOrderedSame:
            comparisonResult = 0;
            break;
        default:
            break;
    }
    return comparisonResult;
}
@end

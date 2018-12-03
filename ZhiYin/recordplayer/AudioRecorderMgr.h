//
//  AudioRecorderMgr.h
//  ZhiYin
//
//  Created by pro on 2018/9/25.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol AudioRecorderMgrDelegate <NSObject>

-(void)recordingCostTime:(NSInteger)lasttime;
-(void)recordFinish:(NSString*)savepath costtime:(NSUInteger)costtime;
-(void)recordCancel;
-(void)recordSpeakPower:(double)power;

@end

@interface AudioRecorderMgr : NSObject
@property (nonatomic, weak) id<AudioRecorderMgrDelegate> recordDelegate;
@property (nonatomic, assign) NSUInteger maxRecordTime;

+(AudioRecorderMgr*)shareAudioRecorderMgr;
-(NSInteger)startRecord;
-(void)stopRecord;
-(NSString*)recordFileDir;

@end

NS_ASSUME_NONNULL_END

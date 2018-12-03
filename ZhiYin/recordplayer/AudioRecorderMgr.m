//
//  AudioRecorderMgr.m
//  ZhiYin
//
//  Created by pro on 2018/9/25.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "AudioRecorderMgr.h"
#import <AVFoundation/AVFoundation.h>
#import <QMUIKit/QMUIKit.h>

@interface AudioRecorderMgr()<AVAudioRecorderDelegate>
{
    NSInteger _recordcount;
    BOOL _isDelete;
    dispatch_source_t _power_timer;
    dispatch_source_t _speak_timer;
}

@property (nonatomic, strong) NSString *recordfilepath;
@property (nonatomic, retain) AVAudioRecorder *audioRecorder;

@end

@implementation AudioRecorderMgr

#define RECORD_FILE_DIR @"record_temp"

+ (AudioRecorderMgr *)shareAudioRecorderMgr
{
    static AudioRecorderMgr *shareAudioRecorderManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareAudioRecorderManager = [[self alloc] init];
        if(![self fileExistsAtPath:[shareAudioRecorderManager recordFileDir]])
        {
            NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:RECORD_FILE_DIR];
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
    });
    return shareAudioRecorderManager;
}

+ (BOOL)fileExistsAtPath:(NSString*)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (NSString *)recordFileDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:RECORD_FILE_DIR];
}

- (NSDictionary *)audioRecordingSettings{
    
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithFloat:8000.0],AVSampleRateKey ,    // 采样率 8000/44100/96000
                              [NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,  // 录音格式
                              [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,   // 线性采样位数  8、16、24、32
                              [NSNumber numberWithInt:1],AVNumberOfChannelsKey,      // 声道 1，2
                              [NSNumber numberWithInt:AVAudioQualityMin],AVEncoderAudioQualityKey, // 录音质量
                              nil];
    return (settings);
}

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) { // 麦克风权限
        if (granted) {
            bCanRecord = true;
        }else{
            bCanRecord = false;
        }
    }];
    return bCanRecord;
}

- (NSInteger)startRecord
{
    if (![self canRecord])
    {
        return -1;
    }
    
    [self initRecordSession];
    
    NSError *error = nil;
    NSString *fileName = [NSString stringWithFormat:@"%@.aac",[self currenttime_rand_string]];
    NSString *savepath = [[self recordFileDir] stringByAppendingPathComponent:fileName];
    self.recordfilepath = savepath;
    NSURL *audioRecordingUrl = [NSURL fileURLWithPath:savepath];
    AVAudioRecorder *newRecorder = [[AVAudioRecorder alloc]
                                    initWithURL:audioRecordingUrl
                                    settings:[self audioRecordingSettings]
                                    error:&error];
    newRecorder.meteringEnabled = YES;
    self.audioRecorder = newRecorder;
    if (self.audioRecorder) {
        self.audioRecorder.delegate = self;
        if([self.audioRecorder prepareToRecord] == NO){
            NSLog(@"prepareToRecord fail！");
            return -2;
        }
        
        if ([self.audioRecorder record] == YES) {
            NSLog(@"录音开始！");
            [self disposespeaktimer];
            [self addTimer];
        }
        else {
            NSLog(@"录音失败！");
            self.audioRecorder = nil;
            return -3;
        }
    }
    else {
        NSLog(@"auioRecorder实例录音器失败！");
        return -4;
    }
    
    [self createPickSpeakPowerTimer];
    
    return 0;
}

- (void)createPickSpeakPowerTimer
{
    _power_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_power_timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
    
    __weak __typeof(self) weakSelf = self;
    
    dispatch_source_set_event_handler(_power_timer, ^{
        __strong __typeof(weakSelf) _self = weakSelf;
        [_self->_audioRecorder updateMeters];
        double lowPassResults = pow(10, (0.05 * [_self->_audioRecorder peakPowerForChannel:0]));
        if (_self.recordDelegate) {
            [_self.recordDelegate recordSpeakPower:lowPassResults];
        }
    });
    
    dispatch_resume(_power_timer);
}


-(NSString*)currenttime_rand_string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    return [NSString stringWithFormat:@"%@%06d",[dateFormatter stringFromDate:[NSDate date]],arc4random() % 100000];
}

-(void)disposespeaktimer {
    if (_speak_timer) {
        dispatch_source_cancel(_speak_timer);
        _speak_timer = NULL;
    }
}

- (void)addTimer
{
    _recordcount = 0;
    _speak_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_speak_timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
    
    __weak __typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(_speak_timer, ^{
        __strong __typeof(weakSelf) _self = weakSelf;
        _self->_recordcount ++;
        [_self->_recordDelegate recordingCostTime:_self->_recordcount];
    });
    
    dispatch_resume(_speak_timer);
}

- (void)initRecordSession
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];
}

- (void)stopRecord{
    [self stopRecordingOnAudioRecorder:self.audioRecorder];
    if (self.audioRecorder != nil) {
        if ([self.audioRecorder isRecording] == YES) {
            [self.audioRecorder stop];
        }
        self.audioRecorder = nil;
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (flag) {
        NSLog(@"audioRecorderDidFinishRecording 录音完成！");
        [_recordDelegate recordFinish:self.recordfilepath costtime:_recordcount];
    } else {
        NSLog(@"audioRecorderDidFinishRecording 录音过程意外终止！");
        [_recordDelegate recordCancel];
    }
    
    [self disposespeaktimer];
    
    if (_power_timer) {
        dispatch_source_cancel(_power_timer);
        _power_timer = NULL;
    }
    self.audioRecorder = nil;
}

- (void)stopRecordingOnAudioRecorder:(AVAudioRecorder *)recorder{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    [recorder stop];
}

- (void)countRecord
{
    _recordcount ++;
    [_recordDelegate recordingCostTime:_recordcount];
}

@end


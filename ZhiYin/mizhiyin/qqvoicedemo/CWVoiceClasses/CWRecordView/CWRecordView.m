//
//  CWRecordView.m
//  QQVoiceDemo
//
//  Created by chavez on 2017/10/11.
//  Copyright © 2017年 陈旺. All rights reserved.
//

#import "CWRecordView.h"
#import "CWAudioPlayView.h"
#import "CWRecordStateView.h"
#import "CWVoiceButton.h"
#import "UIView+CWChat.h"
#import "CWRecorder.h"
#import "CWVoiceView.h"
#import "CWFlieManager.h"
#import <QMUIKit/QMUIKit.h>
//----------------------录音界面---------------------------------//
@interface CWRecordView ()<CWRecorderDelegate>
{
     dispatch_source_t _record_timer;
}
@property (nonatomic, weak) CWRecordStateView *stateView;
@property (nonatomic, weak) CWVoiceButton *recordButton;    // 录音按钮
@property (nonatomic, weak) CWAudioPlayView *playView;   // 播放界面

@end

#define LIMIT_RECORD_DURATION 90

@implementation CWRecordView

-(void)disposerecordtimer {
    if (_record_timer) {
        dispatch_source_cancel(_record_timer);
        _record_timer = NULL;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    [self stateView];
    [self recordButton];
}

#pragma mark - subViews
- (CWAudioPlayView *)playView {
    if (_playView == nil) {
        CWAudioPlayView *view = [[CWAudioPlayView alloc] initWithFrame:self.bounds];
        [self addSubview:view];
        _playView = view;
    }
    return _playView;
}

- (CWRecordStateView *)stateView {
    if (_stateView == nil) {
        CWRecordStateView *stateView = [[CWRecordStateView alloc] initWithFrame:CGRectMake(0, 10, self.cw_width, 50)];
        stateView.recordState = CWRecordStateClickRecord;
        [self addSubview:stateView];
        _stateView = stateView;
    }
    return  _stateView;
}

- (CWVoiceButton *)recordButton {
    if (_recordButton == nil) {
        CWVoiceButton *btn = [CWVoiceButton buttonWithBackImageNor:@"aio_record_being_button" backImageSelected:@"aio_record_being_button" imageNor:@"aio_record_start_nor" imageSelected:@"aio_record_stop_nor" frame:CGRectMake(0, self.stateView.cw_bottom, 0, 0) isMicPhone:YES];
        [btn addTarget:self action:@selector(startRecorde:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.cw_centerX = self.cw_width / 2.0;
        [self addSubview:btn];
        _recordButton = btn;
    }
    return _recordButton;
}

- (void)startRecorde:(CWVoiceButton *)btn {
    // 设置状态 隐藏小圆点和三个标签
    [(CWVoiceView *)self.superview.superview setState:CWVoiceStateRecord];
    btn.selected = !btn.selected;
    if (btn.selected) {
        [CWRecorder shareInstance].delegate = self;
        NSString *filePath = [CWFlieManager filePath];
        NSLog(@"--------------%@",filePath);
//        NSString *path = [CWDocumentPath stringByAppendingPathComponent:@"test.wav"];
        //        @"/Users/chavez/Desktop/test.wav"
        [[CWRecorder shareInstance] beginRecordWithRecordPath:filePath];
        
        _record_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_record_timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_record_timer, ^{
            NSInteger recordtime = [self.stateView recordduration];
            if (recordtime >= LIMIT_RECORD_DURATION) {
                [self disposerecordtimer];
                [[CWRecorder shareInstance] endRecord];
                [self.stateView endRecord];
                self.stateView.recordState = CWRecordStateClickRecord;
                self.playView = nil;
                [self playView];
            }
        });
        dispatch_resume(_record_timer);
        
    }else {
        [self disposerecordtimer];
        [[CWRecorder shareInstance] endRecord];
        [self.stateView endRecord];
        self.stateView.recordState = CWRecordStateClickRecord;
        self.playView = nil;
        [self playView];
    }
}

#pragma mark - CWRecorderDelegate
- (void)recorderPrepare {
    //    NSLog(@"准备中......");
    self.stateView.recordState = CWRecordStatePrepare;
}

- (void)recorderRecording {
    self.stateView.recordState = CWRecordStateRecording;
    // 设置状态view开始录音
    [self.stateView beginRecord];
}

- (void)recorderFailed:(NSString *)failedMessage {
    self.stateView.recordState = CWRecordStateClickRecord;
    NSLog(@"失败：%@",failedMessage);
    [QMUITips showError:@"开始录音时遇未明错误，请检查麦克风是否正常可用，并重试。" inView:self hideAfterDelay:3];
}

@end

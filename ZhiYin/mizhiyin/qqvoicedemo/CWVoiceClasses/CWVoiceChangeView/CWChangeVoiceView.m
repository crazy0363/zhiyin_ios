//
//  CWChangeVoiceView.m
//  QQVoiceDemo
//
//  Created by chavez on 2017/10/11.
//  Copyright © 2017年 陈旺. All rights reserved.
//

#import "CWChangeVoiceView.h"
#import "CWRecordStateView.h"
#import "CWVoiceButton.h"
#import "UIView+CWChat.h"
#import "CWRecorder.h"
#import "CWVoiceView.h"
#import "CWVoiceChangePlayView.h"
#import "CWFlieManager.h"
#import <QMUIKit/QMUIKit.h>
#import "globalvar.h"
//----------------------变声界面---------------------------------//

@interface CWChangeVoiceView()<CWRecorderDelegate>
{
    dispatch_source_t _record_timer;
    BOOL _recordtimeout;
}

@property (nonatomic, weak) CWRecordStateView *stateView;
@property (nonatomic, weak) UIButton *voiceChangeBtn;    // 录音按钮
@property (nonatomic,weak) CWVoiceChangePlayView *playView;

@end

#define LIMIT_RECORD_DURATION 90

@implementation CWChangeVoiceView

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
    [self voiceChangeBtn];
//    [self playView];
    
    [[NSNotificationCenter defaultCenter]addObserver: self
                                             selector: @selector(plyaviewdisappear:)
                                                 name: disapper_notify
                                               object: nil];
}

-(void)plyaviewdisappear:(id)param {
    self.stateView.recordState = CWRecordStateTouchChangeVoice;
}

#pragma mark - subviews
- (CWVoiceChangePlayView *)playView {
    if (_playView == nil) {
        CWVoiceChangePlayView *playView = [[CWVoiceChangePlayView alloc] initWithFrame:self.bounds];
        [(CWVoiceView *)self.superview.superview setState:CWVoiceStatePlay];
        [UIView transitionWithView:self duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self addSubview:playView];
        } completion:nil];
        self.playView = playView;
    }
    return _playView;
}

- (CWRecordStateView *)stateView {
    if (_stateView == nil) {
        CWRecordStateView *stateView = [[CWRecordStateView alloc] initWithFrame:CGRectMake(0, 10, self.cw_width, 50)];
        stateView.recordState = CWRecordStateTouchChangeVoice;
        [self addSubview:stateView];
        _stateView = stateView;
    }
    return  _stateView;
}

- (UIButton *)voiceChangeBtn {
    if (_voiceChangeBtn == nil) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"aio_voiceChange_icon"] forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, self.stateView.cw_bottom, btn.currentImage.size.width, btn.currentImage.size.height);
        // 手指按下
        [btn addTarget:self action:@selector(startRecorde:) forControlEvents:UIControlEventTouchDown];
        // 松开手指
        [btn addTarget:self action:@selector(endRecord:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(endRecord:) forControlEvents:UIControlEventTouchUpOutside];
        
        btn.cw_centerX = self.cw_width / 2.0;
        btn.cw_centerY = self.cw_height - btn.currentImage.size.height/2;
        [self addSubview:btn];
        _voiceChangeBtn = btn;
    }
    return _voiceChangeBtn;
}

#pragma mark - button events
- (void)startRecorde:(UIButton *)btn {
    _recordtimeout = NO;
    [CWRecorder shareInstance].delegate = self;
    // 设置状态 隐藏小圆点和三个标签
    [(CWVoiceView *)self.superview.superview setState:CWVoiceStateRecord];
    __weak __typeof(self) weakSelf = self;
    [self animationMicBtn:^(BOOL finished) {
        NSString *filePath = [CWFlieManager filePath];
        [[CWRecorder shareInstance] beginRecordWithRecordPath:filePath];
        
        __strong __typeof(weakSelf) _self = weakSelf;
        _self->_record_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_self->_record_timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_self->_record_timer, ^{
            NSInteger recordtime = [self.stateView recordduration];
            // 录制结束出口一：超时
            if (recordtime >= LIMIT_RECORD_DURATION) {
                _self->_recordtimeout = YES;
                [self disposerecordtimer];
                [[CWRecorder shareInstance] endRecord];
                [self.stateView endRecord];
                self.stateView.recordState = CWRecordStateTouchChangeVoice;
                [(CWVoiceView *)self.superview.superview setState:CWVoiceStateDefault];
                self.playView = nil;
                [self playView];
            }
        });
        dispatch_resume(_self->_record_timer);
    }];

}

// 录制结束出口二：松开
- (void)endRecord:(UIButton *)btn {
    NSInteger cost = [self.stateView recordduration];
    [self disposerecordtimer];
    if (_recordtimeout) {
        NSLog(@"record timeout");
        return;
    }
    
    NSTimeInterval t = 0;
    if (![CWRecorder shareInstance].isRecording) {
        t = 0.3;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(t * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
//        self.stateView.recordState = CWRecordStateTouchChangeVoice; // 切换状态为按住变声
        [[CWRecorder shareInstance] endRecord];  // 停止录音
        [self.stateView endRecord];    // stateview的动画停止
        // 设置状态 显示小圆点和三个标签
        [(CWVoiceView *)self.superview.superview setState:CWVoiceStateDefault];
        if (t == 0 && cost >= 3) {
            NSLog(@"跳转到变声界面");
            self.playView = nil;
            [self playView];
        }else {
            NSLog(@"录音时间太短");
            self.stateView.recordState = CWRecordStateTouchChangeVoice; // 切换状态为按住变声
            [QMUITips showInfo:@"真是惜字如金，再多说两句好吗？请不要短于三秒" inView:[globalvar shareglobalvar].mizhiyinvc.view hideAfterDelay:3];
        }
    });
    
}

#pragma mark - button animation
- (void)animationMicBtn:(void(^)(BOOL finished))completion {
    [UIView animateWithDuration:0.10 animations:^{
        self.voiceChangeBtn.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.05 animations:^{
            self.voiceChangeBtn.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
        
    }];
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
    self.stateView.recordState = CWRecordStateTouchChangeVoice;
    NSLog(@"失败：%@",failedMessage);
    [QMUITips showError:@"开始录音时遇未明错误，请检查麦克风是否正常可用，并重试。" inView:self hideAfterDelay:3];
}

@end

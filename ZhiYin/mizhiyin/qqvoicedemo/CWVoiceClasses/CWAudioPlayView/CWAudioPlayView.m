//
//  CWAudioPlayView.m
//  QQVoiceDemo
//
//  Created by 陈旺 on 2017/10/4.
//  Copyright © 2017年 陈旺. All rights reserved.
//

#import "CWAudioPlayView.h"
#import "UIView+CWChat.h"
#import "CWRecordStateView.h"
#import "CWAudioPlayer.h"
#import "CWRecordModel.h"
#import "CWRecorder.h"
#import "CWVoiceView.h"
#import <QMUIKit/QMUIKit.h>
#import "globalvar.h"
#import <AFHTTPSessionManager+Synchronous.h>
#import "zyprotocol.h"
#import "CWFlieManager.h"
#import "Tianyavc.h"

@interface CWAudioPlayView ()

@property (nonatomic, weak) CWRecordStateView *stateView;

@property (nonatomic, weak) UIButton *playButton;   // 播放按钮
@property (nonatomic, weak) UIButton *cancelButton; // 取消按钮
@property (nonatomic, weak) UIButton *sendButton;   // 发送按钮
@property(nonatomic, strong)TPAACAudioConverter* audioconverter;

@end



@implementation CWAudioPlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        _progressValue = 0.8;
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    
    self.backgroundColor = [UIColor whiteColor];
    [self stateView];
    [self playButton];
    [self setupSendButtonAndCancelButton];
    [self listenProgress]; // 监听进度
}

#pragma mark - subviews
- (UIButton *)playButton {
    if (_playButton == nil) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"aio_record_play_nor"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"aio_record_play_press"] forState:UIControlStateHighlighted];
        [btn setImage:[UIImage imageNamed:@"aio_record_stop_nor"] forState:UIControlStateSelected];
        UIImage *image = [UIImage imageNamed:@"aio_voice_button_nor"];
        btn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        btn.center = CGPointMake(self.center.x, self.stateView.cw_bottom + image.size.width / 2);
        [btn addTarget:self action:@selector(playRecord) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        _playButton = btn;
    }
    return _playButton;
}

- (CWRecordStateView *)stateView {
    if (_stateView == nil) {
        CWRecordStateView *stateView = [[CWRecordStateView alloc] initWithFrame:CGRectMake(0, 10, self.cw_width, 50)];
        [self addSubview:stateView];
        stateView.recordState = CWRecordStatePreparePlay;
        _stateView = stateView;
    }
    return  _stateView;
}

- (void)setupSendButtonAndCancelButton {
    CGFloat height = 40;
    UIButton *returnbtn = [self buttonWithFrame:CGRectMake(0, self.cw_height - height, self.cw_width / 2.0, height) title:@"放弃并返回" titleColor:kSelectBackGroudColor font:[UIFont systemFontOfSize:18] backImageNor:@"aio_record_cancel_button" backImageHighled:@"aio_record_cancel_button_press" sel:@selector(btnClick:)];
    [self addSubview:returnbtn];
    self.cancelButton = returnbtn;
    
    UIButton *sendBtn = [self buttonWithFrame:CGRectMake(self.cw_width / 2.0, self.cw_height - height, self.cw_width / 2.0, height) title:@"马上发送" titleColor:kSelectBackGroudColor font:[UIFont systemFontOfSize:18] backImageNor:@"aio_record_send_button" backImageHighled:@"aio_record_send_button_press" sel:@selector(btnClick:)];
    [self addSubview:sendBtn];
    self.sendButton = sendBtn;
    
}

- (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font backImageNor:(NSString *)backImageNor backImageHighled:(NSString *)backImageHighled sel:(SEL)sel{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    btn.titleLabel.font = font;
    UIImage *newImageNor = [[UIImage imageNamed:backImageNor] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    UIImage *newImageHighled = [[UIImage imageNamed:backImageHighled] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    [btn setBackgroundImage:newImageNor forState:UIControlStateNormal];
    [btn setBackgroundImage:newImageHighled forState:UIControlStateHighlighted];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

#pragma mark - play/stop
- (void)playRecord {
    self.playButton.selected = !self.playButton.selected;
    if (self.playButton.selected) {
        self.stateView.recordState = CWRecordStatePlay;
        [[CWAudioPlayer shareInstance] playAudioWith:[CWRecordModel shareInstance].path];
    }else {
        [self stopPlay];
    }
}

- (void)stopPlay {
    self.playButton.selected = NO;
    self.stateView.recordState = CWRecordStatePreparePlay;
    [[CWAudioPlayer shareInstance] stopCurrentAudio];
    _progressValue = 0;
    [self setNeedsDisplay];
    [self layoutIfNeeded];
}

// 发送出口一：成功转成aac，并发送完毕（成功或失败）
- (BOOL)request_sendaudio {
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
//    manager.requestSerializer=[AFJSONRequestSerializer serializer];
//    NSString* requesturl = [zyprotocol_sendaudio sendaudio_url];
//    NSString* tpath = [NSString stringWithFormat:@"%@.m4a", [CWRecordModel shareInstance].path];
//    NSData* audiodata = [NSData dataWithContentsOfFile:tpath];
//    NSDictionary* param = [zyprotocol_sendaudio sendaudio_parame:audiodata audiolen:[self.stateView recordduration] towhere:[globalvar shareglobalvar].towhere otherid:[globalvar shareglobalvar].toclientid];
//    NSError *error = nil;
//    NSDictionary *result = [manager syncPOST:requesturl
//                                  parameters:param
//                                        task:NULL
//                                       error:&error];
//    protocol_sendaudio_info* sendaudioinfo = [zyprotocol_sendaudio token_response:result];
//    BOOL ret = NO;
//    if (sendaudioinfo.IsSuccess) {
//        NSLog(@"request sendaudio successful");
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [QMUITips hideAllTipsInView:[globalvar shareglobalvar].mizhiyinvc.view];
//            NSString* tips = @"已经发送到\"广场\"，可到\"寡人\"处查看发送记录或删除";
//            if ([globalvar shareglobalvar].towhere == 1) {
//                tips = [NSString stringWithFormat:@"已经发给\"%@\"，可到\"寡人\"处查看发送记录", [globalvar shareglobalvar].tonickname];
//            }
//            [QMUITips showSucceed:tips inView:[globalvar shareglobalvar].mizhiyinvc.view hideAfterDelay:3];
//            if ([globalvar shareglobalvar].towhere == 0) {
//                [(Tianyavc*)[globalvar shareglobalvar].taiyavc refresh_audiolist];
//            }
//
//            [(CWVoiceView *)self.superview.superview.superview setState:CWVoiceStateDefault];
//            [self removeFromSuperview];
//
//        });
//        ret = YES;
//    }
//    else {
//        NSLog(@"request sendaudio error");
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [QMUITips hideAllTipsInView:[globalvar shareglobalvar].mizhiyinvc.view];
//            [QMUITips showError:@"发送遇阻，请确保网络畅通，再来一次吧。" inView:[globalvar shareglobalvar].mizhiyinvc.view hideAfterDelay:3];
//
//            [(CWVoiceView *)self.superview.superview.superview setState:CWVoiceStateDefault];
//            [self removeFromSuperview];
//        });
//    }
//
//    [CWFlieManager removeFile:[CWRecordModel shareInstance].path];
//    [CWFlieManager removeFile:tpath];
//
//    return ret;
    return NO;
}

-(void)sendRecordfile {
    NSLog(@"send record, path:%@", [CWRecordModel shareInstance].path);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self request_sendaudio];
    });
}

- (void)btnClick:(UIButton *)btn {
//    NSLog(@"%@",btn.titleLabel.text);
    [self stopPlay];
    
    const int minsec = 2;
    BOOL shouldsend = YES;
    if ([self.stateView recordduration] < minsec) {
        [QMUITips showInfo:@"可以再多说两句吗？请不要短于两秒" inView:[globalvar shareglobalvar].mizhiyinvc.view hideAfterDelay:3];
        shouldsend = NO;
    }
    
    if (btn == self.sendButton && shouldsend) { // 发送
        // wav to aac
        NSString* tpath = [NSString stringWithFormat:@"%@.m4a", [CWRecordModel shareInstance].path];
        self.audioconverter = [[TPAACAudioConverter alloc]initWithDelegate:self source:[CWRecordModel shareInstance].path destination:tpath];
        [self.audioconverter start];
        [QMUITips showLoading:@"紧急发送中，请稍安勿躁" inView:[globalvar shareglobalvar].mizhiyinvc.view];
    }else {
        NSLog(@"取消并返回");
        [[CWRecorder shareInstance] deleteRecord];
        [CWFlieManager removeFile:[CWRecordModel shareInstance].path];
        [(CWVoiceView *)self.superview.superview.superview setState:CWVoiceStateDefault];
        [self removeFromSuperview];
    }
}

#pragma mark 监听环形进度条更新
- (void)listenProgress {
    __weak typeof(self) weakSelf = self;
    self.stateView.playProgress = ^(CGFloat progress) {
        if (progress == 1) {
            progress = 0;
            [weakSelf stopPlay];
        }
        weakSelf.progressValue = progress;
        [weakSelf setNeedsDisplay];
        [weakSelf layoutIfNeeded];
    };
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UIImage *image = [UIImage imageNamed:@"aio_voice_button_nor"];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, 2.0f);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColorFromRGBA(214, 219, 222, 1.0) CGColor]);
    CGContextAddArc(ctx, self.center.x, self.stateView.cw_bottom + image.size.width / 2, image.size.width / 2, 0, M_PI * 2, 0);
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [kSelectBackGroudColor CGColor]);
    CGFloat startAngle = -M_PI_2;
    CGFloat angle = self.progressValue * M_PI * 2;
    CGFloat endAngle = startAngle + angle;
    CGContextAddArc(ctx, self.center.x, self.stateView.cw_bottom + image.size.width / 2, image.size.width / 2, startAngle, endAngle, 0);
    CGContextStrokePath(ctx);
    
}

-(void)AACAudioConverter:(TPAACAudioConverter *)converter didMakeProgress:(float)progress {
    NSLog(@"convert progress: %f", progress);
}

-(void)AACAudioConverterDidFinishConversion:(TPAACAudioConverter *)converter {
    NSLog(@"convert finish");
    [self sendRecordfile];
}

// 发送出口二：转aac失败（不发送）
-(void)AACAudioConverter:(TPAACAudioConverter *)converter didFailWithError:(NSError *)error {
    NSLog(@"convert fail, %@", [error localizedDescription]);
    [QMUITips hideAllTipsInView:[globalvar shareglobalvar].mizhiyinvc.view];
    [QMUITips showError:@"压缩数据时遇挫，再来一次吧（或在\"寡人\"处投诉作者！）" inView:[globalvar shareglobalvar].mizhiyinvc.view hideAfterDelay:3];
    
    NSString* tpath = [NSString stringWithFormat:@"%@.m4a", [CWRecordModel shareInstance].path];
    [CWFlieManager removeFile:tpath];
    [CWFlieManager removeFile:[CWRecordModel shareInstance].path];
    [(CWVoiceView *)self.superview.superview.superview setState:CWVoiceStateDefault];
    [self removeFromSuperview];
}


@end

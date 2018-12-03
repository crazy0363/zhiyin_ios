//
//  CWVoiceChangePlayView.m
//  QQVoiceDemo
//
//  Created by chavez on 2017/10/11.
//  Copyright © 2017年 陈旺. All rights reserved.
//

#import "CWVoiceChangePlayView.h"
#import "UIView+CWChat.h"
#import "CWVoiceChangePlayCell.h"
#import "CWAudioPlayer.h"
#import "CWRecordModel.h"
#import "CWVoiceView.h"
#import "CWRecorder.h"
#import "CWFlieManager.h"
#import "zyprotocol.h"
#import <QMUIKit/QMUIKit.h>
#import "globalvar.h"
#import <AFHTTPSessionManager+Synchronous.h>
#import "Tianyavc.h"
#import "topicvc.h"

@interface CWVoiceChangePlayView()

@property (nonatomic, weak) UIButton *cancelButton; // 取消按钮
@property (nonatomic, weak) UIButton *sendButton;   // 发送按钮

@property (nonatomic,strong) CADisplayLink *playTimer;      // 播放时振幅计时器

@property (nonatomic,weak) CWVoiceChangePlayCell *playingView;

@property (nonatomic,strong) NSMutableArray *imageNames;

@property (nonatomic,weak) UIScrollView *contentScrollView;

@property(nonatomic, strong)TPAACAudioConverter* audioconverter;

@property(nonatomic, strong)UILabel* infoshow;
@end

@implementation CWVoiceChangePlayView

NSString* disapper_notify = @"playview_disappear_notify";

#pragma mark - lazyLoad
- (NSMutableArray *)imageNames {
    if (_imageNames == nil) {
        _imageNames = [NSMutableArray array];
        for (int i = 0; i < 6; i++) {
            [_imageNames addObject:[NSString stringWithFormat:@"aio_voiceChange_effect_%d",i]];
        }
    }
    return _imageNames;
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
    [self setupContentScrollView];
    [self setupSendButtonAndCancelButton];
}
#pragma mark - setupUI
- (void)setupContentScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.bounces = YES;
    scrollView.cw_height = scrollView.cw_height - 40;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.frame = CGRectMake(scrollView.frame.origin.x,scrollView.frame.origin.y+40,scrollView.frame.size.width, scrollView.frame.size.height);
    [self addSubview:scrollView];
    self.contentScrollView = scrollView;
    
    self.infoshow = [[UILabel alloc]qmui_initWithFont:[UIFont systemFontOfSize:15] textColor:[UIColor grayColor]];
    self.infoshow.text = @"变音为：原声";
    self.infoshow.frame = CGRectMake(0,0,self.cw_width,20);
    self.infoshow.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.infoshow];
    
    NSArray *titles = @[@"原声",@"萝莉",@"大叔",@"惊悚",@"空灵",@"搞怪"];
    CGFloat width = self.cw_width / 4;
    CGFloat height = width + 10;
    __weak typeof(self) weakSelf = self;
    for (int i = 0; i < self.imageNames.count; i++) {
        CWVoiceChangePlayCell *cell = [[CWVoiceChangePlayCell alloc] initWithFrame:CGRectMake(i%4 * width, i / 4 * height, width, height)];
        cell.center = scrollView.center;
        cell.imageName = self.imageNames[i];
        cell.title = titles[i];
        [self.contentScrollView addSubview:cell];
        [UIView animateWithDuration:0.25 animations:^{
            cell.frame = CGRectMake(i%4 * width, i / 4 * height, width, height);
        } completion:^(BOOL finished) {
            cell.frame = CGRectMake(i%4 * width, i / 4 * height, width, height);
        }];
        cell.playRecordBlock = ^(CWVoiceChangePlayCell *cellBlock) {
            [weakSelf.playTimer invalidate];
            if (weakSelf.playingView != cellBlock) {
                [weakSelf.playingView endPlay];
            }
            [cellBlock playingRecord];
            weakSelf.playingView = cellBlock;
            [weakSelf startPlayTimer];
            
            NSString* infotext = [NSString stringWithFormat:@"变音为：%@", cellBlock.title];
            self.infoshow.text = infotext;
        };
        cell.endPlayBlock = ^(CWVoiceChangePlayCell *cellBlock) {
            [weakSelf.playTimer invalidate];
            [cellBlock endPlay];
        };
        if (i == self.imageNames.count - 1) {
            CGFloat h = i / 4 * height;
            if (h < self.cw_height - self.cancelButton.cw_height) h = self.cw_height - self.cancelButton.cw_height + 1;
            self.contentScrollView.contentSize = CGSizeMake(0, h);
        }
    }
    
}


- (void)setupSendButtonAndCancelButton {
    CGFloat height = 30;
    UIButton *cancelBtn = [self buttonWithFrame:CGRectMake(0, self.cw_height - height, self.cw_width / 2.0, height) title:@"重 说" titleColor:kSelectBackGroudColor font:[UIFont systemFontOfSize:18] backImageNor:@"aio_record_cancel_button" backImageHighled:@"aio_record_cancel_button_press" sel:@selector(btnClick:)];
    [self addSubview:cancelBtn];
    self.cancelButton = cancelBtn;
    
    UIButton *sendBtn = [self buttonWithFrame:CGRectMake(self.cw_width / 2.0, self.cw_height - height, self.cw_width / 2.0, height) title:@"发 送" titleColor:kSelectBackGroudColor font:[UIFont systemFontOfSize:18] backImageNor:@"aio_record_send_button" backImageHighled:@"aio_record_send_button_press" sel:@selector(btnClick:)];
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

#pragma mark - playTimer
- (void)startPlayTimer {
//    _allCount = self.allLevels.count;
    [self.playTimer invalidate];
    self.playTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updatePlayMeter)];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] > 10.0) {
        self.playTimer.preferredFramesPerSecond = 10;
    }else {
        self.playTimer.frameInterval = 6;
    }
    [self.playTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updatePlayMeter {
    [self.playingView updateLevels];
}

- (void)stopPlay {
    [[CWAudioPlayer shareInstance] stopCurrentAudio];
}

- (void)btnClick:(UIButton *)btn {
    //    NSLog(@"%@",btn.titleLabel.text);
    
    [self stopPlay];
    if (btn == self.sendButton) { // 发送
        if ([globalvar shareglobalvar].towhere == TO_WHERE_UNKNOWN) {
            [QMUITips showInfo:@"请先选择发往何处，点击上方的圆圈即可" inView:[globalvar shareglobalvar].mizhiyinvc.view hideAfterDelay:3];
            return;
        }
        // wav to aac
        NSString* pathtem = self.playingView.voicePath;
        if ([pathtem length] <= 0) {
            pathtem = [CWRecordModel shareInstance].path;
        }
        NSString* tpath = [NSString stringWithFormat:@"%@.m4a", pathtem];
        self.audioconverter = [[TPAACAudioConverter alloc]initWithDelegate:self source:pathtem destination:tpath];
        [self.audioconverter start];
        [QMUITips showLoading:@"紧急发送中，请稍安勿躁" inView:[globalvar shareglobalvar].mizhiyinvc.view];
    }else {
        NSLog(@"取消并返回");
        [[CWRecorder shareInstance] deleteRecord]; // 会删除录音文件
        [CWFlieManager removeFile:self.playingView.voicePath];
        
        [(CWVoiceView *)self.superview.superview.superview setState:CWVoiceStateDefault];
        [UIView transitionWithView:self duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self removeFromSuperview];
        } completion:nil];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:disapper_notify object:nil];
    }
}

// 发送出口一：成功转成aac，并发送完毕（成功或失败）
- (BOOL)request_sendaudio {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    NSString* requesturl = [zyprotocol_sendaudio sendaudio_url];
    NSString* pathtem = self.playingView.voicePath;
    if ([pathtem length] <= 0) {
        pathtem = [CWRecordModel shareInstance].path;
    }
    NSString* tpath = [NSString stringWithFormat:@"%@.m4a", pathtem];
    NSData* audiodata = [NSData dataWithContentsOfFile:tpath];
    NSString* otherid = [globalvar shareglobalvar].toclientid;
    if ([globalvar shareglobalvar].towhere == TO_WHERE_TOPIC ||
        [globalvar shareglobalvar].towhere == TO_WHERE_TIANYA_TOPIC) {
        otherid = [globalvar shareglobalvar].topicid;
    }
    NSDictionary* param = [zyprotocol_sendaudio sendaudio_parame:audiodata audiolen:[CWRecordModel shareInstance].duration towhere:[globalvar shareglobalvar].towhere otherid:otherid];
    NSError *error = nil;
    NSDictionary *result = [manager syncPOST:requesturl
                                  parameters:param
                                        task:NULL
                                       error:&error];
    protocol_sendaudio_info* sendaudioinfo = [zyprotocol_sendaudio token_response:result];
    BOOL ret = NO;
    if (sendaudioinfo.IsSuccess) {
        NSLog(@"request sendaudio successful");
        dispatch_sync(dispatch_get_main_queue(), ^{
            [QMUITips hideAllTipsInView:[globalvar shareglobalvar].mizhiyinvc.view];
            NSString* tips = @"已经发送到\"广场\"，可到\"寡人\"处查看发送记录或删除";
            if ([globalvar shareglobalvar].towhere == TO_WHERE_SOMEONE) {
                tips = [NSString stringWithFormat:@"已经发给\"%@\"，可到\"寡人\"处查看发送记录", [globalvar shareglobalvar].tonickname];
            }
            else if ([globalvar shareglobalvar].towhere == TO_WHERE_TOPIC) {
                tips = @"已经发送到\"今日话题\"，可到\"寡人\"处查看发送记录或删除";
            }
            else if ([globalvar shareglobalvar].towhere == TO_WHERE_TIANYA_TOPIC) {
                tips = @"已经发送到\"广场\"与\"今日话题\"，可到\"寡人\"处查看发送记录或删除";
            }
            [QMUITips showSucceed:tips inView:[globalvar shareglobalvar].mizhiyinvc.view hideAfterDelay:3];
            if ([globalvar shareglobalvar].towhere == TO_WHERE_TIANYA) {
                [(Tianyavc*)[globalvar shareglobalvar].taiyavc refresh_audiolist];
            }
            else if ([globalvar shareglobalvar].towhere == TO_WHERE_TOPIC) {
                [(topicvc*)[globalvar shareglobalvar].topicvc refresh_audiolist];
            }
            else if ([globalvar shareglobalvar].towhere == TO_WHERE_TIANYA_TOPIC) {
                [(Tianyavc*)[globalvar shareglobalvar].taiyavc refresh_audiolist];
                [(topicvc*)[globalvar shareglobalvar].topicvc refresh_audiolist];
            }
            
            [(CWVoiceView *)self.superview.superview.superview setState:CWVoiceStateDefault];
            [UIView transitionWithView:self duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self removeFromSuperview];
            } completion:nil];
            
        });
        ret = YES;
    }
    else {
        NSLog(@"request sendaudio error");
        dispatch_sync(dispatch_get_main_queue(), ^{
            [QMUITips hideAllTipsInView:[globalvar shareglobalvar].mizhiyinvc.view];
            [QMUITips showError:@"发送遇阻，请确保网络畅通，再来一次吧。" inView:[globalvar shareglobalvar].mizhiyinvc.view hideAfterDelay:3];
            
            [(CWVoiceView *)self.superview.superview.superview setState:CWVoiceStateDefault];
            [UIView transitionWithView:self duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self removeFromSuperview];
            } completion:nil];
        });
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:disapper_notify object:nil];
    });
    
    [CWFlieManager removeFile:tpath];
    [CWFlieManager removeFile:[CWRecordModel shareInstance].path];
    [CWFlieManager removeFile:self.playingView.voicePath];

    
    return ret;
}

-(void)sendRecordfile {
    NSLog(@"send record, path:%@", self.playingView.voicePath);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self request_sendaudio];
    });
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
    
    NSString* tpath = [NSString stringWithFormat:@"%@.m4a", self.playingView.voicePath];
    [CWFlieManager removeFile:tpath];
    [CWFlieManager removeFile:[CWRecordModel shareInstance].path];
    [CWFlieManager removeFile:self.playingView.voicePath];
    [(CWVoiceView *)self.superview.superview.superview setState:CWVoiceStateDefault];
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter]postNotificationName:disapper_notify object:nil];
}


@end

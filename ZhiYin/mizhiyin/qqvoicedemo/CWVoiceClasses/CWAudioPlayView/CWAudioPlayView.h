//
//  CWAudioPlayView.h
//  QQVoiceDemo
//
//  Created by 陈旺 on 2017/10/4.
//  Copyright © 2017年 陈旺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPAACAudioConverter.h"

@interface CWAudioPlayView : UIView<TPAACAudioConverterDelegate>

@property (nonatomic,assign) CGFloat progressValue;

@end

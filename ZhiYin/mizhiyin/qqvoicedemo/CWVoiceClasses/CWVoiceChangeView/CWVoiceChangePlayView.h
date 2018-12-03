//
//  CWVoiceChangePlayView.h
//  QQVoiceDemo
//
//  Created by chavez on 2017/10/11.
//  Copyright © 2017年 陈旺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPAACAudioConverter.h"

extern NSString* disapper_notify;

@interface CWVoiceChangePlayView : UIView<TPAACAudioConverterDelegate>

@end

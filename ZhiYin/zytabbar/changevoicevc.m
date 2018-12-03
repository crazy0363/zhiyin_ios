//
//  changevoicevc.m
//  ZhiYin
//
//  Created by pro on 2018/11/16.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "changevoicevc.h"
#import "CWVoiceChangePlayView.h"
#import "CWFlieManager.h"
#import <QMUIKit/QMUIKit.h>
#import "globalvar.h"

@interface changevoicevc ()

@end

@implementation changevoicevc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CWVoiceChangePlayView *playView = [[CWVoiceChangePlayView alloc] initWithFrame:self.voiceview.bounds];
    [self.voiceview addSubview:playView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  Mizhiyinvc.m
//  ZhiYin
//
//  Created by freejet on 2018/10/5.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "Mizhiyinvc.h"
#import "globalvar.h"
#import "CWVoiceView.h"
#import "UIView+CWChat.h"
#import "zyprotocol.h"

@interface Mizhiyinvc ()

@end

@implementation Mizhiyinvc

-(void)introlabelinfo {
    NSString* info = @"---------使用说明书---------\n\n1. 用声音，宣泄您的情绪，表明态度。\n\n2. 最长有90秒的录音时间。\n\n3. 吼几句熟悉的歌词；抱怨一下上司；大声说我要奋斗... \n\n4. 不要告诉别人您有千万身家，也不要说出密码跟隐私。\n\n5. 都是有身份证的人，请务必文明用语，勿发布不良信息。";
    self.introlabel.numberOfLines = 20;
    self.introlabel.text = info;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect rt = self.view.frame;
    float xscal = [globalvar shareglobalvar].autoSizeScaleX;
    float yscal = [globalvar shareglobalvar].autoSizeScaleY;
    CGRect rtfit = CGRectMake(rt.origin.x*xscal, rt.origin.y*yscal, rt.size.width*xscal, rt.size.height*yscal);
    self.view.frame = rtfit;
    
    self.recordview.backgroundColor = [UIColor blueColor];
    CWVoiceView *view = [[CWVoiceView alloc] initWithFrame:CGRectMake(0, 0,self.recordview.cw_width, self.recordview.cw_height)];
    [self.recordview addSubview:view];
//    [self.view addSubview:view];
//    [self introlabelinfo];
    
    self.tianyabox.delegate = self;
    self.topicbox.delegate = self;
}

- (void)didTapCheckBox:(BEMCheckBox *)checkBox {
    if (checkBox == self.tianyabox) {
        NSLog(@"to tianya, %d", self.tianyabox.on);
    }
    else if (checkBox == self.topicbox) {
        NSLog(@"to topic, %d", self.topicbox.on);
    }
    BOOL istianya = self.tianyabox.on;
    BOOL istopic = self.topicbox.on;
    if (istianya && istopic) {
        [globalvar shareglobalvar].towhere = TO_WHERE_TIANYA_TOPIC;
    }
    else if (istianya) {
        [globalvar shareglobalvar].towhere = TO_WHERE_TIANYA;
    }
    else if (istopic) {
        [globalvar shareglobalvar].towhere = TO_WHERE_TOPIC;
    }
    else {
        [globalvar shareglobalvar].towhere = TO_WHERE_UNKNOWN;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    if ([globalvar shareglobalvar].towhere == TO_WHERE_SOMEONE) {
        NSString* info = [NSString stringWithFormat:@"寡人的语音将发给%@。", [globalvar shareglobalvar].tonickname];
        NSInteger nicklen = [[globalvar shareglobalvar].tonickname length];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:info];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,8)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(8,nicklen)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(8+nicklen,1)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(0, 8)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0] range:NSMakeRange(8, nicklen)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(8+nicklen, 1)];
        self.towherelabel.text = str;
        self.towhereview.hidden = YES;
    }
    else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"寡人的语音将发往："];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,9)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(0, 9)];
        self.towherelabel.text = str;
        self.towhereview.hidden = NO;
        if ([globalvar shareglobalvar].towhere == TO_WHERE_TOPIC) {
            self.topicbox.enabled = YES;
            self.topicbox.on = YES;
            self.tianyabox.on = NO;
        }
        else {
            if ([globalvar shareglobalvar].topicid) {
                self.topicbox.enabled = YES;
            }
            else {
                self.topicbox.enabled = NO;
            }
            self.topicbox.on = NO;
            self.tianyabox.on = YES;
            [globalvar shareglobalvar].towhere = TO_WHERE_TIANYA;
        }
    }
    [super viewDidAppear:animated];
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

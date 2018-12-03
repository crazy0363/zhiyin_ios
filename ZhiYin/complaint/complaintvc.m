//
//  complaintvc.m
//  ZhiYin
//
//  Created by pro on 2018/11/6.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "complaintvc.h"
#import "globalvar.h"
#import "zyprotocol.h"
#import <AFHTTPSessionManager+Synchronous.h>
#import <QMUIKit/QMUIKit.h>
#import "BlacklistM+CoreDataClass.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Tianyavc.h"
#import "topicvc.h"

@interface complaintvc ()
{
    NSInteger _comtype;
    NSInteger _vcindex;
}
@end

@implementation complaintvc

-(void)resetvc {
    if (_vcindex == TAB_INDEX_TAIYA) {
        [[globalvar shareglobalvar].tabbarcontroller resettianya];
    }
    else if (_vcindex == TAB_INDEX_RANK) {
        [[globalvar shareglobalvar].tabbarcontroller resetrank];
    }
    else if (_vcindex == TAB_INDEX_SEND_ME) {
        [[globalvar shareglobalvar].tabbarcontroller resetsendme];
    }
    else if (_vcindex == TAB_INDEX_TOPIC) {
        [[globalvar shareglobalvar].tabbarcontroller resettopic];
    }
    else {
        [[globalvar shareglobalvar].tabbarcontroller resettianya];
    }
}

-(BOOL)request_complaint:(NSString*)audioid comtype:(NSInteger)comtype reason:(NSString*)reason {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    NSString* url = [zyprotocol_complaint complaint_url];
    NSDictionary* param = [zyprotocol_complaint complaint_param:audioid complainttype:comtype reason:reason];
    NSError *error = nil;
    NSDictionary *result = [manager syncPOST:url
                                  parameters:param
                                        task:NULL
                                       error:&error];
//    protocol_complaint_info* retinfo = [zyprotocol_complaint token_response:result];
    BOOL ret = NO;
    if (result) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [QMUITips hideAllTipsInView:self.view];
            NSString* tips = @"已经收到您的举报信息，后台将进行审查，谢谢您的反馈";
            [QMUITips showSucceed:tips inView:self.view hideAfterDelay:3];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self resetvc];
            });
        });
        ret = YES;
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [QMUITips hideAllTipsInView:self.view];
            [QMUITips showError:@"发送遇阻，请确保网络畅通，再来一次吧。" inView:self.view hideAfterDelay:3];
        });
    }
    
    return ret;
}

-(BOOL)request_pushblack:(NSString*)userid nickname:(NSString*)nickname {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    NSString* url = [zyprotocol_pushblack pushblack_url];
    NSDictionary* param = [zyprotocol_pushblack pushblack_param:userid];
    NSError *error = nil;
    NSDictionary *result = [manager syncPOST:url
                                  parameters:param
                                        task:NULL
                                       error:&error];
    BOOL ret = NO;
    if (result) {
        // save balcklist
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            BlacklistM* item = [BlacklistM MR_findFirstByAttribute:@"userid" withValue:userid inContext:localContext];
            if (item) {
                [item MR_deleteEntityInContext:localContext];
            }
            item = [BlacklistM MR_createEntityInContext:localContext];
            item.userid = userid;
            item.nickname = nickname;
            [localContext MR_saveToPersistentStoreAndWait];
        } completion:^(BOOL success, NSError *error) {
            NSLog(@"magicalrecord add: %d, err:%@", success, error);
        }];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [QMUITips hideAllTipsInView:self.view];
            NSString* tips = @"已拉黑此人，可在\"寡人\"处解除拉黑";
            [QMUITips showSucceed:tips inView:self.view hideAfterDelay:3];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self resetvc];
            });
        });
        ret = YES;
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [QMUITips hideAllTipsInView:self.view];
            [QMUITips showError:@"发送遇阻，请确保网络畅通，再来一次吧。" inView:self.view hideAfterDelay:3];
        });
    }
    
    return ret;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString* info = [NSString stringWithFormat:@"这个语音来自于%@", self.nicknamefrom];
    NSInteger nicklen = [self.nicknamefrom length];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:info];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,7)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(7,nicklen)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(0, 7)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0] range:NSMakeRange(7, nicklen)];
    self.audiofrom.text = str;
    
    info = [NSString stringWithFormat:@"忍无可忍，寡人要拉黑%@", self.nicknamefrom];
    str = [[NSMutableAttributedString alloc] initWithString:info];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,10)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(10,nicklen)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11.0] range:NSMakeRange(0, 10)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0] range:NSMakeRange(10, nicklen)];
    self.pushblacklabel.text = str;
    
    self.blackintro.text = @"* 拉黑此人后，将不再收到TA的任何语音信息\n* 拉黑后，在语音页面下拉刷新，让TA消失\n* 可在\"寡人\"处解除拉黑";
    self.blackintro.numberOfLines = 3;
    
    [self.returnbtn setImage:[UIImage imageNamed:@"me_returnbtn"] forState:UIControlStateNormal];
    [self.returnbtn addTarget:self action:@selector(returnaction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.sendcomplaint setImage:[UIImage imageNamed:@"complaint_complaint"] forState:UIControlStateNormal];
    [self.sendcomplaint addTarget:self action:@selector(sendcomplaint:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendblack setImage:[UIImage imageNamed:@"complaint_pushblack"] forState:UIControlStateNormal];
    [self.sendblack addTarget:self action:@selector(sendblack:) forControlEvents:UIControlEventTouchUpInside];
    
    _comtype = 1;
}

- (void)sendcomplaint:(UIButton *)sender {
    NSLog(@"sendcomplaint");
    [QMUITips showLoading:@"紧急发送中，请稍安勿躁" inView:self.view];
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong __typeof(weakSelf) _self = weakSelf;
        [self request_complaint:_self.audioid comtype:_self->_comtype reason:@""];
    });
}

-(void)pushblacklist:(NSString*)userid nickname:(NSString*)nickname {
    // save balcklist
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        BlacklistM* item = [BlacklistM MR_findFirstByAttribute:@"userid" withValue:userid inContext:localContext];
        if (item) {
            [item MR_deleteEntityInContext:localContext];
        }
        item = [BlacklistM MR_createEntityInContext:localContext];
        item.userid = userid;
        item.nickname = nickname;
        NSLog(@"userid:%@, nickname:%@", item.userid, item.nickname);
        [localContext MR_saveToPersistentStoreAndWait];
    } completion:^(BOOL success, NSError *error) {
        NSLog(@"magicalrecord add: %d, err:%@", success, error);
    }];
    NSString* tips = @"已拉黑此人，可在\"寡人\"处解除拉黑";
    [QMUITips showSucceed:tips inView:self.view hideAfterDelay:3];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self resetvc];
        [(Tianyavc*)[globalvar shareglobalvar].taiyavc refresh_audiolist];
        [(topicvc*)[globalvar shareglobalvar].topicvc refresh_audiolist];
    });
}

- (void)sendblack:(UIButton *)sender {
    NSLog(@"sendblack");
//    [QMUITips showLoading:@"紧急发送中，请稍安勿躁" inView:self.view];
//    __weak __typeof(self) weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        __strong __typeof(weakSelf) _self = weakSelf;
//        [self request_pushblack:_self.userid nickname:_self.nicknamefrom];
//    });
    [self pushblacklist:self.userid nickname:self.nicknamefrom];
}

- (IBAction)onRadioBtn:(RadioButton *)sender {
    NSInteger type = 5;
    if (sender == self.radioButton1) {
        type =1;
    }
    else if (sender == self.radioButton2) {
        type=2;
    }
    else if (sender == self.radioButton3) {
        type=3;
    }
    else if (sender == self.radioButton4) {
        type=4;
    }
    else if (sender == self.radioButton5) {
        type=5;
    }
    _comtype = type;
    NSLog(@"complaint type:%d", (int)type);
    
}

-(void)returnaction:(UIButton*)btn {
    [self resetvc];
}

-(void)complaint_who:(NSString*)userid nickname:(NSString*)nicknamefrom audioid:(NSString*)audioid onvcindex:(NSInteger)vcindex {
    self.nicknamefrom = nicknamefrom;
    self.audioid = audioid;
    self.userid = userid;
    _vcindex = vcindex;
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

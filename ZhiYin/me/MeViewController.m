//
//  MeViewController.m
//  ZhiYin
//
//  Created by pro on 2018/9/26.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "MeViewController.h"
#import "globalvar.h"
#import "AppDelegate.h"
#import "zhiyiaboutvc.h"
#import "isendvc.h"
#import "sendmevc.h"
#import "blacklistvc.h"

@interface MeViewController ()

@end

@implementation MeViewController

-(void)setnickinfo {
    if ([globalvar shareglobalvar].nickname) {
        self.nickinfo.text = @"您是一个有身份的人，您的大号是：";
        self.nickinfo.numberOfLines = 1;
        self.nickinfo.textColor = [UIColor grayColor];
        self.nickname.text = [globalvar shareglobalvar].nickname;
        self.nickname.font = [UIFont systemFontOfSize:20];
        self.nickname.textColor = [UIColor blueColor];
        self.nickname.textAlignment = NSTextAlignmentCenter;
    }
    else {
        self.nickinfo.text = @"您是一个有身份的人，但您的大号还在更新的路上（努力更新中，请保持网络畅通）...";
        self.nickinfo.textColor = [UIColor grayColor];
        self.nickinfo.numberOfLines = 2;
        
        dispatch_source_t nickname_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        dispatch_source_set_timer(nickname_timer, DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
        dispatch_source_set_event_handler(nickname_timer, ^{
            if ([globalvar shareglobalvar].nickname) {
                dispatch_source_cancel(nickname_timer);
                dispatch_async(dispatch_get_main_queue(), ^{
                                   [self setnickinfo];
                               });
            }
        });
        dispatch_resume(nickname_timer);
    }
}

-(void)settableview {
    self.metableview.delegate = self;
    self.metableview.dataSource = self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 50;
    UIImage* image = [UIImage imageNamed:@"respose"]; // 48*48
    if (image) {
        UIImageView* view = [[UIImageView alloc]initWithImage:image];
        height = view.qmui_width * 2.5;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSString* cellid = [NSString stringWithFormat:@"cell%d_%d", (int)indexPath.section, (int)indexPath.row];
            QMUITableViewCell* cell = [[QMUITableViewCell alloc]initForTableView:tableView withStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.imageView.image = [UIImage imageNamed:@"me_isend"];
            cell.textLabel.text = @"寡人语录";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else if (indexPath.row == 1) {
            NSString* cellid = [NSString stringWithFormat:@"cell%d_%d", (int)indexPath.section, (int)indexPath.row];
            QMUITableViewCell* cell = [[QMUITableViewCell alloc]initForTableView:tableView withStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            if ([globalvar shareglobalvar].newmsg_sendtome) {
                cell.imageView.image = [UIImage imageNamed:@"me_sendtome_red"];
            }
            else {
                cell.imageView.image = [UIImage imageNamed:@"me_sendtome"];
            }
            cell.textLabel.text = @"有事启奏";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else if (indexPath.row == 2) {
            // blacklist
            NSString* cellid = [NSString stringWithFormat:@"cell%d_%d", (int)indexPath.section, (int)indexPath.row];
            QMUITableViewCell* cell = [[QMUITableViewCell alloc]initForTableView:tableView withStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.imageView.image = [UIImage imageNamed:@"complaint_pushblack"];
            cell.textLabel.text = @"禁言者";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else if (indexPath.row == 3) {
            // about zy
            NSString* cellid = [NSString stringWithFormat:@"cell%d_%d", (int)indexPath.section, (int)indexPath.row];
            QMUITableViewCell* cell = [[QMUITableViewCell alloc]initForTableView:tableView withStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.imageView.image = [UIImage imageNamed:@"me_about"];
            cell.textLabel.text = @"关于知音";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
    return nil;
}

-(void)newmsg_uiflag_hidden {
    UITabBarController* tbvc = [globalvar shareglobalvar].tabbarcontroller;
    [tbvc.tabBar hideBadgeOnItemIndex:TAB_INDEX_ME];
}

-(void)refreshtableview {
    [self.metableview reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // i send
            isendvc* vc = [[UIStoryboard storyboardWithName:@"isend" bundle:nil]instantiateViewControllerWithIdentifier:@"isendvc"];
            [[globalvar shareglobalvar].tabbarcontroller changevc_overme:vc title:@"寡人语录"];
        }
        else if (indexPath.row == 1) {
            // send to me
            [globalvar shareglobalvar].newmsg_sendtome = NO;
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
            [self newmsg_uiflag_hidden];
            sendmevc* vc = [[UIStoryboard storyboardWithName:@"sendmevc" bundle:nil]instantiateViewControllerWithIdentifier:@"sendmevc"];
            [[globalvar shareglobalvar].tabbarcontroller changevc_overme:vc title:@"有事启奏"];
        }
        else if (indexPath.row == 2) {
            // blacklist
            blacklistvc* vc = [[UIStoryboard storyboardWithName:@"blacklist" bundle:nil]instantiateViewControllerWithIdentifier:@"blacklist"];
            [[globalvar shareglobalvar].tabbarcontroller changevc_overme:vc title:@"小黑屋"];
        }
        else if (indexPath.row == 3) {
            // zhiyi about
            zhiyiaboutvc* aboutvc = [[UIStoryboard storyboardWithName:@"zhiyi_about" bundle:nil]instantiateViewControllerWithIdentifier:@"zhiyi_about"];
            [[globalvar shareglobalvar].tabbarcontroller changevc_overme:aboutvc title:@"关于知音"];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setnickinfo];
    [self settableview];
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

//
//  zhiyiaboutvc.m
//  ZhiYin
//
//  Created by pro on 2018/10/11.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "zhiyiaboutvc.h"
#import "globalvar.h"

@interface zhiyiaboutvc ()

@end

@implementation zhiyiaboutvc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.returnbtn setImage:[UIImage imageNamed:@"me_returnbtn"] forState:UIControlStateNormal];
    [self.returnbtn addTarget:self action:@selector(returnaction:) forControlEvents:UIControlEventTouchUpInside];
    [self settableview];
}

- (void)returnaction:(UIButton*)btn {
    [[globalvar shareglobalvar].tabbarcontroller resetmevc];
}

-(void)settableview {
    self.abouttableview.delegate = self;
    self.abouttableview.dataSource = self;
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
            cell.textLabel.text = @"给知音点个赞（点击跳转到APPStore）";
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else if (indexPath.row == 1) {
            NSString* cellid = [NSString stringWithFormat:@"cell%d_%d", (int)indexPath.section, (int)indexPath.row];
            QMUITableViewCell* cell = [[QMUITableViewCell alloc]initForTableView:tableView withStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.textLabel.text = @"官方网站（点击跳转）";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else if (indexPath.row == 2) {
            NSString* cellid = [NSString stringWithFormat:@"cell%d_%d", (int)indexPath.section, (int)indexPath.row];
            QMUITableViewCell* cell = [[QMUITableViewCell alloc]initForTableView:tableView withStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.textLabel.text = @"客服邮箱：crazy0363@126.com";
            return cell;
        }
        else if (indexPath.row == 3) {
            NSString* cellid = [NSString stringWithFormat:@"cell%d_%d", (int)indexPath.section, (int)indexPath.row];
            QMUITableViewCell* cell = [[QMUITableViewCell alloc]initForTableView:tableView withStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.textLabel.text = @"联系作者：（微信号）freeself0363";
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // to appstore
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1439297254"]];
            NSLog(@"to appstore");
        }
        else if (indexPath.row == 1) {
            NSLog(@"to myweb");
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://zyapi.alry.cn/index.html"]];
        }
        else if (indexPath.row == 2) {
            
        }
    }
}

@end

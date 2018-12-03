//
//  blacklistvc.m
//  ZhiYin
//
//  Created by pro on 2018/11/9.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "blacklistvc.h"
#import "globalvar.h"
#import <MagicalRecord/MagicalRecord.h>
#import "BlacklistM+CoreDataClass.h"
#import "blacklistcell.h"
#import "commom_utils.h"

@interface blacklistvc ()
@property(nonatomic, strong)NSMutableArray* blacklist;
@end

@implementation blacklistvc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.returnbtn setImage:[UIImage imageNamed:@"me_returnbtn"] forState:UIControlStateNormal];
    [self.returnbtn addTarget:self action:@selector(returnaction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.blacklisttv.delegate = self;
    self.blacklisttv.dataSource = self;
    self.infolable.text = @"以下黑名单中，是被您禁言的人，\n您可以解除禁言，从而收到TA的所有语音";
    self.infolable.numberOfLines = 2;
    
    // 没有数据的cell隐藏分隔线
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.blacklisttv.tableFooterView = view;
    
    self.blacklist = [NSMutableArray arrayWithCapacity:30];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray* items = [BlacklistM MR_findAllInContext:localContext];
        for (NSInteger i = 0; i < (NSInteger)[items count]; i ++) {
            blackiteminfo* info = [[blackiteminfo alloc]init];
            BlacklistM* item = (BlacklistM*)items[i];
            info.userid = item.userid;
            info.nickname = item.nickname;
            [self.blacklist addObject:info];
        }
    } completion:^(BOOL success, NSError *error) {
        // on ui
        [self.blacklisttv reloadData];
        NSLog(@"magicalrecord find: %d, err:%@", success, error);
    }];
}

- (void)returnaction:(UIButton*)btn {
    [[globalvar shareglobalvar].tabbarcontroller resetmevc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.blacklist count];
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
        blacklistcell* cell = [blacklistcell cellwithTableview:tableView];
        blackiteminfo* item = self.blacklist[indexPath.row];
        NSLog(@"cell:nickname=%@, useid=%@", item.nickname, item.userid);
        cell.nickname.text = item.nickname;
        [cell.outblacklist setImage:[UIImage imageNamed:@"complaint_unlock"] forState:UIControlStateNormal];
        [cell.outblacklist addTarget:self action:@selector(outblackaction:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    return nil;
}

-(void)outblackaction:(UIButton*)btn {
    NSIndexPath* ip =  [self.blacklisttv qmui_indexPathForRowAtView:btn];
    if (ip) {
        blackiteminfo* item = self.blacklist[ip.row];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            BlacklistM* i = [BlacklistM MR_findFirstByAttribute:@"userid" withValue:item.userid inContext:localContext];
            if (i) {
                [i MR_deleteEntityInContext:localContext];
                [localContext MR_saveToPersistentStoreAndWait];
                [self.blacklist removeObject:item];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.blacklisttv reloadData];
                });
            }
        } completion:^(BOOL success, NSError *error) {
            NSLog(@"magicalrecord delete: %d, err:%@", success, error);
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}



@end

//
//  blacklistcell.m
//  ZhiYin
//
//  Created by pro on 2018/11/9.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "blacklistcell.h"

@implementation blacklistcell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)cellwithTableview:(UITableView*)tableview {
    static NSString* idcell = @"blacklist_cell";
    blacklistcell* cell = [tableview dequeueReusableCellWithIdentifier:idcell];
    if (!cell) {
        cell = [[blacklistcell alloc]init];
    }
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

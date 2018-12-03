//
//  RanklistCell.m
//  ZhiYin
//
//  Created by pro on 2018/10/9.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "RanklistCell.h"

@implementation RanklistCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)cellwithTableview:(UITableView*)tableview {
    static NSString* idcell = @"ranklist_cell";
    RanklistCell* cell = [tableview dequeueReusableCellWithIdentifier:idcell];
    if (!cell) {
        cell = [[RanklistCell alloc]init];
    }
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

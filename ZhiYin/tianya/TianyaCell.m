//
//  TianyaCell.m
//  ZhiYin
//
//  Created by freejet on 2018/10/1.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "TianyaCell.h"

@implementation TianyaCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)cellwithTableview:(UITableView*)tableview {
    static NSString* idcell = @"tianya_cell";
    TianyaCell* cell = [tableview dequeueReusableCellWithIdentifier:idcell];
    if (!cell) {
        cell = [[TianyaCell alloc]init];
    }
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

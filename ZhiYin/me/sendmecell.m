//
//  sendmecell.m
//  ZhiYin
//
//  Created by freejet on 2018/10/11.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "sendmecell.h"

@implementation sendmecell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)cellwithTableview:(UITableView*)tableview {
    static NSString* idcell = @"sendme_cell";
    sendmecell* cell = [tableview dequeueReusableCellWithIdentifier:idcell];
    if (!cell) {
        cell = [[sendmecell alloc]init];
    }
    return cell;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

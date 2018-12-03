//
//  topiccell.m
//  ZhiYin
//
//  Created by pro on 2018/11/28.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "topiccell.h"

@implementation topiccell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)cellwithTableview:(UITableView*)tableview {
    static NSString* idcell = @"topic_cell";
    topiccell* cell = [tableview dequeueReusableCellWithIdentifier:idcell];
    if (!cell) {
        cell = [[topiccell alloc]init];
    }
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

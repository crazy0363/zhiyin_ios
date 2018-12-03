//
//  topiccell.h
//  ZhiYin
//
//  Created by pro on 2018/11/28.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface topiccell : UITableViewCell
@property(nonatomic, strong)IBOutlet UIImageView* play;
@property(nonatomic, strong)IBOutlet UILabel* nickname;
@property(nonatomic, strong)IBOutlet UILabel* duration;
@property(nonatomic, strong)IBOutlet UILabel* time;
@property(nonatomic, strong)IBOutlet UILabel* playcount;
@property(nonatomic, strong)IBOutlet UIButton* supportbtn;
@property(nonatomic, strong)IBOutlet UIButton* isaybtn;
@property(nonatomic, strong)IBOutlet UILabel* supportcount;
@property(nonatomic, strong)IBOutlet UIButton* complain_audio;

+(instancetype)cellwithTableview:(UITableView*)tableview;
@end

NS_ASSUME_NONNULL_END

//
//  isendcell.h
//  ZhiYin
//
//  Created by pro on 2018/10/11.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface isendcell : UITableViewCell
@property(nonatomic, strong)IBOutlet UIImageView* play;
@property(nonatomic, strong)IBOutlet UILabel* duration;
@property(nonatomic, strong)IBOutlet UILabel* time;
@property(nonatomic, strong)IBOutlet UILabel* towho;
@property(nonatomic, strong)IBOutlet UILabel* playcount;
@property(nonatomic, strong)IBOutlet UIButton* deleteaudio;

+(instancetype)cellwithTableview:(UITableView*)tableview;
@end

NS_ASSUME_NONNULL_END

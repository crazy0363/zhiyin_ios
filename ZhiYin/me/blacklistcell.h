//
//  blacklistcell.h
//  ZhiYin
//
//  Created by pro on 2018/11/9.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface blacklistcell : UITableViewCell
@property(nonatomic, strong)IBOutlet UILabel* nickname;
@property(nonatomic, strong)IBOutlet UIButton* outblacklist;
+(instancetype)cellwithTableview:(UITableView*)tableview;
@end

NS_ASSUME_NONNULL_END

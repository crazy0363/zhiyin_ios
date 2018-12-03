//
//  blacklistvc.h
//  ZhiYin
//
//  Created by pro on 2018/11/9.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface blacklistvc : QMUICommonViewController<QMUITableViewDelegate, QMUITableViewDataSource>
@property(nonatomic, strong)IBOutlet UITableView* blacklisttv;
@property(nonatomic, strong)IBOutlet UIButton* returnbtn;
@property(nonatomic, strong)IBOutlet UILabel* infolable;
@end

NS_ASSUME_NONNULL_END

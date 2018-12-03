//
//  isendvc.h
//  ZhiYin
//
//  Created by pro on 2018/10/11.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface isendvc : QMUICommonViewController<QMUITableViewDelegate, QMUITableViewDataSource>
@property(nonatomic, strong)IBOutlet UITableView* isendtv;
@property(nonatomic, strong)IBOutlet UIButton* returnbtn;
@end

NS_ASSUME_NONNULL_END

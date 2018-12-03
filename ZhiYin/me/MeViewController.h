//
//  MeViewController.h
//  ZhiYin
//
//  Created by pro on 2018/9/26.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeViewController : QMUICommonViewController<QMUITableViewDelegate, QMUITableViewDataSource>

@property(nonatomic, strong)IBOutlet QMUILabel* nickinfo;
@property(nonatomic, strong)IBOutlet QMUILabel* nickname;
@property(nonatomic, strong)IBOutlet QMUITableView* metableview;

-(void)refreshtableview;

@end

NS_ASSUME_NONNULL_END

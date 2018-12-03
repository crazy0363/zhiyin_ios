//
//  Ranklistvc.h
//  ZhiYin
//
//  Created by pro on 2018/10/9.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Ranklistvc : QMUICommonViewController<QMUITableViewDelegate, QMUITableViewDataSource>
@property(nonatomic, strong)IBOutlet UITableView* ranklisttv;
@property(nonatomic, strong)IBOutlet UILabel* tiplabel;
-(NSArray*)ranklist_audiolist;
@end

NS_ASSUME_NONNULL_END

//
//  topicvc.h
//  ZhiYin
//
//  Created by pro on 2018/11/28.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface topicvc : QMUICommonViewController<QMUITableViewDelegate, QMUITableViewDataSource>
@property(nonatomic, strong)IBOutlet UITableView* topictv;
@property(nonatomic, strong)IBOutlet UILabel* tiplabel;
-(void)refresh_audiolist;
@end

NS_ASSUME_NONNULL_END

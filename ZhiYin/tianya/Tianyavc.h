//
//  Tianyavc.h
//  ZhiYin
//
//  Created by freejet on 2018/10/1.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tianyavc : QMUICommonViewController<QMUITableViewDelegate, QMUITableViewDataSource>
@property(nonatomic, strong)IBOutlet UITableView* tianyatv;
@property(nonatomic, strong)IBOutlet UILabel* tiplabel;
-(NSArray*)tianya_audiolist;
-(void)refresh_audiolist;
@end

NS_ASSUME_NONNULL_END

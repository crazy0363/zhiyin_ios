//
//  Mizhiyinvc.h
//  ZhiYin
//
//  Created by freejet on 2018/10/5.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import <QMUIKit/QMUIKit.h>
#import "BEMCheckBox.h"

NS_ASSUME_NONNULL_BEGIN

@interface Mizhiyinvc : QMUICommonViewController<BEMCheckBoxDelegate>
@property(nonatomic, strong)IBOutlet TTTAttributedLabel* towherelabel;
@property(nonatomic, strong)IBOutlet UILabel* introlabel;
@property(nonatomic, strong)IBOutlet UIView* recordview;
@property(nonatomic, strong)IBOutlet UIView* towhereview;
@property(nonatomic, strong)IBOutlet BEMCheckBox* tianyabox;
@property(nonatomic, strong)IBOutlet BEMCheckBox* topicbox;
@end

NS_ASSUME_NONNULL_END

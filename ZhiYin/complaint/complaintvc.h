//
//  complaintvc.h
//  ZhiYin
//
//  Created by pro on 2018/11/6.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import "RadioButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface complaintvc : UIViewController
@property(nonatomic, strong)IBOutlet TTTAttributedLabel* audiofrom;
@property(nonatomic, strong)IBOutlet TTTAttributedLabel* pushblacklabel;
@property(nonatomic, strong)IBOutlet UIButton* returnbtn;
@property(nonatomic, strong)IBOutlet UIButton* sendcomplaint;
@property(nonatomic, strong)IBOutlet UIButton* sendblack;
@property (strong, nonatomic) IBOutlet RadioButton *radioButton1;
@property (strong, nonatomic) IBOutlet RadioButton *radioButton2;
@property (strong, nonatomic) IBOutlet RadioButton *radioButton3;
@property (strong, nonatomic) IBOutlet RadioButton *radioButton4;
@property (strong, nonatomic) IBOutlet RadioButton *radioButton5;
@property (strong, nonatomic) IBOutlet UILabel *blackintro;
@property(nonatomic, strong)NSString* nicknamefrom;
@property(nonatomic, strong)NSString* audioid;
@property(nonatomic, strong)NSString* userid;

-(void)complaint_who:(NSString*)userid nickname:(NSString*)nicknamefrom audioid:(NSString*)audioid onvcindex:(NSInteger)vcindex;
@end

NS_ASSUME_NONNULL_END

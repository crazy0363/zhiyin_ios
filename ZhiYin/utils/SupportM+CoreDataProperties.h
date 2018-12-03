//
//  SupportM+CoreDataProperties.h
//  ZhiYin
//
//  Created by pro on 2018/10/8.
//  Copyright © 2018年 zy. All rights reserved.
//
//

#import "SupportM+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SupportM (CoreDataProperties)

+ (NSFetchRequest<SupportM *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *audioid;

@end

NS_ASSUME_NONNULL_END

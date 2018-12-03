//
//  SupportM+CoreDataProperties.m
//  ZhiYin
//
//  Created by pro on 2018/10/8.
//  Copyright © 2018年 zy. All rights reserved.
//
//

#import "SupportM+CoreDataProperties.h"

@implementation SupportM (CoreDataProperties)

+ (NSFetchRequest<SupportM *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"SupportM"];
}

@dynamic audioid;

@end

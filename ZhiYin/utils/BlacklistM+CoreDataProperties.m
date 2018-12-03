//
//  BlacklistM+CoreDataProperties.m
//  
//
//  Created by pro on 2018/11/9.
//
//

#import "BlacklistM+CoreDataProperties.h"

@implementation BlacklistM (CoreDataProperties)

+ (NSFetchRequest<BlacklistM *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BlacklistM"];
}

@dynamic userid;
@dynamic nickname;

@end

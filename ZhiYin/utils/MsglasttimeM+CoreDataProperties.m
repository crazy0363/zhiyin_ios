//
//  MsglasttimeM+CoreDataProperties.m
//  
//
//  Created by freejet on 2018/10/20.
//
//

#import "MsglasttimeM+CoreDataProperties.h"

@implementation MsglasttimeM (CoreDataProperties)

+ (NSFetchRequest<MsglasttimeM *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"MsglasttimeM"];
}

@dynamic msglasttime;

@end

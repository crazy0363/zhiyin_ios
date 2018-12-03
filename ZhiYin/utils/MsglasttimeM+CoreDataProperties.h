//
//  MsglasttimeM+CoreDataProperties.h
//  
//
//  Created by freejet on 2018/10/20.
//
//

#import "MsglasttimeM+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MsglasttimeM (CoreDataProperties)

+ (NSFetchRequest<MsglasttimeM *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *msglasttime;

@end

NS_ASSUME_NONNULL_END

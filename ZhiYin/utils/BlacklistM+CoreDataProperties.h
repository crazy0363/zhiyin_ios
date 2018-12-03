//
//  BlacklistM+CoreDataProperties.h
//  
//
//  Created by pro on 2018/11/9.
//
//

#import "BlacklistM+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BlacklistM (CoreDataProperties)

+ (NSFetchRequest<BlacklistM *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *userid;
@property (nullable, nonatomic, copy) NSString *nickname;

@end

NS_ASSUME_NONNULL_END

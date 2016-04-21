//
//  PX500UserEntity+CoreDataProperties.h
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PX500UserEntity.h"
#import "PX500PhotoEntity.h"
#import "PX500PhotosEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface PX500UserEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *fullName;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSString *userName;
@property (nullable, nonatomic, retain) NSString *userPicUrl;
@property (nullable, nonatomic, retain) NSSet<PX500PhotoEntity *> *photos;

@end

@interface PX500UserEntity (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(PX500PhotoEntity *)value;
- (void)removePhotosObject:(PX500PhotoEntity *)value;
- (void)addPhotos:(NSSet<PX500PhotoEntity *> *)values;
- (void)removePhotos:(NSSet<PX500PhotoEntity *> *)values;

@end

NS_ASSUME_NONNULL_END

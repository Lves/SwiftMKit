//
//  PX500PhotoEntity+CoreDataProperties.h
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PX500PhotoEntity.h"
#import "PX500PhotosEntity.h"
#import "PX500UserEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface PX500PhotoEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *descriptionString;
@property (nullable, nonatomic, retain) NSNumber *favoritesCount;
@property (nullable, nonatomic, retain) NSString *imageUrl;
@property (nullable, nonatomic, retain) NSString *photoId;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSString *user_id;
@property (nullable, nonatomic, retain) NSNumber *votesCount;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) PX500PhotosEntity *photos;
@property (nullable, nonatomic, retain) PX500UserEntity *user;

@end

NS_ASSUME_NONNULL_END

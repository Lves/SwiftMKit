//
//  PX500PhotosEntity+CoreDataProperties.h
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PX500PhotosEntity.h"
#import "PX500PhotoEntity.h"
#import "PX500UserEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface PX500PhotosEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *current_page;
@property (nullable, nonatomic, retain) NSNumber *total_items;
@property (nullable, nonatomic, retain) NSNumber *total_pages;
@property (nullable, nonatomic, retain) NSOrderedSet<PX500PhotoEntity *> *photos;

@end

@interface PX500PhotosEntity (CoreDataGeneratedAccessors)

- (void)insertObject:(PX500PhotoEntity *)value inPhotosAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPhotosAtIndex:(NSUInteger)idx;
- (void)insertPhotos:(NSArray<PX500PhotoEntity *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePhotosAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPhotosAtIndex:(NSUInteger)idx withObject:(PX500PhotoEntity *)value;
- (void)replacePhotosAtIndexes:(NSIndexSet *)indexes withPhotos:(NSArray<PX500PhotoEntity *> *)values;
- (void)addPhotosObject:(PX500PhotoEntity *)value;
- (void)removePhotosObject:(PX500PhotoEntity *)value;
- (void)addPhotos:(NSOrderedSet<PX500PhotoEntity *> *)values;
- (void)removePhotos:(NSOrderedSet<PX500PhotoEntity *> *)values;

@end

NS_ASSUME_NONNULL_END

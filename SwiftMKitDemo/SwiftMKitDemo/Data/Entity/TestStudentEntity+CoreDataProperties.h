//
//  TestStudentEntity+CoreDataProperties.h
//  SwiftMKitDemo
//
//  Created by Mao on 4/25/16.
//  Copyright © 2016 cdts. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TestStudentEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestStudentEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *aliasName;
@property (nullable, nonatomic, retain) NSNumber *money;
@property (nullable, nonatomic, retain) NSNumber *age;
@property (nullable, nonatomic, retain) NSNumber *height;
@property (nullable, nonatomic, retain) TestTeacherEntity *teacher;

@end

NS_ASSUME_NONNULL_END

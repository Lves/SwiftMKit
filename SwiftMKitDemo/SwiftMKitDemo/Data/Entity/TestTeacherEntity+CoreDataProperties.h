//
//  TestTeacherEntity+CoreDataProperties.h
//  SwiftMKitDemo
//
//  Created by Mao on 4/25/16.
//  Copyright © 2016 cdts. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TestTeacherEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestTeacherEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSOrderedSet<TestStudentEntity *> *students;

@end

@interface TestTeacherEntity (CoreDataGeneratedAccessors)

- (void)insertObject:(TestStudentEntity *)value inStudentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromStudentsAtIndex:(NSUInteger)idx;
- (void)insertStudents:(NSArray<TestStudentEntity *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeStudentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInStudentsAtIndex:(NSUInteger)idx withObject:(TestStudentEntity *)value;
- (void)replaceStudentsAtIndexes:(NSIndexSet *)indexes withStudents:(NSArray<TestStudentEntity *> *)values;
- (void)addStudentsObject:(TestStudentEntity *)value;
- (void)removeStudentsObject:(TestStudentEntity *)value;
- (void)addStudents:(NSOrderedSet<TestStudentEntity *> *)values;
- (void)removeStudents:(NSOrderedSet<TestStudentEntity *> *)values;

@end

NS_ASSUME_NONNULL_END

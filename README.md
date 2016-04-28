# SwiftMKit
Swift MKit

####一些类的使用方法
+ 避免数组越界

```
array[safe: index]
````

---

####升级Pod的时候需要注意的问题
+ MBProgressHUD
+ 从Git上下载最新的代码覆盖

+ MJExtension
+ 在NSObject+MJKeyValue文件的顶部增加如下代码：

```objc
//Add by Cdts
@interface NSManagedObject (PrimaryKey)
+ (NSString *)primaryKeyPropertyName;
@end
@implementation NSManagedObject (PrimaryKey)

+ (NSString *)primaryKeyPropertyName {
return @"entityId";
}

@end
//Finish add
```
+ 在NSObject+MJKeyValue文件的`- (instancetype)mj_setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context`
方法中修改如下代码：

```objc
/* remove by Cdts
if (!type.isFromFoundation && propertyClass) { // 模型属性
*/
//Add by Cdts
if (!type.isFromFoundation && propertyClass && propertyClass != [NSOrderedSet class]) {
//Finish add
```
```objc
} else { // 字典数组-->模型数组
value = [objectClass mj_objectArrayWithKeyValuesArray:value context:context];

//Add by Cdts
if ((propertyClass == [NSOrderedSet class] || propertyClass == [NSSet class]) && [self isKindOfClass:[NSManagedObject class]]) {
if (propertyClass == [NSOrderedSet class]) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
NSMutableOrderedSet *set = [self performSelector:NSSelectorFromString(property.name) withObject:nil];
[set removeAllObjects];
for (id x in value) {
[set addObject:x];
}
NSString *selector = [NSString stringWithFormat:@"set%@:", [property.name firstCharUpper]];
[self performSelector:NSSelectorFromString(selector) withObject:set];

#pragma clang diagnostic pop
return;
}else if (propertyClass == [NSSet class]) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
NSMutableSet *set = [self performSelector:NSSelectorFromString(property.name) withObject:nil];
for (id x in value) {
[set addObject:x];
}
NSString *selector = [NSString stringWithFormat:@"set%@:", [property.name firstCharUpper]];
[self performSelector:NSSelectorFromString(selector) withObject:nil];

#pragma clang diagnostic pop
return;
}
}
//Finish add
}
```
+ 在NSObject+MJKeyValue文件的`- + (instancetype)mj_objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context`
方法中修改如下代码：

```objc
if ([self isSubclassOfClass:[NSManagedObject class]] && context) {
/* Remove by Cdts
return [[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context] mj_setKeyValues:keyValues context:context];
*/
//Add by Cdts
NSManagedObject *obj = nil;
NSString *pkProperyName = [NSManagedObject primaryKeyPropertyName];
NSString *key = [[[self class] mj_replacedKeyFromPropertyName] objectForKey:pkProperyName];
if (key.length>0 && keyValues[key]) {
NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
NSString *format = [[NSString stringWithFormat:@"%@ = ",pkProperyName] stringByAppendingString:@"%@"];
id value = keyValues[key];
NSString *entityId = @"";
if ([value isKindOfClass:[NSString class]]) {
entityId = value;
}else{
entityId = [keyValues[key] stringValue];
}
request.predicate = [NSPredicate predicateWithFormat:format,entityId];
NSArray *result = [context executeFetchRequest:request error:NULL];
obj = result.firstObject;
}
if (!obj) {
obj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context];
}
return [obj mj_setKeyValues:keyValues context:context];
//Finish add
}
```

---
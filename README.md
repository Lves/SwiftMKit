# SwiftMKit
Swift MKit

####一些类的使用方法
+ 避免数组越界

```
array[safe: index]
````

---

####升级Pod的时候需要注意的问题
#####MBProgressHUD

+ 从Git上下载最新的代码覆盖

#####MJExtension 
+ 在NSObject+MJKeyValue文件的顶部增加如下代码：

```objc
// ModifySourceCode Add by Cdts
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
/* ModifySourceCode remove by Cdts
if (!type.isFromFoundation && propertyClass) { // 模型属性
*/
// ModifySourceCode Add by Cdts
if (!type.isFromFoundation && propertyClass && propertyClass != [NSOrderedSet class]) {
//Finish add
```
```objc
} else { // 字典数组-->模型数组
value = [objectClass mj_objectArrayWithKeyValuesArray:value context:context];

// ModifySourceCode Add by Cdts
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
/* ModifySourceCode Remove by Cdts
return [[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context] mj_setKeyValues:keyValues context:context];
*/
// ModifySourceCode Add by Cdts
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
#####Charts
+ ILineRadarChartDataSet 增加接口：
```swift
// ModifySourceCode Add By LiXingLe
//是否RangeFill
var drawRangeFilledEnabled:Bool { get set }
//fillRange的较低值
var fillLowerYValues:[ChartDataEntry]{ get set }
//Finish add
```
+ LineRadarChartDataSet 增加实现：
```swift
//ModifySourceCode Add By LiXingLe
//是否RangeFill
public var drawRangeFilledEnabled = false
//fillRange的较低值
public var fillLowerYValues:[ChartDataEntry] = []
//Finish add
```
+ generateFilledPath 修改方法：

```
/* ModifySourceCode Remove By LiXingLe
if e != nil
{
CGPathAddLineToPoint(filled, &matrix, CGFloat(e.xIndex), fillMin)
}
*/
// ModifySourceCode Add By LiXingLe
if dataSet.drawRangeFilledEnabled {
if e != nil
{
let eLower: ChartDataEntry! = dataSet.fillLowerYValues[e.xIndex]
CGPathAddLineToPoint(filled, &matrix, CGFloat(eLower.xIndex), CGFloat(eLower.value)) // 第二条线的右上角
}

// create a Second path
for x in (to - 1).stride(to: Int(from-1), by: -1)
{
let eLower = dataSet.fillLowerYValues[x]
CGPathAddLineToPoint(filled, &matrix, CGFloat(eLower.xIndex), CGFloat(eLower.value) * phaseY)
}

}else{
if e != nil
{
CGPathAddLineToPoint(filled, &matrix, CGFloat(e.xIndex), fillMin)
}
}
//Finish add

```

+  drawCubicFill 修改方法：

```

let fillMin = dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0
// Take the from/to xIndex from the entries themselves,
// so missing entries won't screw up the filling.
// What we need to draw is line from points of the xIndexes - not arbitrary entry indexes!
let xTo = dataSet.entryForIndex(to - 1)?.xIndex ?? 0
let xFrom = dataSet.entryForIndex(from)?.xIndex ?? 0

var pt1 = CGPoint(x: CGFloat(xTo), y: fillMin)
var pt2 = CGPoint(x: CGFloat(xFrom), y: fillMin)
pt1 = CGPointApplyAffineTransform(pt1, matrix)
pt2 = CGPointApplyAffineTransform(pt2, matrix)

CGPathAddLineToPoint(spline, nil, pt1.x, pt1.y)
CGPathAddLineToPoint(spline, nil, pt2.x, pt2.y)
CGPathCloseSubpath(spline)

```


改成：

```

/// modify by lixingle
if dataSet.drawRangeFilledEnabled {
//调用绘制路径
drawCubicFillPath(context: context, dataSet: dataSet, spline: spline, matrix: matrix)

}else{
let fillMin = dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0
// Take the from/to xIndex from the entries themselves,
// so missing entries won't screw up the filling.
// What we need to draw is line from points of the xIndexes - not arbitrary entry indexes!
let xTo = dataSet.entryForIndex(to - 1)?.xIndex ?? 0
let xFrom = dataSet.entryForIndex(from)?.xIndex ?? 0

var pt1 = CGPoint(x: CGFloat(xTo), y: fillMin)
var pt2 = CGPoint(x: CGFloat(xFrom), y: fillMin)
pt1 = CGPointApplyAffineTransform(pt1, matrix)
pt2 = CGPointApplyAffineTransform(pt2, matrix)

CGPathAddLineToPoint(spline, nil, pt1.x, pt1.y)
CGPathAddLineToPoint(spline, nil, pt2.x, pt2.y)
CGPathCloseSubpath(spline)
}

```

+ drawCubicFillPath 新添加方法 用于绘制折线图的部分填充

```

//midify by lixingle
func drawCubicFillPath(context context: CGContext, dataSet: ILineChartDataSet, spline: CGMutablePath, matrix: CGAffineTransform){
guard let
trans = dataProvider?.getTransformer(dataSet.axisDependency),
animator = animator
else { return }

let phaseX = animator.phaseX
let phaseY = animator.phaseY

let entryCount = dataSet.fillLowerYValues.count
let intensity = dataSet.cubicIntensity

guard let
entryFrom:ChartDataEntry! = dataSet.fillLowerYValues[entryCount-1],
entryTo:ChartDataEntry! =  dataSet.fillLowerYValues.first
else { return }

let diff = (entryFrom == entryTo) ? 1 : 0
let minx = 0
let maxx = entryCount-1

var valueToPixelMatrix = trans.valueToPixelMatrix

let size = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))

if (size - minx >= 2)
{
var prevDx: CGFloat = 0.0
var prevDy: CGFloat = 0.0
var curDx: CGFloat = 0.0
var curDy: CGFloat = 0.0

var prevPrev: ChartDataEntry! = dataSet.fillLowerYValues[maxx]
var prev: ChartDataEntry! = prevPrev
var cur: ChartDataEntry! = prev
var next: ChartDataEntry! = dataSet.fillLowerYValues[maxx - 1]

if cur == nil || next == nil { return }

// 最低线的最后一个
CGPathAddLineToPoint(spline, &valueToPixelMatrix, CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY)

for (var j = maxx; j >= 1 ; j-- )
{
prevPrev = prev  //前一个的前一个
prev = cur       //前一个
cur = next       //当前
next = dataSet.fillLowerYValues[j - 1] //下一个

if next == nil { break }

prevDx = CGFloat(cur.xIndex - prevPrev.xIndex) * intensity
prevDy = CGFloat(cur.value - prevPrev.value) * intensity
curDx = CGFloat(next.xIndex - prev.xIndex) * intensity
curDy = CGFloat(next.value - prev.value) * intensity

// the last cubic
CGPathAddCurveToPoint(spline, &valueToPixelMatrix,
CGFloat(prev.xIndex) + prevDx,(CGFloat(prev.value) + prevDy) * phaseY,
CGFloat(cur.xIndex) - curDx,(CGFloat(cur.value) - curDy) * phaseY,
CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY)
}

}
CGPathCloseSubpath(spline)
}

```


---
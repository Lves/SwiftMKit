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

+  LineChartRenderer.swift 中 func drawCubicFill 修改方法：

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

//ModifySourceCode Add By LiXingLe
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

//ModifySourceCode Add By LiXingLe
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
+ LineScatterCandleRadarChartRenderer.swift func:drawHighlightLines中修改绘制活动游标的方法

```
  if set.isVerticalHighlightIndicatorEnabled
        {
           CGContextBeginPath(context)
           CGContextMoveToPoint(context, point.x, viewPortHandler.contentTop)
           CGContextAddLineToPoint(context, point.x, viewPortHandler.contentBottom)
           CGContextStrokePath(context)
            
        }

```
修改为：

```
        // modify by  lxingle
        if set.isVerticalHighlightIndicatorEnabled
        {
            //方案一 ModifySourceCode update By LiXingLe
            CGContextSaveGState(context);
            UIColor.whiteColor().setFill()
            let path = UIBezierPath(ovalInRect: CGRect(x: point.x-1.5/2.0, y: 15, width: 1.5, height: viewPortHandler.contentBottom - viewPortHandler.contentTop-30))
            path.lineWidth = 0.1
            path.fill()
            CGContextRestoreGState( context );
        }

```


#### 显示高亮圆点逻辑
1. 在`ChartViewBase.swift`文件中添加是否显示高亮circle的属性


```
// ModifySourceCode Add By LiXingLe
public var showAllHighlightCircles = false
```

2. 在父类`ChartDataRendererBase`中添加 绘制单个高亮圆点的空函数

```
// ModifySourceCode Add By LiXingLe
public func drawCircleIndex(context context: CGContext, indices: [ChartHighlight]) {

}
```

3. 在 ILineRadarChartDataSet 中添加高亮原定形状枚举,和形状属性

```
// ModifySourceCode Add By LiXingLe 高亮点形状枚举
@objc
public enum ChartDataForm: Int
{
    case Square
    case Circle
}
//add end

```

形状：

```
 //高亮点类型
 var form:ChartDataForm {get set}
```
4. 在LineRadarChartDataSet中实现属性

```
 //实现高亮点类型
 public var form: ChartDataForm = .Circle
```


5. 在`LineChartRenderer`中实现绘制高亮点的方法

```
//绘制高亮数据点
    // ModifySourceCode Add By LiXingLe
    public override func drawCircleIndex(context context: CGContext , indices: [ChartHighlight]) {
        guard let
            dataProvider = dataProvider,
            lineData = dataProvider.lineData,
            animator = animator
            else { return }
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        let dataSets = lineData.dataSets
        
        var pt = CGPoint()
        var rect = CGRect()
        
        CGContextSaveGState(context)
        
        for i in 0 ..< dataSets.count
        {
            guard let dataSet = lineData.getDataSetByIndex(i) as? ILineChartDataSet else { continue }
            //lixingle 添加是否可以高亮条件
            if !dataSet.isVisible || dataSet.entryCount == 0 || !dataSet.highlightEnabled
            {
                continue
            }
            
            let trans = dataProvider.getTransformer(dataSet.axisDependency)
            let valueToPixelMatrix = trans.valueToPixelMatrix
            
            let entryCount = dataSet.entryCount
            
            let circleRadius = dataSet.circleRadius
            //计算外环半径，lixingle
            let circleDiameter = circleRadius + 3.0
//            let circleDiameter = circleRadius * 2.0
            let circleHoleDiameter = circleRadius
            let circleHoleRadius = circleHoleDiameter / 2.0
            let isDrawCircleHoleEnabled = dataSet.isDrawCircleHoleEnabled
            
            guard let
                entryFrom = dataSet.entryForXIndex(self.minX < 0 ? self.minX : 0, rounding: .Down),
                entryTo = dataSet.entryForXIndex(self.maxX, rounding: .Up)
                else { continue }
            
            let diff = (entryFrom == entryTo) ? 1 : 0
            let minx = max(dataSet.entryIndex(entry: entryFrom) - diff, 0)
            let maxx = min(max(minx + 2, dataSet.entryIndex(entry: entryTo) + 1), entryCount)
            
            for j in minx ..< Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
            {
                
                if indices[0].xIndex != j {
                    continue
                }
                
                guard let e = dataSet.entryForIndex(j) else { break }
                
                pt.x = CGFloat(e.xIndex)
                pt.y = CGFloat(e.value) * phaseY
                pt = CGPointApplyAffineTransform(pt, valueToPixelMatrix)
                
                if (!viewPortHandler.isInBoundsRight(pt.x))
                {
                    break
                }
                
                // make sure the circles don't do shitty things outside bounds
                if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
                {
                    continue
                }
                
                CGContextSetFillColorWithColor(context, dataSet.getCircleColor(j)!.CGColor)
                //计算外环圆心位置，lixingle
                rect.origin.x = pt.x - circleDiameter/2.0
                rect.origin.y = pt.y - circleDiameter/2.0
//                rect.origin.x = pt.x - circleRadius
//                rect.origin.y = pt.y - circleRadius
                
                rect.size.width = circleDiameter
                rect.size.height = circleDiameter
                //lixingle ,绘制外环数据点
//                CGContextFillEllipseInRect(context, rect)
                if dataSet.form == .Circle {
                    CGContextFillEllipseInRect(context, rect)
                }else{
                    CGContextFillRect(context, rect)
                }

                
                
                if (isDrawCircleHoleEnabled)
                {
                    CGContextSetFillColorWithColor(context, dataSet.circleHoleColor.CGColor)
                    
                    rect.origin.x = pt.x - circleHoleRadius
                    rect.origin.y = pt.y - circleHoleRadius
                    rect.size.width = circleHoleDiameter
                    rect.size.height = circleHoleDiameter
                    //绘制内环数据点
//                    CGContextFillEllipseInRect(context, rect)
                    if dataSet.form == .Circle {
                        CGContextFillEllipseInRect(context, rect)
                    }else{
                        CGContextFillRect(context, rect)
                    }
                }
            }
        }
        
        CGContextRestoreGState(context)
    
    
    }

```

6. 在`BarLineChartViewBase` 中`renderer?.drawHighlighted(context: context, indices: _indicesToHighlight)`下面调用绘制高亮函数

```
// ModifySourceCode Add By LiXingLe
if showAllHighlightCircles {
renderer?.drawCircleIndex(context: context, indices: _indicesToHighlight)
}
```

#### 默认高亮点
1. ChartViewBase.swift  ChartViewBase类中添加存储属性`indicesDefaultToHighlight`存储默认高亮点信息

```
 // ModifySourceCode Add By LiXingLe  绘制默认高亮点
 public var indicesDefaultToHighlight = [ChartHighlight]()
 //Add end
```

2. 在BarLineChartViewBase.swift（270行左右）添加else非高亮状态下绘制高亮点

```
else {
	// ModifySourceCode Add By LiXingLe  绘制默认高亮点
	if showAllHighlightCircles {
	    renderer?.drawCircleIndex(context: context, indices: indicesDefaultToHighlight)
	}
}
```
3. 移动 `CGContextRestoreGState(context)` 位置，从277移到264和274行。解决高亮点在第一个或者最后一个绘制一半的问题


####自定义BarChartView 数值变化动画
1. ChartViewBase.swift 中的 ChartViewBase类中添加两个参数

```
// ModifySourceCode Add By LiXingLe
//自定义动画状态 BarAnimation
public var customAnimating  = false
//是否是返回动画 BarAnimation
public var isCustomAnimateBack  = true
//Add end
```

2. IBarChartDataSet 协议中添加属性

```
// ModifySourceCode Add By LiXingLe
//动画数据源 BarAnimation
var animationVals: [ChartDataEntry]? { get set }
// Add end
```

2. BarChartDataSet.swift 中实例化数据源存储属性

```
// ModifySourceCode Add By LiXingLe
//动画数据源 BarAnimation
public var animationVals: [ChartDataEntry]?
// Add end
```
3. ChartDataRendererBase.swift 中添加三个空函数

```
// ModifySourceCode Add By LiXingLe
//绘制动画数据
public func drawAnimationData(context context: CGContext,animateBack: Bool){
fatalError("drawData() cannot be called on ChartDataRendererBase")
}
//绘制数值
public func drawAnimationValues(context context: CGContext,animateBack: Bool)
{
fatalError("drawValues() cannot be called on ChartDataRendererBase")
}
//绘制高亮
public func drawAnimationHighlighted(context context: CGContext, indices: [ChartHighlight],animateBack: Bool)
{
fatalError("drawHighlighted() cannot be called on ChartDataRendererBase")
}
//Add end
```
4. 在BarChartRenderer.swift中 实现高亮、图形、数值绘制

```
// ModifySourceCode Add By LiXingLe
public override func drawAnimationData(context context: CGContext,animateBack: Bool)
{
guard let dataProvider = dataProvider, barData = dataProvider.barData else { return }

for i in 0 ..< barData.dataSetCount
{
guard let set = barData.getDataSetByIndex(i) else { continue }

if set.isVisible && set.entryCount > 0
{
if !(set is IBarChartDataSet)
{
fatalError("Datasets for BarChartRenderer must conform to IBarChartDataset")
}

drawAnimeDataSet(context: context, dataSet: set as! IBarChartDataSet, index: i ,animateBack: animateBack)
}
}
}
// ModifySourceCode Add By LiXingLe
public func drawAnimeDataSet(context context: CGContext, dataSet: IBarChartDataSet, index: Int , animateBack: Bool)
{
guard let
dataProvider = dataProvider,
barData = dataProvider.barData,
animator = animator
else { return }

CGContextSaveGState(context)

let trans = dataProvider.getTransformer(dataSet.axisDependency)

let drawBarShadowEnabled: Bool = dataProvider.isDrawBarShadowEnabled
let dataSetOffset = (barData.dataSetCount - 1)
let groupSpace = barData.groupSpace
let groupSpaceHalf = groupSpace / 2.0
let barSpace = dataSet.barSpace
let barSpaceHalf = barSpace / 2.0
let containsStacks = dataSet.isStacked
let isInverted = dataProvider.isInverted(dataSet.axisDependency)
let barWidth: CGFloat = 0.5
let phaseY = animator.phaseY
var barRect = CGRect()
var barShadow = CGRect()
var y: Double

var newY: Double

// do the drawing
for j in 0 ..< Int(ceil(CGFloat(dataSet.entryCount) * animator.phaseX))
{
guard let e = dataSet.entryForIndex(j) as? BarChartDataEntry else { continue }
let animationE = dataSet.animationVals![j]

// calculate the x-position, depending on datasetcount
let x = CGFloat(e.xIndex + e.xIndex * dataSetOffset) + CGFloat(index)
+ groupSpace * CGFloat(e.xIndex) + groupSpaceHalf
var vals = e.values

if (!containsStacks || vals == nil)
{
y = e.value
newY = animationE.value

let left = x - barWidth + barSpaceHalf
let right = x + barWidth - barSpaceHalf
var top = isInverted ? (y <= 0.0 ? CGFloat(y) : 0) : (y >= 0.0 ? CGFloat(y) : 0)
var bottom = isInverted ? (y >= 0.0 ? CGFloat(y) : 0) : (y <= 0.0 ? CGFloat(y) : 0)

var newTop = isInverted ? (newY <= 0.0 ? CGFloat(newY) : 0) : (newY >= 0.0 ? CGFloat(newY) : 0)
var newBottom = isInverted ? (newY >= 0.0 ? CGFloat(newY) : 0) : (newY <= 0.0 ? CGFloat(newY) : 0)
// multiply the height of the rect with the phase


if animateBack {
if (top > 0)
{
//                    top *= phaseY
newTop += (top - newTop)*phaseY
newBottom = 0.0
}
else
{
//                            bottom *= phaseY
newBottom += (bottom - newBottom)*phaseY
newTop = 0.0
}
}else {
if (newTop > 0)
{
//       top *= phaseY
top += (newTop - top)*phaseY
bottom = 0.0
}
else
{
//                            bottom *= phaseY
bottom += (newBottom - bottom)*phaseY
top = 0.0
}
}
//s
let useTop  = animateBack ? newTop : top
let useBottom = animateBack ? newBottom : bottom


barRect.origin.x = left
barRect.size.width = right - left
barRect.origin.y = useTop
barRect.size.height = useBottom - useTop

trans.rectValueToPixel(&barRect)

if (!viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width))
{
continue
}

if (!viewPortHandler.isInBoundsRight(barRect.origin.x))
{
break
}

// if drawing the bar shadow is enabled
if (drawBarShadowEnabled)
{
barShadow.origin.x = barRect.origin.x
barShadow.origin.y = viewPortHandler.contentTop
barShadow.size.width = barRect.size.width
barShadow.size.height = viewPortHandler.contentHeight

CGContextSetFillColorWithColor(context, dataSet.barShadowColor.CGColor)
CGContextFillRect(context, barShadow)
}

// Set the color for the currently drawn value. If the index is out of bounds, reuse colors.
CGContextSetFillColorWithColor(context, dataSet.colorAt(j).CGColor)
CGContextFillRect(context, barRect)
}
else
{
var posY = 0.0
var negY = -e.negativeSum
var yStart = 0.0

// if drawing the bar shadow is enabled
if (drawBarShadowEnabled)
{
y = e.value

let left = x - barWidth + barSpaceHalf
let right = x + barWidth - barSpaceHalf
var top = isInverted ? (y <= 0.0 ? CGFloat(y) : 0) : (y >= 0.0 ? CGFloat(y) : 0)
var bottom = isInverted ? (y >= 0.0 ? CGFloat(y) : 0) : (y <= 0.0 ? CGFloat(y) : 0)

// multiply the height of the rect with the phase
if (top > 0)
{
top *= phaseY
}
else
{
bottom *= phaseY
}

barRect.origin.x = left
barRect.size.width = right - left
barRect.origin.y = top
barRect.size.height = bottom - top

trans.rectValueToPixel(&barRect)

barShadow.origin.x = barRect.origin.x
barShadow.origin.y = viewPortHandler.contentTop
barShadow.size.width = barRect.size.width
barShadow.size.height = viewPortHandler.contentHeight

CGContextSetFillColorWithColor(context, dataSet.barShadowColor.CGColor)
CGContextFillRect(context, barShadow)
}

// fill the stack
for k in 0 ..< vals!.count
{
let value = vals![k]

if value >= 0.0
{
y = posY
yStart = posY + value
posY = yStart
}
else
{
y = negY
yStart = negY + abs(value)
negY += abs(value)
}

let left = x - barWidth + barSpaceHalf
let right = x + barWidth - barSpaceHalf
var top: CGFloat, bottom: CGFloat
if isInverted
{
bottom = y >= yStart ? CGFloat(y) : CGFloat(yStart)
top = y <= yStart ? CGFloat(y) : CGFloat(yStart)
}
else
{
top = y >= yStart ? CGFloat(y) : CGFloat(yStart)
bottom = y <= yStart ? CGFloat(y) : CGFloat(yStart)
}

// multiply the height of the rect with the phase
top *= phaseY
bottom *= phaseY

barRect.origin.x = left
barRect.size.width = right - left
barRect.origin.y = top
barRect.size.height = bottom - top

trans.rectValueToPixel(&barRect)

if (k == 0 && !viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width))
{
// Skip to next bar
break
}

// avoid drawing outofbounds values
if (!viewPortHandler.isInBoundsRight(barRect.origin.x))
{
break
}

// Set the color for the currently drawn value. If the index is out of bounds, reuse colors.
CGContextSetFillColorWithColor(context, dataSet.colorAt(k).CGColor)
CGContextFillRect(context, barRect)
}
}
}

CGContextRestoreGState(context)
}

    // ModifySourceCode Add By LiXingLe
    public override func drawAnimationValues(context context: CGContext,animateBack: Bool){
        // if values are drawn
        if (passesCheck())
        {
            guard let
                dataProvider = dataProvider,
                barData = dataProvider.barData,
                animator = animator
                else { return }
            
            var dataSets = barData.dataSets
            
            let drawValueAboveBar = dataProvider.isDrawValueAboveBarEnabled
            
            var posOffset: CGFloat
            var negOffset: CGFloat
            
            for dataSetIndex in 0 ..< barData.dataSetCount
            {
                guard let dataSet = dataSets[dataSetIndex] as? IBarChartDataSet else { continue }
                
                if !dataSet.isDrawValuesEnabled || dataSet.entryCount == 0
                {
                    continue
                }
                
                let isInverted = dataProvider.isInverted(dataSet.axisDependency)
                
                // calculate the correct offset depending on the draw position of the value
                let valueOffsetPlus: CGFloat = 4.5
                let valueFont = dataSet.valueFont
                let valueTextHeight = valueFont.lineHeight
                posOffset = (drawValueAboveBar ? -(valueTextHeight + valueOffsetPlus) : valueOffsetPlus)
                negOffset = (drawValueAboveBar ? valueOffsetPlus : -(valueTextHeight + valueOffsetPlus))
                
                if (isInverted)
                {
                    posOffset = -posOffset - valueTextHeight
                    negOffset = -negOffset - valueTextHeight
                }
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                let trans = dataProvider.getTransformer(dataSet.axisDependency)
                
                let phaseY = animator.phaseY
                let dataSetCount = barData.dataSetCount
                let groupSpace = barData.groupSpace
                
                // if only single values are drawn (sum)
                if (!dataSet.isStacked)
                {
                    for j in 0 ..< Int(ceil(CGFloat(dataSet.entryCount) * animator.phaseX))
                    {
                        guard let e = dataSet.entryForIndex(j) as? BarChartDataEntry else { continue }
                        let animationE = dataSet.animationVals![j]
                        //lxingle
                        let userE = animateBack ? e : animationE

                        
                        
//                        let valuePoint = trans.getTransformedValueBarChart(
//                            entry: userE,
//                            xIndex: e.xIndex,
//                            dataSetIndex: dataSetIndex,
//                            phaseY: phaseY,
//                            dataSetCount: dataSetCount,
//                            groupSpace: groupSpace
//                        )

                        // ............ start ..............
                        let x = CGFloat(e.xIndex + (e.xIndex * (dataSetCount - 1)) + dataSetIndex) + groupSpace * CGFloat(e.xIndex) + groupSpace / 2.0
                        var yPoint:CGFloat = 0.0
                        if animateBack {
                            yPoint = CGFloat(animationE.value) + (CGFloat(e.value) - CGFloat(animationE.value)) * phaseY
                        }else {
                            yPoint = CGFloat(e.value) + (CGFloat(animationE.value) - CGFloat(e.value)) * phaseY
                        }
                        var valuePoint = CGPoint(
                            x: x,
                            y: yPoint
                        )
                        trans.pointValueToPixel(&valuePoint)
                        
                        // .......... end .............
                        
                        if (!viewPortHandler.isInBoundsRight(valuePoint.x))
                        {
                            break
                        }
                        
                        if (!viewPortHandler.isInBoundsY(valuePoint.y)
                            || !viewPortHandler.isInBoundsLeft(valuePoint.x))
                        {
                            continue
                        }
                        //lxingle
                        let val = userE.value
                        
                        drawValue(context: context,
                                  value: formatter.stringFromNumber(val)!,
                                  xPos: valuePoint.x,
                                  yPos: valuePoint.y + (val >= 0.0 ? posOffset : negOffset),
                                  font: valueFont,
                                  align: .Center,
                                  color: dataSet.valueTextColorAt(j))
                    }
                }
                else
                {
                    // if we have stacks
                    
                    for j in 0 ..< Int(ceil(CGFloat(dataSet.entryCount) * animator.phaseX))
                    {
                        guard let e = dataSet.entryForIndex(j) as? BarChartDataEntry else { continue }
                        
                        let values = e.values
                        
                        let valuePoint = trans.getTransformedValueBarChart(entry: e, xIndex: e.xIndex, dataSetIndex: dataSetIndex, phaseY: phaseY, dataSetCount: dataSetCount, groupSpace: groupSpace)
                        
                        // we still draw stacked bars, but there is one non-stacked in between
                        if (values == nil)
                        {
                            if (!viewPortHandler.isInBoundsRight(valuePoint.x))
                            {
                                break
                            }
                            
                            if (!viewPortHandler.isInBoundsY(valuePoint.y)
                                || !viewPortHandler.isInBoundsLeft(valuePoint.x))
                            {
                                continue
                            }
                            
                            drawValue(context: context,
                                      value: formatter.stringFromNumber(e.value)!,
                                      xPos: valuePoint.x,
                                      yPos: valuePoint.y + (e.value >= 0.0 ? posOffset : negOffset),
                                      font: valueFont,
                                      align: .Center,
                                      color: dataSet.valueTextColorAt(j))
                        }
                        else
                        {
                            // draw stack values
                            
                            let vals = values!
                            var transformed = [CGPoint]()
                            
                            var posY = 0.0
                            var negY = -e.negativeSum
                            
                            for k in 0 ..< vals.count
                            {
                                let value = vals[k]
                                var y: Double
                                
                                if value >= 0.0
                                {
                                    posY += value
                                    y = posY
                                }
                                else
                                {
                                    y = negY
                                    negY -= value
                                }
                                
                                transformed.append(CGPoint(x: 0.0, y: CGFloat(y) * animator.phaseY))
                            }
                            
                            trans.pointValuesToPixel(&transformed)
                            
                            for k in 0 ..< transformed.count
                            {
                                let x = valuePoint.x
                                let y = transformed[k].y + (vals[k] >= 0 ? posOffset : negOffset)
                                
                                if (!viewPortHandler.isInBoundsRight(x))
                                {
                                    break
                                }
                                
                                if (!viewPortHandler.isInBoundsY(y) || !viewPortHandler.isInBoundsLeft(x))
                                {
                                    continue
                                }
                                
                                drawValue(context: context,
                                          value: formatter.stringFromNumber(vals[k])!,
                                          xPos: x,
                                          yPos: y,
                                          font: valueFont,
                                          align: .Center,
                                          color: dataSet.valueTextColorAt(j))
                            }
                        }
                    }
                }
            }
        }

    }
// ModifySourceCode Add By LiXingLe
public override func drawAnimationHighlighted(context context: CGContext, indices: [ChartHighlight], animateBack: Bool) {
guard let
dataProvider = dataProvider,
barData = dataProvider.barData,
animator = animator
else { return }

CGContextSaveGState(context)

let setCount = barData.dataSetCount
let drawHighlightArrowEnabled = dataProvider.isDrawHighlightArrowEnabled
var barRect = CGRect()

for i in 0 ..< indices.count
{
let h = indices[i]
let index = h.xIndex

let dataSetIndex = h.dataSetIndex

guard let set = barData.getDataSetByIndex(dataSetIndex) as? IBarChartDataSet else { continue }

if (!set.isHighlightEnabled)
{
continue
}

let barspaceHalf = set.barSpace / 2.0

let trans = dataProvider.getTransformer(set.axisDependency)

CGContextSetFillColorWithColor(context, set.highlightColor.CGColor)
CGContextSetAlpha(context, set.highlightAlpha)

// check outofbounds
if (CGFloat(index) < (CGFloat(dataProvider.chartXMax) * animator.phaseX) / CGFloat(setCount))
{
let e = set.entryForXIndex(index) as! BarChartDataEntry!
//modify by lixingle
let animationE = set.animationVals![index-1]

if (e === nil || e.xIndex != index)
{
continue
}

let groupspace = barData.groupSpace
let isStack = h.stackIndex < 0 ? false : true

// calculate the correct x-position
let x = CGFloat(index * setCount + dataSetIndex) + groupspace / 2.0 + groupspace * CGFloat(index)

let y1: Double
let y2: Double

if (isStack)
{
y1 = h.range?.from ?? 0.0
y2 = h.range?.to ?? 0.0
}
else
{
//modify by lixingle
y1 = animateBack ? e.value : animationE.value
y2 = 0.0
}

prepareBarHighlight(x: x, y1: y1, y2: y2, barspacehalf: barspaceHalf, trans: trans, rect: &barRect)

CGContextFillRect(context, barRect)

if (drawHighlightArrowEnabled)
{
CGContextSetAlpha(context, 1.0)

// distance between highlight arrow and bar
let offsetY = animator.phaseY * 0.07

CGContextSaveGState(context)

let pixelToValueMatrix = trans.pixelToValueMatrix
let xToYRel = abs(sqrt(pixelToValueMatrix.b * pixelToValueMatrix.b + pixelToValueMatrix.d * pixelToValueMatrix.d) / sqrt(pixelToValueMatrix.a * pixelToValueMatrix.a + pixelToValueMatrix.c * pixelToValueMatrix.c))

let arrowWidth = set.barSpace / 2.0
let arrowHeight = arrowWidth * xToYRel

let yArrow = (y1 > -y2 ? y1 : y1) * Double(animator.phaseY)

_highlightArrowPtsBuffer[0].x = CGFloat(x) + 0.4
_highlightArrowPtsBuffer[0].y = CGFloat(yArrow) + offsetY
_highlightArrowPtsBuffer[1].x = CGFloat(x) + 0.4 + arrowWidth
_highlightArrowPtsBuffer[1].y = CGFloat(yArrow) + offsetY - arrowHeight
_highlightArrowPtsBuffer[2].x = CGFloat(x) + 0.4 + arrowWidth
_highlightArrowPtsBuffer[2].y = CGFloat(yArrow) + offsetY + arrowHeight

trans.pointValuesToPixel(&_highlightArrowPtsBuffer)

CGContextBeginPath(context)
CGContextMoveToPoint(context, _highlightArrowPtsBuffer[0].x, _highlightArrowPtsBuffer[0].y)
CGContextAddLineToPoint(context, _highlightArrowPtsBuffer[1].x, _highlightArrowPtsBuffer[1].y)
CGContextAddLineToPoint(context, _highlightArrowPtsBuffer[2].x, _highlightArrowPtsBuffer[2].y)
CGContextClosePath(context)

CGContextFillPath(context)

CGContextRestoreGState(context)
}
}
}

CGContextRestoreGState(context)
}

```


5. 在 BarLineChartViewBase 中修改
* 绘制图形

```
// ModifySourceCode Update By LiXingLe
//        renderer?.drawData(context: context)
if (_data is BarChartData) && customAnimating {
renderer?.drawAnimationData(context: context,animateBack: isCustomAnimateBack)
}else{
renderer?.drawData(context: context)
}
// update end
```
* 绘制高亮

```
// ModifySourceCode Update By LiXingLe
//            renderer?.drawHighlighted(context: context, indices: _indicesToHighlight)
if (_data is BarChartData) && customAnimating {
renderer?.drawAnimationHighlighted(context: context, indices: _indicesToHighlight,animateBack: isCustomAnimateBack)
}else{
renderer?.drawHighlighted(context: context, indices: _indicesToHighlight)
}
//Update end
```
* 绘制数值

```
// ModifySourceCode Update By LiXingLe
//        renderer!.drawValues(context: context)
if (_data is BarChartData) && customAnimating {
renderer?.drawAnimationValues(context: context,animateBack: isCustomAnimateBack)
}else{
renderer!.drawValues(context: context)
}
//Update end
```


---
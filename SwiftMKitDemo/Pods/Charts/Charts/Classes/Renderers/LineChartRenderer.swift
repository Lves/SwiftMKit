//
//  LineChartRenderer.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif


public class LineChartRenderer: LineRadarChartRenderer
{
    public weak var dataProvider: LineChartDataProvider?
    
    public init(dataProvider: LineChartDataProvider?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    public override func drawData(context context: CGContext)
    {
        guard let lineData = dataProvider?.lineData else { return }
        
        for i in 0 ..< lineData.dataSetCount
        {
            guard let set = lineData.getDataSetByIndex(i) else { continue }
            
            if set.isVisible
            {
                if !(set is ILineChartDataSet)
                {
                    fatalError("Datasets for LineChartRenderer must conform to ILineChartDataSet")
                }
                
                drawDataSet(context: context, dataSet: set as! ILineChartDataSet)
            }
        }
    }
    
    public func drawDataSet(context context: CGContext, dataSet: ILineChartDataSet)
    {
        let entryCount = dataSet.entryCount
        
        if (entryCount < 1)
        {
            return
        }
        
        CGContextSaveGState(context)
        
        CGContextSetLineWidth(context, dataSet.lineWidth)
        if (dataSet.lineDashLengths != nil)
        {
            CGContextSetLineDash(context, dataSet.lineDashPhase, dataSet.lineDashLengths!, dataSet.lineDashLengths!.count)
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0)
        }
        
        // if drawing cubic lines is enabled
        if (dataSet.isDrawCubicEnabled)
        {
            drawCubic(context: context, dataSet: dataSet)
        }
        else
        { // draw normal (straight) lines
            drawLinear(context: context, dataSet: dataSet)
        }
        
        CGContextRestoreGState(context)
    }
    
    public func drawCubic(context context: CGContext, dataSet: ILineChartDataSet)
    {
        guard let
            trans = dataProvider?.getTransformer(dataSet.axisDependency),
            animator = animator
            else { return }
        
        let entryCount = dataSet.entryCount
        
        guard let
            entryFrom = dataSet.entryForXIndex(self.minX < 0 ? self.minX : 0, rounding: .Down),
            entryTo = dataSet.entryForXIndex(self.maxX, rounding: .Up)
            else { return }
        
        let diff = (entryFrom == entryTo) ? 1 : 0
        let minx = max(dataSet.entryIndex(entry: entryFrom) - diff - 1, 0)
        let maxx = min(max(minx + 2, dataSet.entryIndex(entry: entryTo) + 1), entryCount)
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        // get the color that is specified for this position from the DataSet
        let drawingColor = dataSet.colors.first!
        
        let intensity = dataSet.cubicIntensity
        
        // the path for the cubic-spline
        let cubicPath = CGPathCreateMutable()
        
        var valueToPixelMatrix = trans.valueToPixelMatrix
        
        let size = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
        
        if (size - minx >= 2)
        {
            var prevDx: CGFloat = 0.0
            var prevDy: CGFloat = 0.0
            var curDx: CGFloat = 0.0
            var curDy: CGFloat = 0.0
            
            var prevPrev: ChartDataEntry! = dataSet.entryForIndex(minx)
            var prev: ChartDataEntry! = prevPrev
            var cur: ChartDataEntry! = prev
            var next: ChartDataEntry! = dataSet.entryForIndex(minx + 1)
            
            if cur == nil || next == nil { return }
            
            // let the spline start
            CGPathMoveToPoint(cubicPath, &valueToPixelMatrix, CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY)
            
            for j in minx + 1 ..< min(size, entryCount - 1)
            {
                prevPrev = prev
                prev = cur
                cur = next
                next = dataSet.entryForIndex(j + 1)
                
                if next == nil { break }
                
                prevDx = CGFloat(cur.xIndex - prevPrev.xIndex) * intensity
                prevDy = CGFloat(cur.value - prevPrev.value) * intensity
                curDx = CGFloat(next.xIndex - prev.xIndex) * intensity
                curDy = CGFloat(next.value - prev.value) * intensity
                
                CGPathAddCurveToPoint(cubicPath, &valueToPixelMatrix, CGFloat(prev.xIndex) + prevDx, (CGFloat(prev.value) + prevDy) * phaseY,
                    CGFloat(cur.xIndex) - curDx,
                    (CGFloat(cur.value) - curDy) * phaseY, CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY)
            }
            
            if (size > entryCount - 1)
            {
                prevPrev = dataSet.entryForIndex(entryCount - (entryCount >= 3 ? 3 : 2))
                prev = dataSet.entryForIndex(entryCount - 2)
                cur = dataSet.entryForIndex(entryCount - 1)
                next = cur
                
                if prevPrev == nil || prev == nil || cur == nil { return }
                
                prevDx = CGFloat(cur.xIndex - prevPrev.xIndex) * intensity
                prevDy = CGFloat(cur.value - prevPrev.value) * intensity
                curDx = CGFloat(next.xIndex - prev.xIndex) * intensity
                curDy = CGFloat(next.value - prev.value) * intensity
                
                // the last cubic
                CGPathAddCurveToPoint(cubicPath, &valueToPixelMatrix, CGFloat(prev.xIndex) + prevDx, (CGFloat(prev.value) + prevDy) * phaseY,
                    CGFloat(cur.xIndex) - curDx,
                    (CGFloat(cur.value) - curDy) * phaseY, CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY)
            }
        }
        
        CGContextSaveGState(context)
        
        if (dataSet.isDrawFilledEnabled)
        {
            // Copy this path because we make changes to it
            let fillPath = CGPathCreateMutableCopy(cubicPath)
            
            drawCubicFill(context: context, dataSet: dataSet, spline: fillPath!, matrix: valueToPixelMatrix, from: minx, to: size)
        }
        
        CGContextBeginPath(context)
        CGContextAddPath(context, cubicPath)
        CGContextSetStrokeColorWithColor(context, drawingColor.CGColor)
        CGContextStrokePath(context)
        
        CGContextRestoreGState(context)
    }
    
    public func drawCubicFill(context context: CGContext, dataSet: ILineChartDataSet, spline: CGMutablePath, matrix: CGAffineTransform, from: Int, to: Int)
    {
        guard let dataProvider = dataProvider else { return }
        
        if to - from <= 1
        {
            return
        }
        // ModifySourceCode Add By LiXingLe
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
        
        if dataSet.fill != nil
        {
            drawFilledPath(context: context, path: spline, fill: dataSet.fill!, fillAlpha: dataSet.fillAlpha)
        }
        else
        {
            drawFilledPath(context: context, path: spline, fillColor: dataSet.fillColor, fillAlpha: dataSet.fillAlpha)
        }
    }
    
    //MARK: 填充曲线rangefill
    // ModifySourceCode Add By LiXingLe
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
            entryFrom:ChartDataEntry! = dataSet.fillLowerYValues[self.maxX],
            entryTo:ChartDataEntry! =  dataSet.fillLowerYValues[self.minX < 0 ? self.minX : 0]
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
            
            for (var j = min(size, entryCount - 1); j >= 1 ; j-- )
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
            //最低线的第一个lixingle
            var firstE:ChartDataEntry! = dataSet.fillLowerYValues[0]
            CGPathAddLineToPoint(spline, &valueToPixelMatrix, CGFloat(firstE.xIndex), CGFloat(firstE.value) * phaseY)
            
            
        }
        
        CGPathCloseSubpath(spline)
    }
    
    
    private var _lineSegments = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public func drawLinear(context context: CGContext, dataSet: ILineChartDataSet)
    {
        guard let
            trans = dataProvider?.getTransformer(dataSet.axisDependency),
            animator = animator
            else { return }
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        let entryCount = dataSet.entryCount
        let isDrawSteppedEnabled = dataSet.isDrawSteppedEnabled
        let pointsPerEntryPair = isDrawSteppedEnabled ? 4 : 2
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY

        guard let
            entryFrom = dataSet.entryForXIndex(self.minX < 0 ? self.minX : 0, rounding: .Down),
            entryTo = dataSet.entryForXIndex(self.maxX, rounding: .Up)
            else { return }
        
        let diff = (entryFrom == entryTo) ? 1 : 0
        let minx = max(dataSet.entryIndex(entry: entryFrom) - diff, 0)
        let maxx = min(max(minx + 2, dataSet.entryIndex(entry: entryTo) + 1), entryCount)
        
        CGContextSaveGState(context)
        
        CGContextSetLineCap(context, dataSet.lineCapType)

        // more than 1 color
        if (dataSet.colors.count > 1)
        {
            if (_lineSegments.count != pointsPerEntryPair)
            {
                _lineSegments = [CGPoint](count: pointsPerEntryPair, repeatedValue: CGPoint())
            }
            
            let count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
            for j in minx ..< count
            {
                if (count > 1 && j == count - 1)
                { // Last point, we have already drawn a line to this point
                    break
                }
                
                var e: ChartDataEntry! = dataSet.entryForIndex(j)
                
                if e == nil { continue }
                
                _lineSegments[0].x = CGFloat(e.xIndex)
                _lineSegments[0].y = CGFloat(e.value) * phaseY
                
                if (j + 1 < count)
                {
                    e = dataSet.entryForIndex(j + 1)
                    
                    if e == nil { break }
                    
                    if isDrawSteppedEnabled
                    {
                        _lineSegments[1] = CGPoint(x: CGFloat(e.xIndex), y: _lineSegments[0].y)
                        _lineSegments[2] = _lineSegments[1]
                        _lineSegments[3] = CGPoint(x: CGFloat(e.xIndex), y: CGFloat(e.value) * phaseY)
                    }
                    else
                    {
                        _lineSegments[1] = CGPoint(x: CGFloat(e.xIndex), y: CGFloat(e.value) * phaseY)
                    }
                }
                else
                {
                    _lineSegments[1] = _lineSegments[0]
                }

                for i in 0..<_lineSegments.count
                {
                    _lineSegments[i] = CGPointApplyAffineTransform(_lineSegments[i], valueToPixelMatrix)
                }
                
                if (!viewPortHandler.isInBoundsRight(_lineSegments[0].x))
                {
                    break
                }
                
                // make sure the lines don't do shitty things outside bounds
                if (!viewPortHandler.isInBoundsLeft(_lineSegments[1].x)
                    || (!viewPortHandler.isInBoundsTop(_lineSegments[0].y) && !viewPortHandler.isInBoundsBottom(_lineSegments[1].y))
                    || (!viewPortHandler.isInBoundsTop(_lineSegments[0].y) && !viewPortHandler.isInBoundsBottom(_lineSegments[1].y)))
                {
                    continue
                }
                
                // get the color that is set for this line-segment
                CGContextSetStrokeColorWithColor(context, dataSet.colorAt(j).CGColor)
                CGContextStrokeLineSegments(context, _lineSegments, pointsPerEntryPair)
            }
        }
        else
        { // only one color per dataset
            
            var e1: ChartDataEntry!
            var e2: ChartDataEntry!
            
            if (_lineSegments.count != max((entryCount - 1) * pointsPerEntryPair, pointsPerEntryPair))
            {
                _lineSegments = [CGPoint](count: max((entryCount - 1) * pointsPerEntryPair, pointsPerEntryPair), repeatedValue: CGPoint())
            }
            
            e1 = dataSet.entryForIndex(minx)
            
            if e1 != nil
            {
                let count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
                
                var j = 0
                for x in (count > 1 ? minx + 1 : minx) ..< count
                {
                    e1 = dataSet.entryForIndex(x == 0 ? 0 : (x - 1))
                    e2 = dataSet.entryForIndex(x)
                    
                    if e1 == nil || e2 == nil { continue }
                    
                    _lineSegments[j] = CGPointApplyAffineTransform(
                        CGPoint(
                            x: CGFloat(e1.xIndex),
                            y: CGFloat(e1.value) * phaseY
                        ), valueToPixelMatrix)
                    j += 1
                    
                    if isDrawSteppedEnabled
                    {
                        _lineSegments[j] = CGPointApplyAffineTransform(
                            CGPoint(
                                x: CGFloat(e2.xIndex),
                                y: CGFloat(e1.value) * phaseY
                            ), valueToPixelMatrix)
                        j += 1
                        
                        _lineSegments[j] = CGPointApplyAffineTransform(
                            CGPoint(
                                x: CGFloat(e2.xIndex),
                                y: CGFloat(e1.value) * phaseY
                            ), valueToPixelMatrix)
                        j += 1
                    }
                    
                    _lineSegments[j] = CGPointApplyAffineTransform(
                        CGPoint(
                            x: CGFloat(e2.xIndex),
                            y: CGFloat(e2.value) * phaseY
                        ), valueToPixelMatrix)
                    j += 1
                }
                
                let size = max((count - minx - 1) * pointsPerEntryPair, pointsPerEntryPair)
                CGContextSetStrokeColorWithColor(context, dataSet.colorAt(0).CGColor)
                CGContextStrokeLineSegments(context, _lineSegments, size)
            }
        }
        
        CGContextRestoreGState(context)
        
        // if drawing filled is enabled
        if (dataSet.isDrawFilledEnabled && entryCount > 0)
        {
            drawLinearFill(context: context, dataSet: dataSet, minx: minx, maxx: maxx, trans: trans)
        }
    }
    
    public func drawLinearFill(context context: CGContext, dataSet: ILineChartDataSet, minx: Int, maxx: Int, trans: ChartTransformer)
    {
        guard let dataProvider = dataProvider else { return }
        
        let filled = generateFilledPath(
            dataSet: dataSet,
            fillMin: dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0,
            from: minx,
            to: maxx,
            matrix: trans.valueToPixelMatrix)
        
        if dataSet.fill != nil
        {
            drawFilledPath(context: context, path: filled, fill: dataSet.fill!, fillAlpha: dataSet.fillAlpha)
        }
        else
        {
            drawFilledPath(context: context, path: filled, fillColor: dataSet.fillColor, fillAlpha: dataSet.fillAlpha)
        }
    }
    
    /// Generates the path that is used for filled drawing.
    private func generateFilledPath(dataSet dataSet: ILineChartDataSet, fillMin: CGFloat, from: Int, to: Int, matrix: CGAffineTransform) -> CGPath
    {
        let phaseX = animator?.phaseX ?? 1.0
        let phaseY = animator?.phaseY ?? 1.0
        let isDrawSteppedEnabled = dataSet.isDrawSteppedEnabled
        var matrix = matrix
        
        var e: ChartDataEntry!
        
        let filled = CGPathCreateMutable()
        
        e = dataSet.entryForIndex(from)
        if e != nil
        {
            CGPathMoveToPoint(filled, &matrix, CGFloat(e.xIndex), fillMin)
            CGPathAddLineToPoint(filled, &matrix, CGFloat(e.xIndex), CGFloat(e.value) * phaseY)
        }
        
        // create a new path
        for x in (from + 1).stride(to: Int(ceil(CGFloat(to - from) * phaseX + CGFloat(from))), by: 1)
        {
            guard let e = dataSet.entryForIndex(x) else { continue }
            
            if isDrawSteppedEnabled
            {
                guard let ePrev = dataSet.entryForIndex(x-1) else { continue }
                CGPathAddLineToPoint(filled, &matrix, CGFloat(e.xIndex), CGFloat(ePrev.value) * phaseY)
            }
            
            CGPathAddLineToPoint(filled, &matrix, CGFloat(e.xIndex), CGFloat(e.value) * phaseY)
        }
        
        // close up
        e = dataSet.entryForIndex(max(min(Int(ceil(CGFloat(to - from) * phaseX + CGFloat(from))) - 1, dataSet.entryCount - 1), 0))
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
        CGPathCloseSubpath(filled)
        
        return filled
    }
    
    public override func drawValues(context context: CGContext)
    {
        guard let
            dataProvider = dataProvider,
            lineData = dataProvider.lineData,
            animator = animator
            else { return }
        
        if (CGFloat(lineData.yValCount) < CGFloat(dataProvider.maxVisibleValueCount) * viewPortHandler.scaleX)
        {
            var dataSets = lineData.dataSets
            
            let phaseX = animator.phaseX
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in 0 ..< dataSets.count
            {
                guard let dataSet = dataSets[i] as? ILineChartDataSet else { continue }
                
                if !dataSet.isDrawValuesEnabled || dataSet.entryCount == 0
                {
                    continue
                }
                
                let valueFont = dataSet.valueFont
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                let trans = dataProvider.getTransformer(dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                // make sure the values do not interfear with the circles
                var valOffset = Int(dataSet.circleRadius * 1.75)
                
                if (!dataSet.isDrawCirclesEnabled)
                {
                    valOffset = valOffset / 2
                }
                
                let entryCount = dataSet.entryCount
                
                guard let
                    entryFrom = dataSet.entryForXIndex(self.minX < 0 ? self.minX : 0, rounding: .Down),
                    entryTo = dataSet.entryForXIndex(self.maxX, rounding: .Up)
                    else { continue }
                
                let diff = (entryFrom == entryTo) ? 1 : 0
                let minx = max(dataSet.entryIndex(entry: entryFrom) - diff, 0)
                let maxx = min(max(minx + 2, dataSet.entryIndex(entry: entryTo) + 1), entryCount)
                
                for j in minx ..< Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
                {
                    guard let e = dataSet.entryForIndex(j) else { break }
                    
                    pt.x = CGFloat(e.xIndex)
                    pt.y = CGFloat(e.value) * phaseY
                    pt = CGPointApplyAffineTransform(pt, valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }
                    
                    if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
                    {
                        continue
                    }
                    
                    ChartUtils.drawText(context: context,
                        text: formatter.stringFromNumber(e.value)!,
                        point: CGPoint(
                            x: pt.x,
                            y: pt.y - CGFloat(valOffset) - valueFont.lineHeight),
                        align: .Center,
                        attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)])
                }
            }
        }
    }
    
    public override func drawExtras(context context: CGContext)
    {
        drawCircles(context: context)
    }
    
    private func drawCircles(context context: CGContext)
    {
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
            
            if !dataSet.isVisible || !dataSet.isDrawCirclesEnabled || dataSet.entryCount == 0
            {
                continue
            }
            
            let trans = dataProvider.getTransformer(dataSet.axisDependency)
            let valueToPixelMatrix = trans.valueToPixelMatrix
            
            let entryCount = dataSet.entryCount
            
            let circleRadius = dataSet.circleRadius
            let circleDiameter = circleRadius * 2.0
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
                
                rect.origin.x = pt.x - circleRadius
                rect.origin.y = pt.y - circleRadius
                rect.size.width = circleDiameter
                rect.size.height = circleDiameter
                CGContextFillEllipseInRect(context, rect)
                
                if (isDrawCircleHoleEnabled)
                {
                    CGContextSetFillColorWithColor(context, dataSet.circleHoleColor.CGColor)
                    
                    rect.origin.x = pt.x - circleHoleRadius
                    rect.origin.y = pt.y - circleHoleRadius
                    rect.size.width = circleHoleDiameter
                    rect.size.height = circleHoleDiameter
                    CGContextFillEllipseInRect(context, rect)
                }
            }
        }
        
        CGContextRestoreGState(context)
    }
    //绘制高亮数据点
    // ModifySourceCode Add By LiXingLe
    public override func drawCircleIndex(context context: CGContext , indices: [ChartHighlight]) {
        guard let
            dataProvider = dataProvider,
            lineData = dataProvider.lineData,
            animator = animator
            else { return }
        
        if indices.count <= 0 {
            return
        }
        
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
                
                if  indices[0].xIndex != j {
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
                
                var hImage = dataSet.highlightImage
                hImage.drawInRect(CGRectMake(pt.x - circleRadius, pt.y - circleRadius, circleRadius*2, circleRadius*2))
                //lower 高亮点
                if dataSet.drawRangeFilledEnabled {
                    var lowPt = CGPoint()
                    let lowE:ChartDataEntry? = dataSet.fillLowerYValues[j]
                    lowPt.x = CGFloat(e.xIndex)
                    lowPt.y = CGFloat(lowE?.value ?? 0.0) * phaseY
                    lowPt = CGPointApplyAffineTransform(lowPt, valueToPixelMatrix)
                    var lowImage = dataSet.lowerHighlightImage
                    lowImage.drawInRect(CGRectMake(lowPt.x - circleRadius, lowPt.y - circleRadius, circleRadius*2, circleRadius*2))
                    
                }
                /*
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
                */
                
            }
        }
        
        CGContextRestoreGState(context)
    
    
    }
    
    
    private var _highlightPointBuffer = CGPoint()
    
    public override func drawHighlighted(context context: CGContext, indices: [ChartHighlight])
    {
        guard let
            lineData = dataProvider?.lineData,
            chartXMax = dataProvider?.chartXMax,
            animator = animator
            else { return }
        
        CGContextSaveGState(context)
        
        for i in 0 ..< indices.count
        {
            guard let set = lineData.getDataSetByIndex(indices[i].dataSetIndex) as? ILineChartDataSet else { continue }
            
            if !set.isHighlightEnabled
            {
                continue
            }
            
            CGContextSetStrokeColorWithColor(context, set.highlightColor.CGColor)
            CGContextSetLineWidth(context, set.highlightLineWidth)
            if (set.highlightLineDashLengths != nil)
            {
                CGContextSetLineDash(context, set.highlightLineDashPhase, set.highlightLineDashLengths!, set.highlightLineDashLengths!.count)
            }
            else
            {
                CGContextSetLineDash(context, 0.0, nil, 0)
            }
            
            let xIndex = indices[i].xIndex; // get the x-position
            
            if (CGFloat(xIndex) > CGFloat(chartXMax) * animator.phaseX)
            {
                continue
            }
            
            let yValue = set.yValForXIndex(xIndex)
            if (yValue.isNaN)
            {
                continue
            }
            
            let y = CGFloat(yValue) * animator.phaseY; // get the y-position
            
            _highlightPointBuffer.x = CGFloat(xIndex)
            _highlightPointBuffer.y = y
            
            let trans = dataProvider?.getTransformer(set.axisDependency)
            
            trans?.pointValueToPixel(&_highlightPointBuffer)
            
            // draw the lines
            drawHighlightLines(context: context, point: _highlightPointBuffer, set: set)
        }
        
        CGContextRestoreGState(context)
    }
}
//
//  LineScatterCandleRadarChartRenderer.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 29/7/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics


public class LineScatterCandleRadarChartRenderer: ChartDataRendererBase
{
    public override init(animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
    }
    
    /// Draws vertical & horizontal highlight-lines if enabled.
    /// :param: context
    /// :param: points
    /// :param: horizontal
    /// :param: vertical
    public func drawHighlightLines(context context: CGContext, point: CGPoint, set: ILineScatterCandleRadarChartDataSet)
    {
        // draw vertical highlight lines 
        //ModifySourceCode update By LiXingLe
        if set.isVerticalHighlightIndicatorEnabled
        {
//            CGContextBeginPath(context)
//            CGContextMoveToPoint(context, point.x, viewPortHandler.contentTop)
//            CGContextAddLineToPoint(context, point.x, viewPortHandler.contentBottom)
//            CGContextStrokePath(context)
            
            //方案一
            CGContextSaveGState(context);
            UIColor.whiteColor().setFill()
            let path = UIBezierPath(ovalInRect: CGRect(x: point.x-1.5/2.0, y: 5.0, width: 1.5, height: viewPortHandler.contentBottom - viewPortHandler.contentTop-10.0))
            path.lineWidth = 0.1
            path.fill()
            CGContextRestoreGState( context );
        }
        
        // draw horizontal highlight lines
        if set.isHorizontalHighlightIndicatorEnabled
        {
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, viewPortHandler.contentLeft, point.y)
            CGContextAddLineToPoint(context, viewPortHandler.contentRight, point.y)
            CGContextStrokePath(context)
        }
    }
}
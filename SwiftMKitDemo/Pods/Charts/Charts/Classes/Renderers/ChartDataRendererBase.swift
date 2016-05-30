//
//  ChartDataRendererBase.swift
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

public class ChartDataRendererBase: ChartRendererBase
{
    public var animator: ChartAnimator?
    
    public init(animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(viewPortHandler: viewPortHandler)
        
        self.animator = animator
    }

    public func drawData(context context: CGContext)
    {
        fatalError("drawData() cannot be called on ChartDataRendererBase")
    }
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
    
    public func drawValues(context context: CGContext)
    {
        fatalError("drawValues() cannot be called on ChartDataRendererBase")
    }
    
    public func drawExtras(context context: CGContext)
    {
        fatalError("drawExtras() cannot be called on ChartDataRendererBase")
    }
    
    /// Draws all highlight indicators for the values that are currently highlighted.
    ///
    /// - parameter indices: the highlighted values
    public func drawHighlighted(context context: CGContext, indices: [ChartHighlight])
    {
        fatalError("drawHighlighted() cannot be called on ChartDataRendererBase")
    }
    // ModifySourceCode Add By LiXingLe  绘制高亮圆点
    public func drawCircleIndex(context context: CGContext, indices: [ChartHighlight]) {
    
    }
    
}
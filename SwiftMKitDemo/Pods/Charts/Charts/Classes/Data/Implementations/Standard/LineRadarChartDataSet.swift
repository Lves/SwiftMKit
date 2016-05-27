//
//  LineRadarChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics


public class LineRadarChartDataSet: LineScatterCandleRadarChartDataSet, ILineRadarChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// The color that is used for filling the line surface area.
    private var _fillColor = NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    /// The color that is used for filling the line surface area.
    public var fillColor: NSUIColor
    {
        get { return _fillColor }
        set
        {
            _fillColor = newValue
            fill = nil
        }
    }
    
    /// The object that is used for filling the area below the line.
    /// **default**: nil
    public var fill: ChartFill?
    
    /// The alpha value that is used for filling the line surface,
    /// **default**: 0.33
    public var fillAlpha = CGFloat(0.33)
    
    private var _lineWidth = CGFloat(1.0)
    
    /// line width of the chart (min = 0.2, max = 10)
    ///
    /// **default**: 1
    public var lineWidth: CGFloat
    {
        get
        {
            return _lineWidth
        }
        set
        {
            if (newValue < 0.2)
            {
                _lineWidth = 0.2
            }
            else if (newValue > 10.0)
            {
                _lineWidth = 10.0
            }
            else
            {
                _lineWidth = newValue
            }
        }
    }
    
    /// Set to true if the DataSet should be drawn filled (surface), and not just as a line.
    /// Disabling this will give great performance boost.
    /// Please note that this method uses the path clipping for drawing the filled area (with images, gradients and layers).
    public var drawFilledEnabled = false
   
    //ModifySourceCode Add By LiXingLe
    //是否RangeFill
    public var drawRangeFilledEnabled = false
    //fillRange的较低值
    public var fillLowerYValues:[ChartDataEntry] = []
    //实现高亮点类型
    public var form: ChartDataForm = .Circle
    //Finish add
    
    /// Returns true if filled drawing is enabled, false if not
    public var isDrawFilledEnabled: Bool
    {
        return drawFilledEnabled
    }
    
    public var isDrawRangeFilledEnabled: Bool
    {
        return drawRangeFilledEnabled
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! LineRadarChartDataSet
        copy.fillColor = fillColor
        copy._lineWidth = _lineWidth
        copy.drawFilledEnabled = drawFilledEnabled
        copy.drawRangeFilledEnabled = drawRangeFilledEnabled
        return copy
    }
    
}

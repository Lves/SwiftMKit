//
//  RangeSliderThumbLayer.swift
//  CustomControl
//
//  Created by chenyh on 16/7/4.
//  Copyright © 2016年 chenyh. All rights reserved.
//

import UIKit
import QuartzCore

/// Range slider track layer. Responsible for drawing the horizontal track
public class RangeSliderTrackLayer: CALayer {
    
    /// owner slider
    weak var rangeSlider: RangeSlider?
    
    /// draw the track between 2 thumbs
    ///
    /// - Parameter ctx: current graphics context
    override public func drawInContext(ctx: CGContext) {
        if let slider = rangeSlider {
            // Clip
            var orgRect = bounds
            if slider.trackHeight > 0 {
                orgRect.y = orgRect.y + (orgRect.h - slider.trackHeight)/2
                orgRect.h = slider.trackHeight
            }
            let cornerRadius = orgRect.height * slider.curvaceousness / 2.0
            let path = UIBezierPath(roundedRect: orgRect, cornerRadius: cornerRadius)
            CGContextAddPath(ctx, path.CGPath)
        
            // Fill the track
            CGContextSetFillColorWithColor(ctx, slider.trackTintColor.CGColor)
            CGContextAddPath(ctx, path.CGPath)
            CGContextFillPath(ctx)
        
            let lowerValuePosition = CGFloat(slider.positionForValue(slider.lowerValue))
            let upperValuePosition = CGFloat(slider.positionForValue(slider.upperValue))
            
            // Fill the lower track range
            CGContextSetFillColorWithColor(ctx, slider.lowerTrackHighlightTintColor.CGColor)
            let lowerRect = CGRect(x: 0.0 , y: orgRect.y, width: lowerValuePosition - 0, height: orgRect.height)
            let lowerPath = UIBezierPath(roundedRect: lowerRect, cornerRadius: cornerRadius)
            CGContextAddPath(ctx, lowerPath.CGPath)
            CGContextFillPath(ctx)
            
            // Fill the upper track range
            CGContextSetFillColorWithColor(ctx, slider.upperTrackHighlightTintColor.CGColor)
            let upperRect = CGRect(x: upperValuePosition, y: orgRect.y, width: orgRect.width - upperValuePosition, height: orgRect.height)
            let upperPath = UIBezierPath(roundedRect: upperRect, cornerRadius: cornerRadius)
            CGContextAddPath(ctx, upperPath.CGPath)
            CGContextFillPath(ctx)
            
            // Fill the highlighted range
            CGContextSetFillColorWithColor(ctx, slider.trackHighlightTintColor.CGColor)
            let rect = CGRect(x: lowerValuePosition, y: orgRect.y, width: upperValuePosition - lowerValuePosition, height: orgRect.height)
            CGContextFillRect(ctx, rect)
        }
    }
}

public class RangeSliderThumbLayer: CALayer {
    
    /// owner slider
    weak var rangeSlider: RangeSlider?
    
    /// whether this thumb is currently highlighted i.e. touched by user
    public var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// stroke color
    public var strokeColor: UIColor = UIColor.grayColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// line width
    public var lineWidth: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// image
    public var image: UIImage?{
        didSet {
            setNeedsDisplay()
        }
    }
    
    override public func drawInContext(ctx: CGContext) {
    // Clip
        
        if let slider = rangeSlider {
            // clip
            
            let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
            let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
            let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
            
            // Image
            if image != nil {
                CGContextSaveGState(ctx)
                CGContextTranslateCTM(ctx, 0, image!.size.height)
                CGContextScaleCTM(ctx, 1.0, -1.0)
                CGContextDrawImage(ctx, CGRect(x: (bounds.w - image!.size.width)/2, y: -(bounds.h - image!.size.height)/2, w: image!.size.width, h: image!.size.height), image!.CGImage!)
                CGContextRestoreGState(ctx)
            }else{
                // Fill
                CGContextSetFillColorWithColor(ctx, slider.thumbTintColor.CGColor)
                CGContextAddPath(ctx, thumbPath.CGPath)
                CGContextFillPath(ctx)
                
                // Outline
                CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor)
                CGContextSetLineWidth(ctx, lineWidth)
                CGContextAddPath(ctx, thumbPath.CGPath)
                CGContextStrokePath(ctx)
            }
            
            if highlighted {
                CGContextSetFillColorWithColor(ctx, UIColor(white: 0.0, alpha: 0.1).CGColor)
                CGContextAddPath(ctx, thumbPath.CGPath)
                CGContextFillPath(ctx)
            }
        }
    }
}

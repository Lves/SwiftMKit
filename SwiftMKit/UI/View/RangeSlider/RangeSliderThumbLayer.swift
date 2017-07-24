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
    override public func draw(in ctx: CGContext) {
        if let slider = rangeSlider {
            // Clip
            var orgRect = bounds
            if slider.trackHeight > 0 {
                orgRect.y = orgRect.y + (orgRect.h - slider.trackHeight)/2
                orgRect.h = slider.trackHeight
            }
            let cornerRadius = orgRect.height * slider.curvaceousness / 2.0
            let path = UIBezierPath(roundedRect: orgRect, cornerRadius: cornerRadius)
            ctx.addPath(path.cgPath)
        
            // Fill the track
            ctx.setFillColor(slider.trackTintColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        
            let lowerValuePosition = CGFloat(slider.positionForValue(value: slider.lowerValue))
            let upperValuePosition = CGFloat(slider.positionForValue(value: slider.upperValue))
            
            // Fill the lower track range
            ctx.setFillColor(slider.lowerTrackHighlightTintColor.cgColor)
            let lowerRect = CGRect(x: 0.0 , y: orgRect.y, width: lowerValuePosition - 0, height: orgRect.height)
            let lowerPath = UIBezierPath(roundedRect: lowerRect, cornerRadius: cornerRadius)
            ctx.addPath(lowerPath.cgPath)
            ctx.fillPath()
            
            // Fill the upper track range
            ctx.setFillColor(slider.upperTrackHighlightTintColor.cgColor)
            let upperRect = CGRect(x: upperValuePosition, y: orgRect.y, width: orgRect.width - upperValuePosition, height: orgRect.height)
            let upperPath = UIBezierPath(roundedRect: upperRect, cornerRadius: cornerRadius)
            ctx.addPath(upperPath.cgPath)
            ctx.fillPath()
            
            // Fill the highlighted range
            ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
            let rect = CGRect(x: lowerValuePosition, y: orgRect.y, width: upperValuePosition - lowerValuePosition, height: orgRect.height)
            ctx.fill(rect)
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
    public var strokeColor: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// highlightedColor color
    public var highlightedColor: UIColor = UIColor(white: 0.0, alpha: 0.1) {
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
    
    override public func draw(in ctx: CGContext) {
    // Clip
        if let slider = rangeSlider {
            // clip
            
            let thumbFrame = bounds.insetBy(dx: 0.0, dy: 0.0)
            let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
            let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
            
            // Image
            if image != nil {
                ctx.saveGState()
                ctx.translateBy(x: 0, y: image!.size.height)
                ctx.scaleBy(x: 1.0, y: -1.0)
                ctx.draw(image!.cgImage!, in: CGRect(x: (bounds.w - image!.size.width)/2, y: -(bounds.h - image!.size.height)/2, w: image!.size.width, h: image!.size.height))
                ctx.restoreGState()
            }else{
                // Fill
                ctx.setFillColor(slider.thumbTintColor.cgColor)
                ctx.addPath(thumbPath.cgPath)
                ctx.fillPath()
                
                // Outline
                ctx.setStrokeColor(strokeColor.cgColor)
                ctx.setLineWidth(lineWidth)
                ctx.addPath(thumbPath.cgPath)
                ctx.strokePath()
            }
            
            if highlighted {
                ctx.setFillColor(highlightedColor.cgColor)
                ctx.addPath(thumbPath.cgPath)
                ctx.fillPath()
            }
        }
    }
}

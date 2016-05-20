//
//  MKChartMarker.swift
//  SwiftMKitDemo
//
//  Created by LiXingLe on 16/5/16.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import CoreGraphics
import Foundation
import Charts

class MKChartMarker: ChartMarker {

    var font: UIFont?
    private var labelns: NSString?
    private var subLabelns: NSString?
    private var _labelSize: CGSize = CGSize()
    private var _subLabelSize: CGSize = CGSize()
    private var _size: CGSize = CGSize()
    private var _paragraphStyle: NSMutableParagraphStyle?
    private var _drawAttributes = [String : AnyObject]()
    private var _subDrawAttributes = [String : AnyObject]()
    
    
    var data: ChartData?
    
    
    var leftImage: NSUIImage?
    
    init(font: UIFont , data: ChartData?)
    {
        super.init()
        
        self.font = font
        self.data = data
        
        _paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .Center
    }
    
    
    override func draw(context context: CGContext, point: CGPoint)
    {
        
        
        let offset = self.offsetForDrawingAtPos(point)
        var size = _labelSize
        
        size = CGSizeMake(size.width+20, 40.0)
    
        UIGraphicsPushContext(context)
        var rect = CGRectZero
        if point.x > UIScreen.mainScreen().bounds.size.width/2.0 {
            rect = CGRect(x: point.x + offset.x - size.width, y: point.y - size.height/2.0, width: size.width, height: size.height)
            leftImage!.drawInRect(rect)
            rect.origin.x -= 2.0
            
        }else{
            rect = CGRect(x: point.x + offset.x, y: point.y - size.height/2.0, width: size.width, height: size.height)
            image!.drawInRect(rect)
            rect.origin.x += 2.0
        }
        
        if data != nil{
            
            let offsetX = point.x > UIScreen.mainScreen().bounds.size.width/2.0 ? -size.width : 0.0
            
            let topRect = CGRect(x: point.x + offset.x + offsetX, y: point.y - self.font!.pointSize-5.0, width: size.width, height: self.font!.pointSize)
            labelns?.drawInRect(topRect, withAttributes: _drawAttributes)
            
            let bottomRect = CGRect(x: point.x + offset.x + offsetX, y: point.y + 2.0  , width: size.width, height: self.font!.pointSize)
            subLabelns?.drawInRect(bottomRect, withAttributes: _subDrawAttributes)
            
            
        }else{
            rect.origin.y += (size.height - self.font!.pointSize)/2.0
            labelns?.drawInRect(rect, withAttributes: _drawAttributes)
        }
        
        
        
        UIGraphicsPopContext()

    }
    
    override func refreshContent(entry entry: ChartDataEntry, highlight: ChartHighlight)
    {
        let label = entry.value.description
        labelns = label as NSString
        labelns = labelns?.stringByAppendingString("%")
        
        if let sets = data?.dataSets {
            for index in 0..<sets.count {
                let set = sets[index]
                let nextEntry = set.entryForIndex(highlight.xIndex)
                let value = nextEntry!.value.description
                if 1 == index {
                    labelns = value as NSString
                    labelns = labelns?.stringByAppendingString("%")
                }else {
                    subLabelns = value as NSString
                    subLabelns = subLabelns?.stringByAppendingString("%")
                }
                
                
            }
            
        }
        
        
        _drawAttributes.removeAll()
        _drawAttributes[NSFontAttributeName] = self.font
        _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
        _labelSize = labelns?.sizeWithAttributes(_drawAttributes) ?? CGSizeZero
        
        _subDrawAttributes.removeAll()
        _subDrawAttributes[NSFontAttributeName] = self.font
        _subDrawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
        _subLabelSize = subLabelns?.sizeWithAttributes(_subDrawAttributes) ?? CGSizeZero

    }
}

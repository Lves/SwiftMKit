//
//  MKMultipleChartMarker.swift
//  SwiftMKitDemo
//
//  Created by LiXingLe on 16/5/20.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import CoreGraphics
import Foundation
import Charts

class MKMultipleChartMarker: ChartMarker {
    var font: UIFont?

    //圆的半径
    let circleR:CGFloat = 4.0
    let textMargin:CGFloat = 5.0
    
    //title
    private var titleLabelns: NSString?
    private var _titleLabelSize: CGSize = CGSize()
    private var _titleDrawAttributes = [String : AnyObject]()
    
    //top
    private var labelns: NSString?
    private var _labelSize: CGSize = CGSize()
    private var _drawAttributes = [String : AnyObject]()
    
    //bottom
    private var _subDrawAttributes = [String : AnyObject]()
    private var subLabelns: NSString?
    private var _subLabelSize: CGSize = CGSize()

    
    private var _size: CGSize = CGSize()
    private var _paragraphStyle: NSMutableParagraphStyle?
    
    
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
        var size = _labelSize.width > _subLabelSize.width ?  _labelSize : _subLabelSize
        
        size = CGSizeMake(size.width+2*circleR + textMargin + 35, 60.0)
        
        
        let offsetX = point.x > UIScreen.mainScreen().bounds.size.width/2.0 ? -size.width : 0.0
        
//        CGContextSaveGState(context)
        UIGraphicsPushContext(context)
        var rect = CGRectZero
        var isLeft = false
        if point.x > UIScreen.mainScreen().bounds.size.width/2.0 {
            rect = CGRect(x: point.x + offset.x - size.width, y: point.y - size.height/2.0, width: size.width, height: size.height)
            leftImage!.drawInRect(rect)
            rect.origin.x -= 2.0
            
        }else{
            rect = CGRect(x: point.x + offset.x, y: point.y - size.height/2.0, width: size.width, height: size.height)
            image!.drawInRect(rect)
            rect.origin.x += 2.0
            isLeft = true
        }
        
        if data != nil{
            
            let circleX = point.x + offset.x + offsetX + ( isLeft ? 30 : 15)
            let titleX  = circleX + circleR + textMargin
            
            //1.0 title
            let titleRect  = CGRect(x: titleX, y: point.y - self.font!.pointSize*2 - 5.0 , width: _titleLabelSize.width, height: _titleLabelSize.height)
            titleLabelns?.drawInRect(titleRect, withAttributes: _titleDrawAttributes)
            
            //2.0 绘制第一个圆
            
            CGContextSetFillColorWithColor(context, _drawAttributes[NSForegroundColorAttributeName]!.CGColor)
            
            CGContextAddArc(context, circleX, point.y - _labelSize.height + _labelSize.height/2.0, circleR, 0, (CGFloat)(2.0*M_PI), 0)
            CGContextDrawPath(context, .Fill)
            
            //2.1 top
            let topRect = CGRect(x: titleX, y: point.y - _labelSize.height, width: _labelSize.width, height: _labelSize.height)
            labelns?.drawInRect(topRect, withAttributes: _drawAttributes)
            
            
            //3.0 绘制第二个圆
            CGContextSetFillColorWithColor(context, _subDrawAttributes[NSForegroundColorAttributeName]!.CGColor)

            CGContextAddArc(context, circleX, point.y + 5.0 + _labelSize.height/2.0, circleR, 0, (CGFloat)(2.0*M_PI), 0)
            CGContextDrawPath(context, .Fill)
            
            //3.1 bottom
            let bottomRect = CGRect(x: titleX, y: point.y + 5.0  , width: _subLabelSize.width, height: _subLabelSize.height)
            subLabelns?.drawInRect(bottomRect, withAttributes: _subDrawAttributes)
            
            
        }else{
            rect.origin.y += (size.height - self.font!.pointSize)/2.0
            labelns?.drawInRect(rect, withAttributes: _drawAttributes)
        }
        
        UIGraphicsPopContext()

//        CGContextRestoreGState(context)
        
    }
    
    override func refreshContent(entry entry: ChartDataEntry, highlight: ChartHighlight)
    {
        
        _titleDrawAttributes.removeAll()
        _titleDrawAttributes[NSFontAttributeName] = self.font
        _titleDrawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
       
        
        
        _drawAttributes.removeAll()
        _drawAttributes[NSFontAttributeName] = self.font
        _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
       
        
        _subDrawAttributes.removeAll()
        _subDrawAttributes[NSFontAttributeName] = self.font
        _subDrawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
        
        

        
        
        
        
        let label = entry.value.description
        labelns = label as NSString
        labelns = labelns?.stringByAppendingString("%")
        
        if let sets = data?.dataSets {
            
            let xValues = data?.xVals[highlight.xIndex]
            titleLabelns = xValues! as NSString
            _titleLabelSize = titleLabelns?.sizeWithAttributes(_titleDrawAttributes) ?? CGSizeZero
            
            
            for index in 0..<sets.count {
                let set = sets[index]
                
                let nextEntry = set.entryForIndex(highlight.xIndex)
                let value = nextEntry!.value.description
                
                if 1 == index {
                    _drawAttributes[NSForegroundColorAttributeName] = set.colorAt(highlight.xIndex)
                    labelns = "\(set.label! as NSString) \(value as NSString)%"
                }else if 0 == index  {
                    _subDrawAttributes[NSForegroundColorAttributeName] = set.colorAt(highlight.xIndex)
                    subLabelns = "\(set.label! as NSString) \(value as NSString)%"
                }
            }
            
        }
        
        _labelSize = labelns?.sizeWithAttributes(_drawAttributes) ?? CGSizeZero
        _subLabelSize = subLabelns?.sizeWithAttributes(_subDrawAttributes) ?? CGSizeZero
        
        
        
    }

}

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
//    public var color: UIColor?
//    public var arrowSize = CGSize(width: 15, height: 11)
    var font: UIFont?
//    public var insets = UIEdgeInsets()
//    public var minimumSize = CGSize()
    
    private var labelns: NSString?
    private var _labelSize: CGSize = CGSize()
    private var _size: CGSize = CGSize()
    private var _paragraphStyle: NSMutableParagraphStyle?
    private var _drawAttributes = [String : AnyObject]()
    
    
    var leftImage: NSUIImage?
    
    init(color: UIColor, font: UIFont, insets: UIEdgeInsets)
    {
        super.init()
        
//        self.color = color
        self.font = font
//        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .Center
    }
    
//    public override var size: CGSize { return _size; }
    
    override func draw(context context: CGContext, point: CGPoint)
    {
        
        
        let offset = self.offsetForDrawingAtPos(point)
        let size = self.size
    
        UIGraphicsPushContext(context)
        var rect = CGRectZero
        if point.x > UIScreen.mainScreen().bounds.size.width/2.0 {
            rect = CGRect(x: point.x + offset.x - size.width, y: point.y - size.height/2.0, width: size.width, height: size.height)
            leftImage!.drawInRect(rect)
        }else{
            rect = CGRect(x: point.x + offset.x, y: point.y - size.height/2.0, width: size.width, height: size.height)
            image!.drawInRect(rect)
        }
        
        rect.origin.y += (size.height - self.font!.pointSize)/2.0
        labelns?.drawInRect(rect, withAttributes: _drawAttributes)
        UIGraphicsPopContext()


    }
    
    override func refreshContent(entry entry: ChartDataEntry, highlight: ChartHighlight)
    {
        let label = entry.value.description
        labelns = label as NSString
        
        _drawAttributes.removeAll()
        _drawAttributes[NSFontAttributeName] = self.font
        _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
        
        _labelSize = labelns?.sizeWithAttributes(_drawAttributes) ?? CGSizeZero
//        _size.width = _labelSize.width + self.insets.left + self.insets.right
//        _size.height = _labelSize.height + self.insets.top + self.insets.bottom
//        _size.width = max(minimumSize.width, _size.width)
//        _size.height = max(minimumSize.height, _size.height)
    }
}

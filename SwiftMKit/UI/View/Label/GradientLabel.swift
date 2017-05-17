//
//  GradientLabel.swift
//  Merak
//
//  Created by HeLi on 17/5/12.
//  Copyright © 2017年 jimubox. All rights reserved.
//

import Foundation

class GradientLabel : UILabel {
    
    var colors : [UIColor] = [] {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var locations : [CGFloat] = [0.0,1.0] {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let textRect : CGRect = (self.text?.toNSString.boundingRectWithSize(rect.size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : self.font], context: nil))!
        let textSize : CGSize = textRect.size
        
        //1. 把label的文字画到context上去(画文字的作用主要是设置 layer 的mask)
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        self.textColor.set()
        self.text?.toNSString.drawWithRect(rect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : self.font], context: nil)

        //2. 设置mask:CGContextClipToMask(context, rect, alphaMask); 并清除文字
        CGContextTranslateCTM(context, 0.0, rect.size.height - (rect.size.height - textSize.height)*0.5)
        CGContextScaleCTM(context, 1.0, -1.0)
        let alphaMask : CGImageRef = CGBitmapContextCreateImage(context)!
        CGContextClearRect(context, rect)// 清除之前画的文字
        CGContextClipToMask(context, rect, alphaMask)
        
        //3. 翻转坐标, 画渐变色
        /*
         *第一个参数：颜色空间
         *第二个参数：CGFloat数组，指定渐变的开始颜色，终止颜色，以及过度色（如果有的话）
         *第三个参数：指定每个颜色在渐变色中的位置，值介于0.0-1.0之间
         *          0.0表示最开始的位置，1.0表示渐变结束的位置
         *第四个参数：渐变中使用的颜色数 
         */
        let colorSpace : CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let gradient : CGGradientRef = CGGradientCreateWithColors(colorSpace, colors.map {(color: UIColor!) -> AnyObject! in return color.CGColor as AnyObject! } as NSArray, locations)!
        let startPoint : CGPoint = CGPointMake(textRect.origin.x, textRect.origin.y)
        let endPoint : CGPoint = CGPointMake(textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, [CGGradientDrawingOptions.DrawsBeforeStartLocation, CGGradientDrawingOptions.DrawsAfterEndLocation])
    }
}

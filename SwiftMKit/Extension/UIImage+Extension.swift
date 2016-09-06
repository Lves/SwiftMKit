//
//  UIImage+Extension.swift
//  Merak
//
//  Created by Mao on 6/8/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image.CGImage else { return nil }
        self.init(CGImage: cgImage)
    }
    
    /**
     UIImage 占用内存大小
     
     - returns:占用内存大小
     */
    public func getImageSize() -> Int {
        return CGImageGetHeight(self.CGImage) * CGImageGetBytesPerRow(self.CGImage)
    }
    
    /**
     图片上绘制文字
     
     - parameter drawText: 文字内容
     - parameter textColor: 文字颜色
     - parameter textFont:  文字字体
     - parameter atPoint:   文字位置
     
     - returns: 返回图片
     */
    func textToImage(drawText: NSString, textColor: UIColor, textFont: UIFont, atPoint: CGPoint) -> UIImage {
        
        // Setup the font specific variables
        
        // Setup the image context using the passed image
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ]
        
        // Put the image into a rectangle as large as the original image
        self.drawInRect(CGRectMake(0, 0, self.size.width, self.size.height))
        
        // Create a point within the space that is as bit as the image
        let rect = CGRectMake(atPoint.x, atPoint.y, self.size.width, self.size.height)
        
        // Draw the text into an image
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage
        
    }
}
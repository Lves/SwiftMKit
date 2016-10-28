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
    
    
    /**
     压缩图片
     */
    func restrict(maxWidth maxWidth: CGFloat, maxHeight: CGFloat, maxSize: Int) -> NSData? {
        //先调整分辨率
        var newSize = CGSize(width: self.size.width, height: self.size.height)
        
        let tempHeight = newSize.height / maxHeight
        let tempWidth  = newSize.width / maxWidth
        
        if tempWidth > 1.0 && tempWidth > tempHeight {
            newSize = CGSize(width: maxWidth, height: self.size.height / tempWidth)
        }
        else if tempHeight > 1.0 && tempWidth < tempHeight {
            newSize = CGSize(width: self.size.width / tempHeight, height: maxHeight)
        }
        
        UIGraphicsBeginImageContext(newSize)
        self.drawAsPatternInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return bSearch(newImage, count: 10, maxSize: maxSize)
    }
    
    func bSearch(image: UIImage, count: Int, maxSize: Int) -> NSData? {
        var low = CGFloat(0)
        var high = CGFloat(count)
        
        var mid = (low + high) / 2
        while high > low {
            if let imageData = UIImageJPEGRepresentation(image, mid/CGFloat(count)) {
                if Int(Int64(imageData.length)) > maxSize {
                    high = mid
                } else {
                    low = mid + 1
                }
                mid = (low + high) / 2
            }
        }
        return UIImageJPEGRepresentation(image, mid/CGFloat(count))
    }
}
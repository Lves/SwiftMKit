//
//  UIImage+Extension.swift
//  Merak
//
//  Created by Mao on 6/8/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    /**
     UIImage 占用内存大小
     
     - returns:占用内存大小
     */
    public func getImageSize() -> Int {
        return self.cgImage!.height * self.cgImage!.bytesPerRow
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
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSAttributedStringKey.font: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            ]
        
        // Put the image into a rectangle as large as the original image
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        // Create a point within the space that is as bit as the image
        let rect = CGRect(x: atPoint.x, y: atPoint.y, width: self.size.width, height: self.size.height)
        
        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage!
        
    }
    
    /**
     压缩图片
     */
    func restrict(maxWidth: CGFloat, maxHeight: CGFloat, maxSize: Int) -> Data? {
        let newImage = resizeImage(originalImg: self, maxWidth: maxWidth, maxHeight: maxHeight)
        return compressImageSize(limitSize: maxSize, image:newImage)
    }
    
    func resizeImage(originalImg:UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage{
        //prepare constants
        let width = originalImg.size.width
        let height = originalImg.size.height
        let scale = width/height
        DDLogInfo("原始长: \(height), 原始宽: \(width)")
        
        var sizeChange = CGSize()
        
        if width <= maxWidth && height <= maxHeight{ //a，图片宽或者高均小于或等于1280时图片尺寸保持不变，不改变图片大小
            return originalImg
        } else if width > maxWidth || height > maxHeight {//b,宽或者高大于1280，但是图片宽度高度比小于或等于2，则将图片宽或者高取大的等比压缩至1280
            
            if scale <= 2 && scale >= 1 {
                let changedWidth:CGFloat = maxWidth
                let changedheight:CGFloat = changedWidth / scale
                sizeChange = CGSize(width: changedWidth, height: changedheight)
                
            } else if scale >= 0.5 && scale <= 1 {
                
                let changedheight:CGFloat = maxHeight
                let changedWidth:CGFloat = changedheight * scale
                sizeChange = CGSize(width: changedWidth, height: changedheight)
                
            } else if width > maxWidth && height > maxHeight {//宽以及高均大于1280，但是图片宽高比大于2时，则宽或者高取小的等比压缩至1280
                
                if scale > 2 {//高的值比较小
                    
                    let changedheight:CGFloat = maxHeight
                    let changedWidth:CGFloat = changedheight * scale
                    sizeChange = CGSize(width: changedWidth, height: changedheight)
                    
                } else if scale < 0.5{//宽的值比较小
                    
                    let changedWidth:CGFloat = maxWidth
                    let changedheight:CGFloat = changedWidth / scale
                    sizeChange = CGSize(width: changedWidth, height: changedheight)
                    
                }
            } else {//d, 宽或者高，只有一个大于1280，并且宽高比超过2，不改变图片大小
                return originalImg
            }
        }
        UIGraphicsBeginImageContext(sizeChange)
        //draw resized image on Context
        originalImg.draw(in: CGRect(x: 0, y: 0, width: sizeChange.width, height: sizeChange.height))
        //create UIImage
        let resizedImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        DDLogInfo("压缩后长: \(sizeChange.height), 压缩后宽: \(sizeChange.width)")
        
        return resizedImg!
    }
    
    //图片质量压缩
    func compressImageSize(limitSize:Int,image:UIImage) -> Data{
        var zipImageData = UIImageJPEGRepresentation(image,1.0)!

        let originalImgSize = zipImageData.count/1024 as Int  //获取图片大小
        DDLogInfo("原始大小: \(originalImgSize)")
        
        let compressionQuality : CGFloat = self.getCompressionQuality(limitSize: limitSize, image: image, compressionQuality: 1.0)
        zipImageData = UIImageJPEGRepresentation(image,compressionQuality)!
       
        DDLogInfo("上传大小: \(zipImageData.count/1024)")
        
        //FIXME: 打印测试数据信息
        let width = image.size.width
        let height = image.size.height
        print("原始长: \(height), 原始宽: \(width)")
        
//        let alert = UIAlertController(title: "compressionQuality : \(compressionQuality) 原始长: \(height), 原始宽: \(width) \n原始大小: \(originalImgSize) 上传大小: \(zipImageData.length/1024)", message: "", preferredStyle: .Alert)
//        alert.addAction(UIAlertAction(title: "关闭", style: .Cancel, handler: nil))
//        UIViewController.topController?.showAlert(alert, completion: nil)
//        
//        let homeDirectory = NSHomeDirectory()
//        let filePath : String = homeDirectory + "/test.jpg"
//        zipImageData.writeToFile(filePath, atomically: true)
//        print("filePath \(filePath)")
        
        return zipImageData
    }
    
    func getCompressionQuality(limitSize:Int,image:UIImage,compressionQuality:CGFloat) -> CGFloat{
        var ret = compressionQuality
        let zipImageData = UIImageJPEGRepresentation(image,compressionQuality)!
        if zipImageData.count > limitSize {
            ret = ret * 0.9
            ret = self.getCompressionQuality(limitSize: limitSize, image: image, compressionQuality: ret)
        }
        return ret
    }
}

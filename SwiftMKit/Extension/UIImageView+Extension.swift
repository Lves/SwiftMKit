//
//  UIImageView+Extension.swift
//
//  Created by Mao on 9/6/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit


extension UIImageView {
    
    func createARGBBitmapContext(inImage: CGImage) -> CGContext {
        var bitmapByteCount = 0
        var bitmapBytesPerRow = 0
        
        //Get image width, height
        let pixelsWide = inImage.width
        let pixelsHigh = inImage.height
        
        // Declare the number of bytes per row. Each pixel in the bitmap in this
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
        // alpha.
        bitmapBytesPerRow = Int(pixelsWide) * 4
        bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        
        // Use the generic RGB color space.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Allocate memory for image data. This is the destination in memory
        // where any drawing to the bitmap context will be rendered.
        let bitmapData = malloc(bitmapByteCount)
        
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here by CGBitmapContextCreate.
        let context = CGContext(data: bitmapData, width: pixelsWide, height: pixelsHigh, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        // Make sure and release colorspace before returning
        return context!
    }
    
    /**
     获取图片某一点的颜色
     
     - parameter point:
     - parameter inImage:
     
     - returns:
     */
    func getPixelColorAtLocation(_ point:CGPoint, inImage:CGImage) -> UIColor {
        // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
        let context = self.createARGBBitmapContext(inImage: inImage)
        let pixelsWide = inImage.width
        let pixelsHigh = inImage.height
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        //Clear the context
        context.clear(rect)
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        context.draw(inImage, in: rect)
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        let data = context.data
        let dataType = data!.assumingMemoryBound(to: UInt8.self)
        
        let offset = 4*((Int(pixelsWide) * Int(point.y)) + Int(point.x))
        let alpha = dataType[offset]
        let red = dataType[offset+1]
        let green = dataType[offset+2]
        let blue = dataType[offset+3]
        let color = UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
        
        // Free image data memory for the context
        free(data)
        return color;
    }

}

//
//  ImageTools.swift
//  SwiftMKitDemo
//
//  Created by wei.mao on 2018/6/29.
//  Copyright © 2018年 cdts. All rights reserved.
//

import Foundation
import UIKit

public struct ImageTools {
    public func getImage(named: String) -> UIImage? {
        return UIImage(named: named)
    }
    public func getImage(named: String, scaleTo size: CGSize) -> UIImage? {
        if let image = getImage(named: named) {
            UIGraphicsBeginImageContext(size)
            image.draw(in: CGRect(x: 0, y: 0, w: size.width, h: size.height))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return scaledImage
        }
        return nil
    }
    //WWDC 2018 中苹果推荐的加载大图的方式
    public func getLargeImage(source: String, extension: String, scaleTo size: CGSize) -> UIImage? {
        let url = Bundle.main.url(forResource: source, withExtension: `extension`)
        let sourceOpt = [kCGImageSourceShouldCache : false] as CFDictionary
        let source = CGImageSourceCreateWithURL(url! as CFURL, sourceOpt)!
        let scale:CGFloat = 1.0
        let maxDimension = max(size.width, size.height) * scale
        let downsampleOpt = [kCGImageSourceCreateThumbnailFromImageAlways : true,
                             kCGImageSourceShouldCacheImmediately : true ,
                             kCGImageSourceCreateThumbnailWithTransform : true,
                             kCGImageSourceThumbnailMaxPixelSize : maxDimension] as CFDictionary
        let downsampleImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOpt)!
        return UIImage(cgImage: downsampleImage)
    }
}

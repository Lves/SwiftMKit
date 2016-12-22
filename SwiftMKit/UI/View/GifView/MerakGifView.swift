//
//  MerakGifView.swift
//  Merak
//
//  Created by HeLi on 16/12/13.
//  Copyright © 2016年 jimubox. All rights reserved.
//

/// 功能： 如何展示一张本地的GIF图片

import UIKit
import ImageIO
import QuartzCore
import CocoaLumberjack

public protocol MerakGifViewDelegate: class {
    func gv_didFinished(gifView: MerakGifView?)
}

public class MerakGifView: UIView {
    weak var delegate : MerakGifViewDelegate?
    var repeatCount : Float = HUGE
    var animation : CAKeyframeAnimation?
    var width:CGFloat{return self.frame.size.width}
    var height:CGFloat{return self.frame.size.height}
    private var gifurl:NSURL! // 把本地图片转化成URL
    private var imageArr:Array<CGImage> = [] // 图片数组(存放每一帧的图片)
    private var timeArr:Array<NSNumber> = [] // 时间数组(存放每一帧的图片的时间)
    private var totalTime:Float = 0 // gif动画时间
    /**
     *  加载本地GIF图片
     */
    func showGIFImageWithLocalName(name:String) {
        //清除数据
        imageArr.removeAll()
        timeArr.removeAll()
        //重新加载
        gifurl = Bundle.main.url(forResource: name, withExtension: "gif") as NSURL!
        self.creatKeyFrame()
    }
    
    /**
     *  重新加载
     */
    func reloadData(){
        self.showAnimation()
    }

    /**
     *  获取GIF图片的每一帧 有关的东西  比如：每一帧的图片、每一帧的图片执行的时间
     */
    private func creatKeyFrame() {
        let url:CFURL = gifurl as CFURL
        let gifSource = CGImageSourceCreateWithURL(url, nil)
        let imageCount = CGImageSourceGetCount(gifSource!)
        
        for i in 0..<imageCount {
            let imageRef = CGImageSourceCreateImageAtIndex(gifSource!, i, nil) // 取得每一帧的图片
            imageArr.append(imageRef!)
            
            let sourceDict = CGImageSourceCopyPropertiesAtIndex(gifSource!, i, nil) as NSDictionary!
            let gifDict : [String:AnyObject] = (sourceDict?[String(kCGImagePropertyGIFDictionary)] as? [String : AnyObject])!
            let time = gifDict[String(kCGImagePropertyGIFUnclampedDelayTime)] as! NSNumber// 每一帧的动画时间
            timeArr.append(time)
            totalTime += time.floatValue
            
            // 获取图片的尺寸 (适应)
            let imageWitdh = sourceDict?[String(kCGImagePropertyPixelWidth)] as! NSNumber
            let imageHeight = sourceDict?[String(kCGImagePropertyPixelHeight)] as! NSNumber
            if ((imageWitdh.floatValue)/(imageHeight.floatValue) != Float((width)/(height))) {
                self.fitScale(imageWitdh: CGFloat(imageWitdh.floatValue), imageHeight: CGFloat(imageHeight.floatValue))
            }
        }
        
        self.showAnimation()
    }
    
    /**
     *  (适应)
     */
    private func fitScale(imageWitdh:CGFloat, imageHeight:CGFloat) {
        var newWidth:CGFloat
        var newHeight:CGFloat
        if imageWitdh/imageHeight > width/height {
            newWidth = width
            newHeight = width/(imageWitdh/imageHeight)
        } else {
            newWidth = height/(imageHeight/imageWitdh)
            newHeight = height;
        }
        let point = self.center;
        self.frame.size = CGSize(width: newWidth, height: newHeight);
        self.center = point;
    }
    
    /**
     *  展示动画
     */
    private func showAnimation() {
        if animation == nil {
            animation = CAKeyframeAnimation(keyPath: "contents")
        }

        var current:Float = 0
        var timeKeys:Array<NSNumber> = []
        
        for time in timeArr {
            timeKeys.append(NSNumber(value: current/totalTime))
            current += time.floatValue
        }
        
        animation?.keyTimes = timeKeys
        animation?.values = imageArr
        animation?.repeatCount = repeatCount
        animation?.duration = TimeInterval(totalTime)
        animation?.isRemovedOnCompletion = false //结束后禁止删除
        animation?.fillMode = kCAFillModeForwards //结束后停留在最后一帧
        animation?.delegate = self
        self.layer.add(animation!, forKey: "MerakGifView")
    }
    
}

extension MerakGifView : CAAnimationDelegate{
    public func animationDidStart(_ anim: CAAnimation) {
        
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        DDLogInfo("animationDidStop \(flag)")
        if flag {
            self.delegate?.gv_didFinished(gifView: self)
        }
    }
}

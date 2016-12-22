//
//  PopAnimator.swift
//  SwiftMKitDemo
//
//  Created by HeLi on 16/12/22.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

class HQPopAnimator: NSObject,UIViewControllerAnimatedTransitioning {
    
    var presenting = true  //是否在presenting
    let duration = 0.25
    
    //动画持续时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    //动画执行的方法
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        let detailView = presenting ? toView : fromView
        let detailViewVC : HQImageViewController = detailView?.getViewController() as! HQImageViewController
        var originFrame : CGRect = detailViewVC.imageModels[detailViewVC.selectedIndex].originFrame
        //FIXME: 测试滑动到第N张效果数据
        originFrame.x += originFrame.w * CGFloat(detailViewVC.selectedIndex)
        
        let SW = detailView!.frame.width
        let SH = detailView!.frame.height
        let w = originFrame.w
        let h = originFrame.h
        
        var fixedOrignFrame = originFrame
        let fixedTargetFrame = detailView!.frame
        if (w / h) > (SW / SH) {
            //wider
            fixedOrignFrame.h = w * SH / SW
            fixedOrignFrame.y -= (fixedOrignFrame.h - originFrame.h) / 2
        } else {
            fixedOrignFrame.w = h * SW / SH
            fixedOrignFrame.x -= (fixedOrignFrame.w - originFrame.w) / 2
        }
        let initialFrame = presenting ? fixedOrignFrame : fixedTargetFrame
        let finalFrame = presenting ? fixedTargetFrame : fixedOrignFrame
        
        let xScaleFactor = presenting ?
            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ?
            initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor,
                                               y: yScaleFactor)
        if presenting {
            detailView!.transform = scaleTransform
            detailView!.center = CGPoint(
                x: initialFrame.midX,
                y: initialFrame.midY)
            detailView!.clipsToBounds = true
        }
        
        containerView.addSubview(toView!)
        containerView.bringSubview(toFront: detailView!)
        
        UIView.animate(withDuration: duration, animations: {
            detailView!.transform = self.presenting ?
                CGAffineTransform.identity : scaleTransform
            detailView!.center = CGPoint(x: finalFrame.midX,
                                         y: finalFrame.midY)
            
        }) { (_) -> Void in
            transitionContext.completeTransition(true)
        }
    }
    
}

//
//  SlideInPresentationAnimator.swift
//  SwiftMKitDemo
//
//  Created by Mao on 08/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

public final class SlideInPresentationAnimator: NSObject {
    
    // MARK: - Properties
    let direction: PresentationDirection
    
    let isPresentation: Bool
    
    var duration: NSTimeInterval = 0.3
    
    // MARK: - Initializers
    init(direction: PresentationDirection, isPresentation: Bool) {
        self.direction = direction
        self.isPresentation = isPresentation
        super.init()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension SlideInPresentationAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let key = isPresentation ? UITransitionContextToViewControllerKey
            : UITransitionContextFromViewControllerKey
        
        let controller = transitionContext.viewControllerForKey(key)!
        
        if isPresentation {
            transitionContext.containerView()?.addSubview(controller.view)
        }
        
        let presentedFrame = transitionContext.finalFrameForViewController(controller)
        var dismissedFrame = presentedFrame
        switch direction {
        case .left:
            dismissedFrame.origin.x = -presentedFrame.width
        case .right:
            dismissedFrame.origin.x = transitionContext.containerView()?.frame.size.width ?? 0
        case .top:
            dismissedFrame.origin.y = -presentedFrame.height
        case .bottom:
            dismissedFrame.origin.y = transitionContext.containerView()?.frame.size.height ?? 0
        }
        
        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
        let finalFrame = isPresentation ? presentedFrame : dismissedFrame
        
        let animationDuration = transitionDuration(transitionContext)
        controller.view.frame = initialFrame
        UIView.animateWithDuration(animationDuration, animations: {
            controller.view.frame = finalFrame
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
}
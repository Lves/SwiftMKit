//
//  SideInPresentationManager.swift
//  SwiftMKitDemo
//
//  Created by Mao on 08/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

public enum PresentationDirection {
    case left
    case top
    case right
    case bottom
}

public class SlideInPresentationManager: NSObject {
    public var direction = PresentationDirection.left
    public var coverPercent: CGFloat = 0.8
    public var dimmingColor: UIColor = UIColor(white: 0.0, alpha: 0.5)
    public var statusBarHidden = false
    public var disableCompactHeight = false

    
    var presentationController: UIPresentationController?
    public var sourceViewController: UIViewController? {
        return presentationController?.presentedViewController
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController?, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(presentedViewController: presented,
                                                                   presenting: presenting,
                                                                   direction: direction)
        presentationController.coverPercent = coverPercent
        presentationController.dimmingColor = dimmingColor
        presentationController.statusBarHidden = statusBarHidden
        presentationController.delegate = self

        return presentationController
    }
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(direction: direction, isPresentation: true)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            return SlideInPresentationAnimator(direction: direction, isPresentation: false)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension SlideInPresentationManager: UIAdaptivePresentationControllerDelegate {
    
    public func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == .Compact && disableCompactHeight {
            return .OverFullScreen
        } else {
            return .None
        }
    }
}

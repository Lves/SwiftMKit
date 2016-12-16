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

open class SlideInPresentationManager: NSObject {
    open var direction = PresentationDirection.left
    open var coverPercent: CGFloat = 0.8
    open var dimmingColor: UIColor = UIColor(white: 0.0, alpha: 0.5)
    open var statusBarHidden = false
    open var disableCompactHeight = false

    
    var presentationController: UIPresentationController?
    open var sourceViewController: UIViewController? {
        return presentationController?.presentedViewController
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(presentedViewController: presented,
                                                                   presenting: presenting,
                                                                   direction: direction)
        presentationController.coverPercent = coverPercent
        presentationController.dimmingColor = dimmingColor
        presentationController.statusBarHidden = statusBarHidden
        presentationController.delegate = self

        return presentationController
    }
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(direction: direction, isPresentation: true)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            return SlideInPresentationAnimator(direction: direction, isPresentation: false)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension SlideInPresentationManager: UIAdaptivePresentationControllerDelegate {
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == .compact && disableCompactHeight {
            return .overFullScreen
        } else {
            return .none
        }
    }
}

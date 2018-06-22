//
//  PersentAnimator.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/5/13.
//  Copyright © 2016年 cdts. All rights reserved.
//

import Foundation
import UIKit

open class PersentAnimator: UIPercentDrivenInteractiveTransition {
    public enum UIPresentTransitionStyle {
        case crossDissolve
        case coverVertical
        case none
    }
    
    /// present样式
    open var presentStlye: UIPresentTransitionStyle = .none
    
    /// 动画时长
    open var animatingDuration: TimeInterval = 0.25
    
    fileprivate var isPersent = false
    
    fileprivate var shouldComplete: Bool = false
    
    fileprivate var interacting = false
    
    fileprivate weak var presentingVC: UIViewController?
    
    open static let sharedPersentAnimation = PersentAnimator()
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPersent = true
        return PersentAnimator.sharedPersentAnimation
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPersent = false
        return PersentAnimator.sharedPersentAnimation
    }
    
    func prepareGestureRecognizerInView(_ view: UIView) {
        let popRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action:#selector(PersentAnimator.handlePopRecognizer(_:)))
        popRecognizer.edges = .left
        view.addGestureRecognizer(popRecognizer)
    }
    
    @objc func handlePopRecognizer(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view?.superview)
        switch (gestureRecognizer.state) {
        case .began:
            // 1. Mark the interacting flag. Used when supplying it in delegate.
            interacting = true
            presentingVC?.dismiss(animated: true, completion:nil)
        case .changed:
            // 2. Calculate the percentage of guesture
            var fraction = translation.x / UIApplication.shared.delegate!.window!!.bounds.width
            //Limit it between 0 and 1
            fraction = CGFloat(fminf(fmaxf(Float(fraction), 0.0), 1.0))
            shouldComplete = (fraction > CGFloat(animatingDuration))
            update(fraction)
            
        case .cancelled:
            // 3. Gesture over. Check if the transition should happen or not
            interacting = false
            if (!shouldComplete || gestureRecognizer.state == .cancelled) {
                cancel()
            } else {
                finish()
            }
            
        case .ended:
            interacting = false
            if (!shouldComplete || gestureRecognizer.state == .cancelled) {
                cancel()
            } else {
                finish()
            }
            
        default: break
        }
    }
    
}

extension PersentAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animatingDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 1. Get controllers from transition context
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) ?? UIViewController()
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)  ?? UIViewController()
        toVC.view.layer.shadowPath = UIBezierPath(rect: toVC.view.bounds).cgPath
        toVC.view.layer.shadowColor = UIColor.black.cgColor
        toVC.view.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        toVC.view.layer.shadowOpacity = 0.5
        toVC.view.layer.shadowRadius = 5.0
        presentingVC = toVC
        if isPersent {
//            prepareGestureRecognizerInView(toVC.view)
        }
        // 2. Set init frame for toVC
        let screenBounds = UIScreen.main.bounds
        let finalFrame = transitionContext.finalFrame(for: toVC)
        if presentStlye == .coverVertical {
            if isPersent {
                toVC.view.frame = finalFrame.offsetBy(dx: screenBounds.size.width, dy: 0)
            } else {
                toVC.view.frame = finalFrame.offsetBy(dx: -screenBounds.size.width/2, dy: 0)
            }
        } else {
            if isPersent {
                toVC.view.alpha = 0
            } else {
                fromVC.view.alpha = 1
            }
        }
        
        // 3. Add toVC's view to containerView
        let containerView = transitionContext.containerView 
        containerView.addSubview(toVC.view)
        if !isPersent {
            containerView.bringSubview(toFront: fromVC.view)
        }
        // 4. Do animate now
        switch presentStlye {
        case .coverVertical:
            UIView.animate(withDuration: animatingDuration, animations: {
                if self.isPersent {
                    fromVC.view.frame = CGRect(x: -screenBounds.size.width / 2, y: fromVC.view.y, width: fromVC.view.frame.width, height: fromVC.view.frame.height)
                } else {
                    fromVC.view.frame = CGRect(x: screenBounds.size.width, y: fromVC.view.y, width: fromVC.view.frame.width, height: fromVC.view.frame.height)
                }
                toVC.view.frame = finalFrame
            }, completion: { _ in
                if self.isPersent {
                    transitionContext.completeTransition(true)
                } else {
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }) 
        case .crossDissolve:
            UIView.animate(withDuration: animatingDuration, animations: {
                if self.isPersent {
                    toVC.view.alpha = 1
                } else {
                    fromVC.view.alpha = 0
                }
            }, completion: { _ in
                if self.isPersent {
                    transitionContext.completeTransition(true)
                }else {
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }) 
        default: break
        }
    }
}

extension PersentAnimator: UIViewControllerTransitioningDelegate {
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interacting ? self : nil
    }
}

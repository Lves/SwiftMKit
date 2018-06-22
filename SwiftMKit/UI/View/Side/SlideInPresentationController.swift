//
//  SlideInPresentationController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 08/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import SnapKit

open class SlideInPresentationController: UIPresentationController {
    open var dimmingColor: UIColor = UIColor(white: 0.0, alpha: 0.5) {
        didSet {
            dimmingView?.backgroundColor = dimmingColor
        }
    }
    open var coverPercent: CGFloat = 0.8
    open var statusBarHidden: Bool = false
    
    fileprivate var direction: PresentationDirection
    fileprivate var dimmingView: UIView!

    
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
                    direction: PresentationDirection) {
        self.direction = direction
        
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
        
        setupDimmingView()

    }
    
    override open func presentationTransitionWillBegin() {
        if statusBarHidden {
            hideStatusBar()
        }
        
        containerView?.insertSubview(dimmingView, at: 0)
        
        dimmingView.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView!)
        }
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
            }, completion: {_ in})
    }
    
    override open func dismissalTransitionWillBegin() {
        if statusBarHidden {
            showStatusBar()
        }
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        }, completion: {_ in})
    }
    
    override open func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    open override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        switch direction {
        case .left, .right:
            return CGSize(width: parentSize.width*coverPercent, height: parentSize.height)
        case .bottom, .top:
            return CGSize(width: parentSize.width, height: parentSize.height*coverPercent)
        }
    }
    open override var frameOfPresentedViewInContainerView : CGRect {
        
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController,
                          withParentContainerSize: containerView!.bounds.size)
        
        switch direction {
        case .right:
            frame.origin.x = containerView!.frame.width*(1-coverPercent)
        case .bottom:
            frame.origin.y = containerView!.frame.height*(1-coverPercent)
        default:
            frame.origin = .zero
        }
        return frame
    }
    
    
    fileprivate func showStatusBar() {
        UIApplication.shared.isStatusBarHidden = false
    }
    fileprivate func hideStatusBar() {
        UIApplication.shared.isStatusBarHidden = true
    }
}

extension SlideInPresentationController {
    func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = dimmingColor
        dimmingView.alpha = 0.0
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        dimmingView.addGestureRecognizer(recognizer)
    }
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        presentingViewController.dismissVC(completion: nil)
    }
}

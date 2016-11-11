//
//  SlideInPresentationController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 08/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import SnapKit

public class SlideInPresentationController: UIPresentationController {
    public var dimmingColor: UIColor = UIColor(white: 0.0, alpha: 0.5) {
        didSet {
            dimmingView?.backgroundColor = dimmingColor
        }
    }
    public var coverPercent: CGFloat = 0.8
    public var statusBarHidden: Bool = false
    
    private var direction: PresentationDirection
    private var dimmingView: UIView!

    
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
                    direction: PresentationDirection) {
        self.direction = direction
        
        super.init(presentedViewController: presentedViewController,
                   presentingViewController: presentingViewController)
        
        setupDimmingView()

    }
    
    override public func presentationTransitionWillBegin() {
        if statusBarHidden {
            hideStatusBar()
        }
        
        containerView?.insertSubview(dimmingView, atIndex: 0)
        
        dimmingView.snp_makeConstraints { (make) in
            make.edges.equalTo(containerView!)
        }
        
        guard let coordinator = presentedViewController.transitionCoordinator() else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animateAlongsideTransition({ _ in
            self.dimmingView.alpha = 1.0
            }, completion: {_ in})
    }
    
    override public func dismissalTransitionWillBegin() {
        if statusBarHidden {
            showStatusBar()
        }
        
        guard let coordinator = presentedViewController.transitionCoordinator() else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animateAlongsideTransition({ _ in
            self.dimmingView.alpha = 0.0
        }, completion: {_ in})
    }
    
    override public func containerViewWillLayoutSubviews() {
        presentedView()?.frame = frameOfPresentedViewInContainerView()
    }
    
    public override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        switch direction {
        case .left, .right:
            return CGSize(width: parentSize.width*coverPercent, height: parentSize.height)
        case .bottom, .top:
            return CGSize(width: parentSize.width, height: parentSize.height*coverPercent)
        }
    }
    public override func frameOfPresentedViewInContainerView() -> CGRect {
        
        var frame: CGRect = .zero
        frame.size = sizeForChildContentContainer(presentedViewController,
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
    
    
    private func showStatusBar() {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    }
    private func hideStatusBar() {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
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
    func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismissVC(completion: nil)
    }
}

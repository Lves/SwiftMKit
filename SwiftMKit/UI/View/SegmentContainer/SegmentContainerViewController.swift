//
//  SegmentContainerViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/12/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

public protocol SegmentContainerViewControllerDelegate : class {
    func didSelectSegment(segmentContainer: SegmentContainerViewController, index: Int, viewController: UIViewController)
    func animationForTransition(segmentContainer: SegmentContainerViewController, fromIndex: Int, toIndex: Int, fromViewController: UIViewController, toViewController: UIViewController) -> UIViewControllerAnimatedTransitioning?
}
public extension SegmentContainerViewControllerDelegate {
    func didSelectSegment(segmentContainer: SegmentContainerViewController, index: Int, viewController: UIViewController) {}
    func animationForTransition(segmentContainer: SegmentContainerViewController, fromIndex: Int, toIndex: Int, fromViewController: UIViewController, toViewController: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

public class SegmentContainerViewController: UIViewController {
    
    public var views:[UIView] {
        get {
            return self.viewControllers.map { vc in vc.view }
        }
    }
    private var _viewControllers = [UIViewController]()
    public var viewControllers:[UIViewController] {
        get {
            return _viewControllers
        }
    }
    private var _selectedSegment: Int = -1
    public var selectedSegment: Int {
        get {
            return _selectedSegment
        }
    }
    public var selectedViewController: UIViewController? {
        get {
            return viewControllers[safe: selectedSegment]
        }
    }
    public weak var delegate: SegmentContainerViewControllerDelegate?
    public var animated: Bool = true
    public var interactive: Bool = false

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    public func addSegmentViewControllers(childController: [UIViewController]) {
        _viewControllers = childController
        selectSegment(0)
    }
    
    public func selectSegment(index: Int) {
        if index < 0 || index >= _viewControllers.count {
            DDLogError("Segment Index out of bounds")
            return
        }
        if index == selectedSegment {
            DDLogDebug("Segment Index is same to old one, do nothing")
            return
        }
        transitionSegment(to: viewControllers[index])
        _selectedSegment = index
    }
    
    public func transitionSegment(to toViewController: UIViewController) {
        let fromIndex = _selectedSegment
        let toIndex = viewControllers.indexOf(toViewController)!
        let fromViewController = selectedViewController
        if fromViewController == toViewController || self.isViewLoaded() == false {
            return
        }
        let toView = toViewController.view
        toView.frame = self.view.bounds
        fromViewController?.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController)
        
        if fromViewController == nil {
            self.view.addSubview(toView)
            toViewController.didMoveToParentViewController(self)
            return
        }
        let animator = delegate?.animationForTransition(self, fromIndex: fromIndex, toIndex: toIndex, fromViewController: fromViewController!, toViewController: toViewController) ?? SegmentContainerAnimatedTransition()
        let transitionContext = SegmentContainerTransitionContext(fromViewController: fromViewController!, toViewController: toViewController, goRight: toIndex > fromIndex)
        transitionContext.animated = animated
        transitionContext.interactive = interactive
        transitionContext.completionBlock = { [weak self] complete in
            fromViewController?.view.removeFromSuperview()
            fromViewController?.removeFromParentViewController()
            toViewController.didMoveToParentViewController(self)
            animator.animationEnded?(complete)
        }
        animator.animateTransition(transitionContext)
    }
}

public class SegmentContainerTransitionContext : NSObject, UIViewControllerContextTransitioning {
    
    public var completionBlock: ((Bool) -> Void)?
    public var animated: Bool = true
    public var interactive: Bool = false
    init(fromViewController: UIViewController, toViewController: UIViewController, goRight: Bool) {
        assert(fromViewController.isViewLoaded() && fromViewController.view!.superview != nil)
        _containerView = fromViewController.view!.superview!
        self.privateViewControllers = [UITransitionContextFromViewControllerKey: fromViewController, UITransitionContextToViewControllerKey: toViewController]
        let travelDistance = goRight ? -_containerView.w : _containerView.w
        self.privateDisappearingFromRect = _containerView.bounds
        self.privateAppearingToRect = _containerView.bounds
        self.privateDisappearingToRect = CGRectOffset(_containerView.bounds, travelDistance, 0)
        self.privateAppearingFromRect = CGRectOffset(_containerView.bounds, -travelDistance, 0)
        super.init()
    }
    
    public func isAnimated() -> Bool {
        return animated
    }
    public func isInteractive() -> Bool {
        return interactive
    }
    public func containerView() -> UIView? {
        return _containerView
    }
    public func presentationStyle() -> UIModalPresentationStyle {
        return _presentationStyle
    }
    
    public func initialFrameForViewController(viewController: UIViewController) -> CGRect {
        if viewController == viewControllerForKey(UITransitionContextFromViewControllerKey) {
            return privateDisappearingFromRect
        } else {
            return privateAppearingFromRect
        }
    }
    public func finalFrameForViewController(viewController: UIViewController) -> CGRect {
        if viewController == viewControllerForKey(UITransitionContextFromViewControllerKey) {
            return privateDisappearingToRect
        } else {
            return privateAppearingToRect
        }
    }
    public func viewControllerForKey(key: String) -> UIViewController? {
        return privateViewControllers[key]
    }
    public func viewForKey(key: String) -> UIView? {
        return viewControllerForKey(key)?.view
    }
    public func completeTransition(didComplete: Bool) {
        if let block = completionBlock {
            block(didComplete)
        }
    }
    public func transitionWasCancelled() -> Bool {
        return false
    }
    public func targetTransform() -> CGAffineTransform {
        return CGAffineTransformIdentity
    }
    public func updateInteractiveTransition(percentComplete: CGFloat) {}
    public func finishInteractiveTransition() {}
    public func cancelInteractiveTransition() {}
    
    private var privateViewControllers: [String: UIViewController]
    private var privateDisappearingFromRect: CGRect
    private var privateAppearingFromRect: CGRect
    private var privateDisappearingToRect: CGRect
    private var privateAppearingToRect: CGRect
    private var _presentationStyle: UIModalPresentationStyle = .Custom
    private var _containerView: UIView
    
}

public class SegmentContainerAnimatedTransition : NSObject, UIViewControllerAnimatedTransitioning {
    struct InnerConstant {
        static let ChildViewPadding: CGFloat = 0
        static let Damping: CGFloat = 1
        static let InitialSpringVelocity: CGFloat = 0.5
        static let Duration: Double = 0.4
    }
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return InnerConstant.Duration
    }
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let goRight = transitionContext.initialFrameForViewController(toViewController).x < transitionContext.finalFrameForViewController(toViewController).x
        let travelDistance = transitionContext.containerView()!.w + InnerConstant.ChildViewPadding
        let travel = CGAffineTransformMakeTranslation(goRight ? travelDistance : -travelDistance, 0)
        transitionContext.containerView()?.addSubview(toViewController.view)
        toViewController.view.transform = CGAffineTransformInvert(travel)
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: InnerConstant.Damping, initialSpringVelocity: InnerConstant.InitialSpringVelocity, options: [], animations: {
            fromViewController.view.transform = travel
            toViewController.view.transform = CGAffineTransformIdentity
            }) { finished in
                fromViewController.view.transform = CGAffineTransformIdentity
                transitionContext.completeTransition(transitionContext.transitionWasCancelled())
        }
    }
}

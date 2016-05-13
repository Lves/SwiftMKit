//
//  MKUISideViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/10/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

// TODO: 状态栏显示与隐藏

class MKUISideViewController: BaseViewController, SideMenuDelegate, SideMenuProtocol {
    var sideMenu: SideMenu = SideMenu()
    let screenSize = UIScreen.mainScreen().bounds.size
    let kWindow: UIWindow = UIApplication.sharedApplication().keyWindow!
    
    private var _viewModel = MKUISideViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    let subVc = MKUISideTableViewController()
    var flag = false
    override func setupUI() {
        super.setupUI()
        title = "侧滑🐷视图"
        let v1 = self
        let v2 = MKUISideTableViewController()
        sideMenu = SideMenu(mainVc: v1, menuVc: v2)
        sideMenu.delegate = self
        DDLogInfo("\(sideMenu.view)")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        DDLogInfo("显示菜单")
        sideMenu.showMenu()
        flag = true
    }
    
    func sideMenuDidHideMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController) {
        DDLogInfo("\(sideMenu)   \(menuViewController)")
        DDLogInfo(#function)
    }
}

class MKUISideTableViewController: UITableViewController, SideMenuProtocol {
    var sideMenu: SideMenu = SideMenu()
    let kWindow: UIWindow = UIApplication.sharedApplication().keyWindow!
    let screenSize = UIScreen.mainScreen().bounds.size
    lazy private var coverView: UIControl = UIControl()
    let duration = 0.25
    let menuWidth = UIScreen.mainScreen().bounds.size.width * 0.7
    var menuView: UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.frame = CGRectMake(-screenSize.width * 0.7, 0, screenSize.width * 0.7, screenSize.height)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell?.textLabel?.text = "hello -- \(indexPath.row)"
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        DDLogInfo("选中了第\(indexPath.row)行")
//        let nav = UINavigationController(rootViewController: self.instanceViewControllerInXibWithName("SubViewController")!)
        
        // TODO: present操作应该封装到SideMenu控件里面，接收一个输入参数（作为rootViewController）
        let nav = UINavigationController(rootViewController: SubViewController())
        
        let fromVc = sideMenu.mainVc?.navigationController
        let effect = PersentAnimator.sharedPersentAnimation.then { $0.presentStlye = .CoverVertical }
        nav.transitioningDelegate = effect
        fromVc?.presentViewController(nav, animated: true, completion: nil)
    }
    
}

protocol SideMenuProtocol : NSObjectProtocol {
    var sideMenu: SideMenu { get set }
}

// MARK: - 弹出菜单
@objc protocol SideMenuDelegate {
    optional func sideMenuDidRecognizePanGesture(sideMenu: SideMenu, recongnizer: UIPanGestureRecognizer)
    optional func sideMenuDidShowMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController)
    optional func sideMenuDidHideMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController)
}

/// 自定义抽屉
/// 输入参数：MainVC、MenuVc
class SideMenu: UIViewController {
//    let kWindow: UIWindow = UIApplication.sharedApplication().keyWindow!
    let screenSize = UIScreen.mainScreen().bounds.size
    lazy private var coverView: UIControl = UIControl()
    let duration = 0.25
    let factor: CGFloat = 0.5
    let menuWidth = UIScreen.mainScreen().bounds.size.width * 0.5
    
    var mainVc: UIViewController?
    var menuVc: UIViewController?
    
    weak var delegate: SideMenuDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coverView.addTarget(self, action: #selector(coverClick), forControlEvents: UIControlEvents.TouchUpInside)
        coverView.frame = UIScreen.mainScreen().bounds
        coverView.backgroundColor = UIColor.init(r: 0, g: 0, b: 0, a: 0.45)
        menuVc!.view.frame = CGRectMake(-menuWidth, 0, menuWidth, screenSize.height)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
//    init<T:UIViewController where T: SideMenuProtocol>(mainVc: T, menuVc: T) {
//        super.init(nibName: nil, bundle: nil)
//        self.mainVc = mainVc
//        self.menuVc = menuVc
////        var mvc = mainVc
////        mvc.sideMenu = self
////        var svc = menuVc
////        svc.sideMenu = self
//        
////        mainVc.sideMenu = self
////        menuVc.sideMenu = self
//    }
    
    init<T:UIViewController>(mainVc: T, menuVc: T) {
        super.init(nibName: nil, bundle: nil)
        self.mainVc = mainVc
        self.menuVc = menuVc
        if let vc = mainVc as? SideMenuProtocol {
            vc.sideMenu = self
        }
        if let vc = menuVc as? SideMenuProtocol {
            vc.sideMenu = self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showMenu(animated: Bool = true) {
        if (coverView.superview == nil) {
            self.mainVc?.tabBarController?.tabBar.sendSubviewToBack(coverView)
//            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
            var view = mainVc!.view
            if let nav = mainVc?.navigationController {
                view = nav.view
            }
            view.addSubview(menuVc!.view)
            view.insertSubview(coverView, belowSubview: menuVc!.view)
            if animated {
                UIView.animateWithDuration(duration) {
                    self.menuVc!.view.frame = CGRectMake(0, 0, self.menuWidth, self.screenSize.height)
                }
            } else {
                self.menuVc!.view.frame = CGRectMake(0, 0, self.menuWidth, self.screenSize.height)
            }
        }
    }
    
    func hideMenu(animated: Bool = true) {
//        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        if animated {
            UIView.animateWithDuration(duration, animations: {
                self.menuVc!.view.frame = CGRectMake(-self.menuWidth, 0, self.menuWidth, self.screenSize.height)
            }) { (flag) in
                self.coverView.removeFromSuperview()
            }
        } else {
            self.menuVc!.view.frame = CGRectMake(-self.menuWidth, 0, self.menuWidth, self.screenSize.height)
            self.coverView.removeFromSuperview()
        }
    }
    
    @objc private func coverClick() {
        DDLogInfo("隐藏菜单")
        delegate?.sideMenuDidHideMenuViewController?(self, menuViewController: menuVc!)
        hideMenu()
    }
}


class SubViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "SubViewController"
        view.backgroundColor = UIColor.grayColor()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

/////////////////////////////////////////////////////////////////////////////////////////
// TODO: 待封装成单独的文件
public class PersentAnimator: UIPercentDrivenInteractiveTransition {
    public enum UIPresentTransitionStyle {
        case CrossDissolve
        case CoverVertical
        case None
    }
    
    /// present样式
    public var presentStlye: UIPresentTransitionStyle = .None
    
    /// 动画时长
    public var animatingDuration: NSTimeInterval = 0.25
    
    private var isPersent = false
    
    private var shouldComplete: Bool = false
    
    private var interacting = false
    
    private weak var presentingVC: UIViewController?
    
    public static let sharedPersentAnimation = PersentAnimator()
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPersent = true
        return PersentAnimator.sharedPersentAnimation
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPersent = false
        return PersentAnimator.sharedPersentAnimation
    }
    
    func prepareGestureRecognizerInView(view: UIView) {
        let popRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action:#selector(PersentAnimator.handlePopRecognizer(_:)))
        popRecognizer.edges = .Left
        view.addGestureRecognizer(popRecognizer)
    }
    
    func handlePopRecognizer(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        
        let translation = gestureRecognizer.translationInView(gestureRecognizer.view?.superview)
        switch (gestureRecognizer.state) {
        case .Began:
            // 1. Mark the interacting flag. Used when supplying it in delegate.
            interacting = true
            presentingVC?.dismissViewControllerAnimated(true, completion:nil)
        case .Changed:
            // 2. Calculate the percentage of guesture
            var fraction = translation.x / UIApplication.sharedApplication().delegate!.window!!.bounds.width
            //Limit it between 0 and 1
            fraction = CGFloat(fminf(fmaxf(Float(fraction), 0.0), 1.0))
            shouldComplete = (fraction > CGFloat(animatingDuration))
            updateInteractiveTransition(fraction)
            
        case .Cancelled:
            // 3. Gesture over. Check if the transition should happen or not
            interacting = false
            if (!shouldComplete || gestureRecognizer.state == .Cancelled) {
                cancelInteractiveTransition()
            } else {
                finishInteractiveTransition()
            }
            
        case .Ended:
            interacting = false
            if (!shouldComplete || gestureRecognizer.state == .Cancelled) {
                cancelInteractiveTransition()
            } else {
                finishInteractiveTransition()
            }
            
        default: break
        }
    }
    
}

extension PersentAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animatingDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // 1. Get controllers from transition context
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) ?? UIViewController()
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)  ?? UIViewController()
        toVC.view.layer.shadowPath = UIBezierPath(rect: toVC.view.bounds).CGPath
        toVC.view.layer.shadowColor = UIColor.blackColor().CGColor
        toVC.view.layer.shadowOffset = CGSizeMake(0.5, 0.5)
        toVC.view.layer.shadowOpacity = 0.5
        toVC.view.layer.shadowRadius = 5.0
        presentingVC = toVC
        if isPersent {
            prepareGestureRecognizerInView(toVC.view)
        }
        // 2. Set init frame for toVC
        let screenBounds = UIScreen.mainScreen().bounds
        let finalFrame = transitionContext.finalFrameForViewController(toVC)
        if presentStlye == .CoverVertical {
            if isPersent {
                toVC.view.frame = CGRectOffset(finalFrame, screenBounds.size.width, 0)
            } else {
                toVC.view.frame = CGRectOffset(finalFrame, -screenBounds.size.width/2, 0)
            }
        } else {
            if isPersent {
                toVC.view.alpha = 0
            } else {
                fromVC.view.alpha = 1
            }
        }
        
        // 3. Add toVC's view to containerView
        let containerView = transitionContext.containerView() ?? UIView()
        containerView.addSubview(toVC.view)
        if !isPersent {
            containerView.bringSubviewToFront(fromVC.view)
        }
        // 4. Do animate now
        switch presentStlye {
        case .CoverVertical:
            UIView.animateWithDuration(animatingDuration, animations: {
                if self.isPersent {
                    fromVC.view.frame = CGRectMake(-screenBounds.size.width / 2, fromVC.view.y, fromVC.view.frame.width, fromVC.view.frame.height)
                } else {
                    fromVC.view.frame = CGRectMake(screenBounds.size.width, fromVC.view.y, fromVC.view.frame.width, fromVC.view.frame.height)
                }
                toVC.view.frame = finalFrame
            }) { _ in
                if self.isPersent {
                    transitionContext.completeTransition(true)
                } else {
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                }
            }
        case .CrossDissolve:
            UIView.animateWithDuration(animatingDuration, animations: {
                if self.isPersent {
                    toVC.view.alpha = 1
                } else {
                    fromVC.view.alpha = 0
                }
            }) { _ in
                if self.isPersent {
                    transitionContext.completeTransition(true)
                }else {
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                }
            }
        default: break
        }
    }
}

extension PersentAnimator: UIViewControllerTransitioningDelegate {
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interacting ? self : nil
    }
}

public protocol Then {}

extension Then {
    func then(closure: Self -> Void) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: Then {}

//extension UIView: Then {}
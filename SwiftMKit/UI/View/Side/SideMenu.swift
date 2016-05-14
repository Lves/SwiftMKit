//
//  SideMenu.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/5/13.
//  Copyright © 2016年 cdts. All rights reserved.
//

/**
 * 　　　　　　　　┏┓　　　┏┓
 * 　　　　　　　┏┛┻━━━┛┻┓
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┃　　　━　　　┃
 * 　　　　　　　┃　＞　　　＜　┃
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┃...　⌒　...　┃
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┗━┓　　　┏━┛
 * 　　　　　　　　　┃　　　┃　Code is far away from bug with the animal protecting
 * 　　　　　　　　　┃　　　┃   神兽保佑,代码无bug
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┗━━━┓
 * 　　　　　　　　　┃　　　　　　　┣┓
 * 　　　　　　　　　┃　　　　　　　┏┛
 * 　　　　　　　　　┗┓┓┏━┳┓┏┛
 * 　　　　　　　　　　┃┫┫　┃┫┫
 * 　　　　　　　　　　┗┻┛　┗┻┛
 */

import Foundation
import UIKit
import CocoaLumberjack
import ReactiveCocoa

protocol SideMenuProtocol : NSObjectProtocol {
    var sideMenu: SideMenu? { get set }
}

// MARK: - 弹出菜单
public protocol SideMenuDelegate: class {
    func sideMenuDidRecognizePanGesture(sideMenu: SideMenu, recongnizer: UIPanGestureRecognizer)
    func sideMenuDidShowMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController)
    func sideMenuDidHideMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController)
}
public extension SideMenuDelegate {
    func sideMenuDidRecognizePanGesture(sideMenu: SideMenu, recongnizer: UIPanGestureRecognizer) {}
    func sideMenuDidShowMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController) {}
    func sideMenuDidHideMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController) {}
}

/// 自定义抽屉菜单
public class SideMenu: UIViewController, UIGestureRecognizerDelegate {
    struct InnerConstant {
        static let AnimationDuration = 0.25
        static let MenuWidthPercent = 0.75
        static let MaskColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
    }
    lazy private var coverView: UIControl = UIControl()
    public var animationDuration = InnerConstant.AnimationDuration
    public var menuWidthPercent = InnerConstant.MenuWidthPercent
    public var maskColor = InnerConstant.MaskColor
    var screenSize: CGSize {
        get {
            return UIScreen.mainScreen().bounds.size
        }
    }
    var menuWidth: CGFloat {
        get {
            return screenSize.width * CGFloat(menuWidthPercent)
        }
    }
    weak var masterViewController: UIViewController?
    weak var menuViewController: UIViewController?
    weak var delegate: SideMenuDelegate?
    
    var menuShowed = MutableProperty<Bool>(false)
    
    /// 跳转到菜单子项的Nav
    private var destNav: UINavigationController?
    private var originalPoint: CGPoint = CGPoint()
    private var lastDrugPoint: CGPoint = CGPoint()
    private var startDrugPoint: CGPoint = CGPoint()
    private var drug2Right = false
    private var panGestureRecognizer: UIPanGestureRecognizer?
    
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(masterViewController: UIViewController, menuViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.masterViewController = masterViewController
        self.menuViewController = menuViewController
        if let vc = masterViewController as? SideMenuProtocol {
            vc.sideMenu = self
        }
        if let vc = menuViewController as? SideMenuProtocol {
            vc.sideMenu = self
        }
        menuShowed.producer.startWithNext { [weak self] showed in
            if showed {
                self?.hideStatusBar()
            } else {
                self?.showStatusBar()
            }
        }
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized(_:)))
        self.panGestureRecognizer = panGestureRecognizer
        panGestureRecognizer.delegate = self
        menuViewController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    deinit {
        panGestureRecognizer?.delegate = nil
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
    }
    
    ///  监听滑动手势
    func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        delegate?.sideMenuDidRecognizePanGesture(self, recongnizer: recognizer)
        
        let currentView = menuViewController!.view   // 菜单视图
        let baseView = masterViewController!.view
        let velocity = recognizer.velocityInView(baseView)
        drug2Right = velocity.x > 0
        if currentView.x >= 0 {
            currentView.x = 0
        }
        if (currentView.x >= 0 && drug2Right) {
            return
        }
        if currentView.x <= -menuWidth {
            hideMenu()
            return
        }
        if recognizer.state == .Began {
            
        } else if (recognizer.state == .Changed) {
            let currentPoint: CGPoint = recognizer.translationInView(baseView)
            var xOffset = startDrugPoint.x + currentPoint.x
            if (xOffset >= 0 && drug2Right) {
                return
            }
            DDLogInfo("\(xOffset)  \(currentView.x)")
            if xOffset < 0 {
                if coverView.superview != nil {
                    xOffset = xOffset < -menuWidth ? -menuWidth : xOffset
                } else {
                    xOffset = 0
                }
            }
            if xOffset != currentView.x {
                currentView.x = xOffset
            }
        } else if (recognizer.state == .Ended) {
            if currentView.x == 0 {
                
            } else {
                if drug2Right && currentView.x < -menuWidth {
                    let animatedTime = abs((menuWidth + currentView.x) / menuWidth  * 0.25)
                    UIView.setAnimationCurve(.EaseInOut)
                    UIView.animateWithDuration(Double(animatedTime), animations: {
                        currentView.x = -self.menuWidth
                    })
                } else {
                    DDLogDebug("\(currentView.x)")
                }
            }
            if drug2Right {
                UIView.animateWithDuration(animationDuration, animations: {
                    currentView.x = 0
                })
            } else {
                hideMenu()
            }
            lastDrugPoint = CGPointZero
        }
        
    }
    
    // MARK: - 解决手势冲突问题
    @objc public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let gestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
        let cell = gestureRecognizer.view
        let point = gestureRecognizer.translationInView(cell?.superview)
        return fabsf(Float(point.x)) > fabsf(Float(point.y))
    }
    
    private func showStatusBar() {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    }
    private func hideStatusBar() {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
    }
    private func hideMenu() {
        menuShowed.value = false
        UIView.animateWithDuration(animationDuration, animations: {
            self.coverView.backgroundColor = UIColor.clearColor()
            self.menuViewController?.view.x = -self.menuWidth
        }) { _ in
            self.menuViewController?.view.removeFromSuperview()
            self.coverView.removeFromSuperview()
        }
    }
    
    public func click_mask() {
        DDLogInfo("Hide Side Menu")
        if let vc = menuViewController {
            delegate?.sideMenuDidHideMenuViewController(self, menuViewController: vc)
        }
        hideMenu()
    }
    
    public func routeToSideMenu(nextParams: Dictionary<String, AnyObject> = [:]) {
        DDLogInfo("Show Side Menu")
        if (coverView.superview == nil) {
            coverView.addTarget(self, action: #selector(click_mask), forControlEvents: UIControlEvents.TouchUpInside)
            coverView.frame = UIScreen.mainScreen().bounds
            coverView.backgroundColor = UIColor.clearColor()
            menuViewController?.view.frame = CGRectMake(-menuWidth, 0, menuWidth, screenSize.height)
            var view = masterViewController!.view
            if let nav = masterViewController?.navigationController {
                view = nav.view
            }
            view.addSubview(menuViewController!.view)
            view.insertSubview(coverView, belowSubview: menuViewController!.view)
            UIView.animateWithDuration(animationDuration) {
                self.coverView.backgroundColor = self.maskColor
                self.menuViewController?.view.x = 0
            }
            menuShowed.value = true
        }
    }
    
    public func routeToSideMaster(name: String, params nextParams: Dictionary<String, AnyObject> = [:]) {
        if let viewController = masterViewController?.initialedViewController(name, params: nextParams) {
            let navigationController = UINavigationController(rootViewController: viewController)
            let effect = PersentAnimator.sharedPersentAnimation.then { $0.presentStlye = .CoverVertical }
            navigationController.transitioningDelegate = effect
            masterViewController?.presentViewController(navigationController, animated: true, completion: nil)
            menuShowed.value = false
        }
    }
}
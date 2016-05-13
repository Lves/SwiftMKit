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

protocol SideMenuProtocol : NSObjectProtocol {
    var sideMenu: SideMenu? { get set }
}

// MARK: - 弹出菜单
@objc protocol SideMenuDelegate {
    optional func sideMenuDidRecognizePanGesture(sideMenu: SideMenu, recongnizer: UIPanGestureRecognizer)
    optional func sideMenuDidShowMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController)
    optional func sideMenuDidHideMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController)
}

/// 自定义抽屉菜单
public class SideMenu: UIViewController, UIGestureRecognizerDelegate {
    let screenSize = UIScreen.mainScreen().bounds.size
    lazy private var coverView: UIControl = UIControl()
    let duration = 0.25
    let factor: CGFloat = 0.75
    let menuWidth = UIScreen.mainScreen().bounds.size.width * 0.75
    
    // TODO: 内存泄露！！！
    weak var mainVc: UIViewController?
    var menuVc: UIViewController?
    /// 代理
    weak var delegate: SideMenuDelegate?
    /// 跳转到菜单子项的Nav
    private var destNav: UINavigationController?
    private var originalPoint: CGPoint = CGPoint()
    private var lastDrugPoint: CGPoint = CGPoint()
    private var startDrugPoint: CGPoint = CGPoint()
    private var drug2Right = false
    
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
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
    
    public init<T:UIViewController>(mainVc: T, menuVc: T) {
        super.init(nibName: nil, bundle: nil)
        self.mainVc = mainVc
        self.menuVc = menuVc
        if let vc = mainVc as? SideMenuProtocol {
            vc.sideMenu = self
        }
        if let vc = menuVc as? SideMenuProtocol {
            vc.sideMenu = self
        }
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized(_:)))
        panGestureRecognizer.delegate = self
        menuVc.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    ///  监听滑动手势
    func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        delegate?.sideMenuDidRecognizePanGesture?(self, recongnizer: recognizer)
        
        let currentView = menuVc!.view   // 菜单视图
        let baseView = mainVc!.view
        let velocity = recognizer.velocityInView(baseView)
        drug2Right = velocity.x > 0
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
                UIView.animateWithDuration(duration, animations: { 
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
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func hideMenu() {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        UIView.animateWithDuration(duration, animations: {
            self.menuVc!.view.frame = CGRectMake(-self.menuWidth, 0, self.menuWidth, self.screenSize.height)
        }) { (flag) in
            self.coverView.removeFromSuperview()
        }
    }
    
    @objc private func coverClick() {
        DDLogInfo("隐藏菜单")
        delegate?.sideMenuDidHideMenuViewController?(self, menuViewController: menuVc!)
        hideMenu()
    }
    
    public func routeToSideMenu(nextParams: Dictionary<String, AnyObject> = [:]) {
        if (coverView.superview == nil) {
            coverView.addTarget(self, action: #selector(coverClick), forControlEvents: UIControlEvents.TouchUpInside)
            coverView.frame = UIScreen.mainScreen().bounds
            coverView.backgroundColor = UIColor.init(r: 0, g: 0, b: 0, a: 0.45)
            menuVc?.view.frame = CGRectMake(-menuWidth, 0, menuWidth, screenSize.height)
            self.mainVc?.navigationController?.view.sendSubviewToBack(coverView)
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
            var view = mainVc!.view
            if let nav = mainVc?.navigationController {
                view = nav.view
            }
            view.addSubview(menuVc!.view)
            view.insertSubview(coverView, belowSubview: menuVc!.view)
            UIView.animateWithDuration(duration) {
                self.menuVc!.view.frame = CGRectMake(0, 0, self.menuWidth, self.screenSize.height)
            }
        }
    }
    
    public func routeToSideContainer(name: String, params nextParams: Dictionary<String, AnyObject> = [:]) {
        var destVc = initialedViewController(name, params: nextParams)
        if destVc == nil {
            destVc = NSObject.fromClassName(name) as? UIViewController
            if let title = nextParams["title"] {
                destVc?.title = title as? String
            }
        }
        if destVc != nil {
            let destNav = UINavigationController(rootViewController: destVc!)
            self.destNav = destNav
            let fromVc = self.mainVc?.navigationController
            let effect = PersentAnimator.sharedPersentAnimation.then { $0.presentStlye = .CoverVertical }
            destNav.transitioningDelegate = effect
            fromVc?.presentViewController(destNav, animated: true, completion: nil)
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        }
    }
    
    public class func routeToBack(nav: UINavigationController?) {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        nav?.dismissViewControllerAnimated(true, completion: nil)
    }
}
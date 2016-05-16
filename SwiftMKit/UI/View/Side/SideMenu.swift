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

public enum SideMenuDirection: Int {
    case Left, Right
}

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
    public var direction: SideMenuDirection = .Left
    public var interactive: Bool = true
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
    
    private var draggingPoint: CGPoint = CGPointZero
    private var lastDrugPoint: CGPoint = CGPoint()
    private var startDrugPoint: CGPoint = CGPoint()
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
        masterViewController.rac_signalForSelector(#selector(UIViewController.viewWillAppear(_:))).toSignalProducer().startWithNext { [weak self] _ in
            if self?.menuShowed.value ?? false {
                self?.hideStatusBar()
            }
        }
    }
    
    deinit {
        panGestureRecognizer?.delegate = nil
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
    }
    
    ///  监听滑动手势
    func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        if !interactive {
            return
        }
        delegate?.sideMenuDidRecognizePanGesture(self, recongnizer: recognizer)
        
        let translation = recognizer.translationInView(recognizer.view)
        recognizer.setTranslation(CGPointZero, inView: recognizer.view)
        let velocity = recognizer.velocityInView(recognizer.view)
        let newX = draggingPoint.x + translation.x
        var offsetX: CGFloat = 0
        switch direction {
        case .Left:
            offsetX = 0
            if newX < -menuWidth || newX > 0 { // [-menuWidth newX 0]
                return
            }
        case .Right: // [screenSize.width-menuWidth newX screenSize.width]
            offsetX = screenSize.width - menuWidth
            if newX < 0 || newX > menuWidth {
                return
            }
        }
        switch recognizer.state {
        case .Began:
            draggingPoint = translation
            recognizer.view?.x = draggingPoint.x + offsetX
        case .Changed:
            draggingPoint.x += translation.x
            recognizer.view?.x = draggingPoint.x + offsetX
        case .Ended:
            fallthrough
        case .Cancelled:
            switch direction {
            case .Left:
                if velocity.x < 0 || newX < -0.5 * menuWidth {
                    hideMenu()
                } else {
                    UIView.animateWithDuration(animationDuration) {
                        recognizer.view?.x = 0
                    }
                }
            case .Right:
                if velocity.x > 0 || newX > 0.5 * menuWidth {
                    hideMenu()
                } else {
                    UIView.animateWithDuration(animationDuration) {
                        recognizer.view?.x = offsetX
                    }
                }
            }
        default:
            break
        }
    }
    
    // 解决手势冲突问题
    @objc public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let view = gesture.view
            let translation = gesture.translationInView(view)
            return fabsf(Float(translation.x)) > fabsf(Float(translation.y))
        }
        return true
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
            switch self.direction {
            case .Left:
                self.menuViewController?.view.x = -self.menuWidth
            case .Right:
                self.menuViewController?.view.x = self.screenSize.width
            }
            
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
            var view = masterViewController!.view
            if let nav = masterViewController?.navigationController {
                view = nav.view
            }
            menuViewController?.view.frame = CGRectMake(0, 0, menuWidth, screenSize.height)
            view.addSubview(menuViewController!.view)
            view.insertSubview(coverView, belowSubview: menuViewController!.view)
            switch direction {
            case .Left:
                menuViewController?.view.x = -menuWidth
                UIView.animateWithDuration(animationDuration) {
                    self.coverView.backgroundColor = self.maskColor
                    self.menuViewController?.view.x = 0
                }
            case .Right:
                menuViewController?.view.x = screenSize.width
                UIView.animateWithDuration(animationDuration) {
                    self.coverView.backgroundColor = self.maskColor
                    self.menuViewController?.view.x = self.screenSize.width - self.menuWidth
                }
            }
            menuShowed.value = true
            if let vc = menuViewController {
                delegate?.sideMenuDidShowMenuViewController(self, menuViewController: vc)
            }
        }
    }
    
    public func routeToSideMaster(name: String, params nextParams: Dictionary<String, AnyObject> = [:]) {
        if let viewController = masterViewController?.initialedViewController(name, params: nextParams) {
            let navigationController = UINavigationController(rootViewController: viewController)
            let effect = PersentAnimator.sharedPersentAnimation.then { $0.presentStlye = .CoverVertical }
            navigationController.transitioningDelegate = effect
            masterViewController?.presentViewController(navigationController, animated: true, completion: nil)
            showStatusBar()
        }
    }
}
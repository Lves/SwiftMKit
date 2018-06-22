//
//  SideMenu.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/5/13.
//  Copyright © 2016年 cdts. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack
import ReactiveCocoa
import ReactiveSwift

public enum SideMenuDirection: Int {
    case left, right
}

protocol SideMenuProtocol : NSObjectProtocol {
    var sideMenu: SideMenu? { get set }
}

// MARK: - 弹出菜单
public protocol SideMenuDelegate: class {
    func sideMenuDidRecognizePanGesture(_ sideMenu: SideMenu, recongnizer: UIPanGestureRecognizer)
    func sideMenuDidShowMenuViewController(_ sideMenu: SideMenu, menuViewController: UIViewController)
    func sideMenuDidHideMenuViewController(_ sideMenu: SideMenu, menuViewController: UIViewController)
}
public extension SideMenuDelegate {
    func sideMenuDidRecognizePanGesture(_ sideMenu: SideMenu, recongnizer: UIPanGestureRecognizer) {}
    func sideMenuDidShowMenuViewController(_ sideMenu: SideMenu, menuViewController: UIViewController) {}
    func sideMenuDidHideMenuViewController(_ sideMenu: SideMenu, menuViewController: UIViewController) {}
}

/// 自定义抽屉菜单
open class SideMenu: UIViewController, UIGestureRecognizerDelegate {
    struct InnerConstant {
        static let AnimationDuration = 0.25
        static let MenuWidthPercent = 0.75
        static let MaskColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
    }
    lazy fileprivate var coverView: UIControl = UIControl()
    lazy fileprivate var shadowView: UIImageView = UIImageView(image: UIImage(named: "sideMenu_shadow"))
    open var animationDuration = InnerConstant.AnimationDuration
    open var menuWidthPercent = InnerConstant.MenuWidthPercent
    open var maskColor = InnerConstant.MaskColor
    open var direction: SideMenuDirection = .left
    open var interactive: Bool = true
    var screenSize: CGSize {
        get {
            return UIScreen.main.bounds.size
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
    
    fileprivate var draggingPoint: CGPoint = CGPoint.zero
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer?
    
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
        menuShowed.producer.startWithValues { [weak self] showed in
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
        masterViewController.reactive.trigger(for: #selector(UIViewController.viewWillAppear(_:))).observeValues { [weak self] _ in
            if self?.menuShowed.value ?? false {
                self?.hideStatusBar()
            }
        }
    }
    
    deinit {
        panGestureRecognizer?.delegate = nil
        DDLogError("Deinit: \(NSStringFromClass(type(of: self)))")
    }
    
    ///  监听滑动手势
    @objc func panGestureRecognized(_ recognizer: UIPanGestureRecognizer) {
        if !interactive {
            return
        }
        delegate?.sideMenuDidRecognizePanGesture(self, recongnizer: recognizer)
        
        let translation = recognizer.translation(in: recognizer.view)
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        let velocity = recognizer.velocity(in: recognizer.view)
        let newX = draggingPoint.x + translation.x

        var offsetX: CGFloat = 0
        switch direction {
        case .left:
            offsetX = 0
            if newX < -menuWidth || newX > 0 { // [-menuWidth newX 0]
                return
            }
        case .right: // [screenSize.width-menuWidth newX screenSize.width]
            offsetX = screenSize.width - menuWidth
            if newX < 0 || newX > menuWidth {
                return
            }
        }
        switch recognizer.state {
        case .began:
//            draggingPoint = translation
//            recognizer.view?.x = draggingPoint.x + offsetX
            draggingPoint = CGPoint.zero
            recognizer.view?.x = 0
        case .changed:
            draggingPoint.x += translation.x
            recognizer.view?.x = draggingPoint.x + offsetX
        case .ended:
            fallthrough
        case .cancelled:
            switch direction {
            case .left:
                if velocity.x < 0 || newX < -0.5 * menuWidth {
                    hideMenu()
                } else {
                    UIView.animate(withDuration: animationDuration) {
                        recognizer.view?.x = 0
                    }
                }
            case .right:
                if velocity.x > 0 || newX > 0.5 * menuWidth {
                    hideMenu()
                } else {
                    UIView.animate(withDuration: animationDuration) {
                        recognizer.view?.x = offsetX
                    }
                }
            }
        default:
            break
        }
        
        DDLogInfo("panGestureRecognized \(recognizer.state.rawValue) \(direction) \(recognizer.view?.x ?? 0)")
    }
    
    // 解决手势冲突问题
    @objc open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let view = gesture.view
            let translation = gesture.translation(in: view)
            return fabsf(Float(translation.x)) > fabsf(Float(translation.y))
        }
        return true
    }
    
    fileprivate func showStatusBar() {
        UIApplication.shared.isStatusBarHidden = false
    }
    fileprivate func hideStatusBar() {
        UIApplication.shared.isStatusBarHidden = true
    }
    open func hideMenu() {
        menuShowed.value = false
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.coverView.backgroundColor = UIColor.clear
            switch self.direction {
            case .left:
                self.menuViewController?.view.x = -self.menuWidth
            case .right:
                self.menuViewController?.view.x = self.screenSize.width
            }
            
        }, completion: { _ in
            self.menuViewController?.view.removeFromSuperview()
            self.coverView.removeFromSuperview()
            self.shadowView.isHidden = true
        }) 
    }
    
    @objc open func click_mask() {
        DDLogInfo("Hide Side Menu")
        if let vc = menuViewController {
            delegate?.sideMenuDidHideMenuViewController(self, menuViewController: vc)
        }
        hideMenu()
    }
    
    open func routeToSideMenu(_ nextParams: Dictionary<String, AnyObject> = [:]) {
        DDLogInfo("Show Side Menu")
        if (coverView.superview == nil) {
            coverView.addTarget(self, action: #selector(click_mask), for: UIControlEvents.touchUpInside)
            coverView.frame = UIScreen.main.bounds
            coverView.backgroundColor = UIColor.clear
            var view = masterViewController!.view
            if let nav = masterViewController?.navigationController {
                view = nav.view
            }
            menuViewController?.view.frame = CGRect(x: 0, y: 0, width: menuWidth, height: screenSize.height)
            menuViewController!.view.addSubview(shadowView)
            shadowView.h = self.view.h
            self.shadowView.isHidden = false

            view?.addSubview(menuViewController!.view)
            view?.insertSubview(coverView, belowSubview: menuViewController!.view)
            
            switch direction {
            case .left:
                shadowView.left = menuWidth
                menuViewController?.view.x = -menuWidth
                UIView.animate(withDuration: animationDuration, animations: {
                    self.coverView.backgroundColor = self.maskColor
                    self.menuViewController?.view.x = 0
                }) 
            case .right:
                shadowView.right = 0
                shadowView.transform = CGAffineTransform(rotationAngle: .pi);
                menuViewController?.view.x = screenSize.width
                UIView.animate(withDuration: animationDuration, animations: {
                    self.coverView.backgroundColor = self.maskColor
                    self.menuViewController?.view.x = self.screenSize.width - self.menuWidth
                }) 
            }
            menuShowed.value = true
            if let vc = menuViewController {
                delegate?.sideMenuDidShowMenuViewController(self, menuViewController: vc)
            }
        }
    }
    
    open func routeToSideMaster(_ name: String, params nextParams: Dictionary<String, AnyObject> = [:]) {
        routeToSideMaster(name, storyBoardName: nil, params: nextParams)
    }
    open func routeToSideMaster(_ name: String, storyBoardName: String?, params nextParams: Dictionary<String, AnyObject> = [:]) {
        if let viewController = masterViewController?.initialedViewController(name, params: nextParams, storyboardName: storyBoardName ?? "") {
            let navigationController = UINavigationController(rootViewController: viewController)        
            let effect = PersentAnimator.sharedPersentAnimation.then { $0.presentStlye = .coverVertical }
            navigationController.transitioningDelegate = effect
            masterViewController?.present(navigationController, animated: true, completion: nil)
            showStatusBar()
        }
    }
    open func routeToSideMaster(_ controller: UIViewController?) {
        if let viewController = controller {
            let navigationController = UINavigationController(rootViewController: viewController)
            let effect = PersentAnimator.sharedPersentAnimation.then { $0.presentStlye = .coverVertical }
            navigationController.transitioningDelegate = effect
            masterViewController?.present(navigationController, animated: true, completion: nil)
            showStatusBar()
        }
    }
}

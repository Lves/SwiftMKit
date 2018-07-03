//
//  UIViewController+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

public extension UIViewController {
    public static var topController: UIViewController? {
        get {
            var window = UIApplication.shared.keyWindow
            if window?.windowLevel != UIWindowLevelNormal {
                window = UIApplication.shared.windows.filter { $0.windowLevel == UIWindowLevelNormal }.first ?? window
            }
            
            let frontView = window?.subviews.last
            let nextResponder = frontView?.next
            
            func getTopFromVC(_ vc: UIViewController) -> UIViewController {
                var topController = vc
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                if let nav = topController as? UINavigationController {
                    if let vc = nav.viewControllers.last {
                        topController = vc
                    }
                } else if let tab = topController as? UITabBarController {
                    if let nav = tab.selectedViewController as? UINavigationController {
                        if let vc = nav.viewControllers.last {
                            topController = vc
                        }
                    } else {
                        topController = tab
                    }
                }
                return topController
            }
            if let vc = nextResponder as? UIViewController {
                return getTopFromVC(vc)
            } else {
                if let vc = window?.rootViewController {
                    return getTopFromVC(vc)
                }
                return nil
            }
        }
    }
}

//Alert
public extension UIViewController {
    
    public func showAlert(_ alert: UIAlertController, animated: Bool = true, completion: (() -> Void)?) {
        self.present(alert, animated: animated, completion: completion)
    }
}

//Route
public extension UIViewController {
    @discardableResult
    public func route(toName name: String, params nextParams: [String: Any] = [:], storyboardName: String? = "", animation: Bool = true, pop: Bool = false) -> Bool {
        DDLogInfo("Route name: \(name) (\(nextParams.stringFromHttpParameters()))")
        if let vc = initialedViewController(name, params: nextParams, storyboardName: storyboardName) {
            if pop {
                self.present(vc, animated: animation, completion: nil)
            } else {
                self.navigationController?.pushViewController(vc, animated: animation)
            }
            return true
        } else if canPerformSegue(withIdentifier: name){
            self.performSegue(withIdentifier: name, sender: ["params": nextParams])
            return true
        } else {
            DDLogError("Can't route to: \(name), please check the name")
            return false
        }
    }
    @discardableResult
    public func route(toUrl url: String, name: String, params nextParams: [String: Any] = [:], pop: Bool = false) -> Bool {
        var params = nextParams
        params["url"] = url as AnyObject?
        return route(toName: name, params: params, pop: pop)
    }
    @discardableResult
    public func routeBack(params: [String: Any] = [:], animation: Bool = true, completeion: (() -> Void)? = nil) -> Bool {
        DDLogInfo("Route back")
        if self.navigationController == nil || self.navigationController?.viewControllers.count == 1 {
            self.dismiss(animated: animation, completion: completeion)
            return true
        } else {
            let count = self.navigationController?.viewControllers.count ?? 0
            if count > 1 {
                if let vc = self.navigationController?.viewControllers[count - 2] {
                    if vc is BaseKitViewController {
                        let baseVC = vc as! BaseKitViewController
                        baseVC.params = params
                    }
                    return self.navigationController?.popToViewController(vc, animated: animation) != nil
                }
            }
            return self.navigationController?.popViewController(animated: animation) != nil
        }
    }
    @discardableResult
    public func routeBack(toName name: String, params: [String: Any] = [:], animation: Bool = true) -> Bool {
        DDLogInfo("Route back to \(name)")
        if self.navigationController == nil || self.navigationController?.viewControllers.count == 1 {
            return false
        } else {
            var vc: UIViewController?
            let count = self.navigationController?.viewControllers.count ?? 0
            for index in 0..<count {
                if let viewController = self.navigationController?.viewControllers[count - 1 - index] {
                    
                    if viewController.className == name { //NSStringFromClass(viewController.classForCoder)  这个返回的包含module名，不可用
                        vc = viewController
                        break
                    }
                }
            }
            if vc != nil {
                if vc is BaseKitViewController {
                    let baseVC = vc as! BaseKitViewController
                    baseVC.params = params
                }
                return self.navigationController?.popToViewController(vc!, animated: animation) != nil
            } else {
                return false
            }
        }
    }
    @discardableResult
    public func routeBack(toPageNumber pageNumber: Int, animation: Bool = true) -> Bool {
        DDLogInfo("Route back: \(pageNumber)")
        if self.navigationController == nil || self.navigationController?.viewControllers.count == 1 {
            self.dismiss(animated: animation, completion: nil)
            return true
        } else {
            let count = self.navigationController?.viewControllers.count ?? 0
            if count > pageNumber {
                if let vc = self.navigationController?.viewControllers[count - 1 - pageNumber] {
                    return self.navigationController?.popToViewController(vc, animated: animation) != nil
                }
            }
            return self.navigationController?.popViewController(animated: animation) != nil
        }
    }
    @discardableResult
    public func routeToRoot(animation: Bool = true) -> Bool {
        DDLogInfo("Route to root")
        return self.navigationController?.popToRootViewController(animated: animation) != nil
    }

    
    public func initialedViewController(_ name: String, params nextParams: [String: Any] = [:], storyboardName: String? = "") -> UIViewController? {
        var vc = instanceViewControllerInStoryboard(withName: name, storyboardName: storyboardName)
        if (vc == nil) {
            vc = instanceViewControllerInXib(withName: name)
        }
        if vc != nil {
            if let baseVC = vc as? BaseKitViewController {
                var params = nextParams
                if baseVC.autoHidesBottomBarWhenPushed {
                    if params["hidesBottomBarWhenPushed"] == nil {
                        params["hidesBottomBarWhenPushed"] = true as AnyObject?
                    }
                }
                baseVC.params = params
            } else if let baseVC = vc as? BaseKitTableViewController {
                var params = nextParams
                if baseVC.autoHidesBottomBarWhenPushed {
                    if params["hidesBottomBarWhenPushed"] == nil {
                        params["hidesBottomBarWhenPushed"] = true as AnyObject?
                    }
                }
                baseVC.params = params
            }
        }
        return vc
    }
    public func instanceViewControllerInXib(withName name: String) -> UIViewController? {
        let type = UIViewController.fullClassName(name) as? UIViewController.Type
        if let vc = type?.init(nibName: name, bundle: nil) {
            return vc
        }
        let nibPath = Bundle.main.path(forResource: name, ofType: "nib")
        if (nibPath != nil) {
            return NSObject.fromClassName(name) as? UIViewController
        }
        return nil
    }
    public func instanceViewControllerInStoryboard(withName name: String) -> UIViewController? {
        return self.instanceViewControllerInStoryboard(withName: name, storyboardName: nil)
    }
    public func instanceViewControllerInStoryboard(withName name: String, storyboardName: String?) -> UIViewController? {
        if let story = storyboardName != nil && storyboardName!.length > 0 ? UIStoryboard(name: storyboardName!, bundle: nil) : self.storyboard {
            if (story.value(forKey: "identifierToNibNameMap") as AnyObject).object(forKey: name) != nil {
                return story.instantiateViewController(withIdentifier: name)
            }
        }
        return nil
    }
    public class func instanceViewControllerInStoryboard(withName name: String, storyboardName: String) -> UIViewController? {
        let story = UIStoryboard(name: storyboardName, bundle: nil)
        if (story.value(forKey: "identifierToNibNameMap") as AnyObject).object(forKey: name) != nil {
            return story.instantiateViewController(withIdentifier: name)
        }
        return nil
    }
    public func canPerformSegue(withIdentifier identifier: String) -> Bool {
        let segueTemplates: AnyObject = self.value(forKey: "storyboardSegueTemplates") as AnyObject
        guard !(segueTemplates is NSNull) else {
            return false
        }
        let predicate = NSPredicate(format: "identifier = %@", identifier)
        let filteredArray: [Any] = segueTemplates.filtered(using: predicate)
        return filteredArray.count > 0
    }
    
    public func getStackIndexForViewController(withName name: String) -> Int? {
        if self.navigationController == nil || self.navigationController?.viewControllers.count == 1 {
            return nil
        } else {
            let count = self.navigationController?.viewControllers.count ?? 0
            for index in 0..<count {
                if let viewController = self.navigationController?.viewControllers[count - 1 - index] {
                    if NSStringFromClass(viewController.classForCoder) == name {
                        return index
                    }
                }
            }
        }
        return nil
    }
    
    public func navContainsViewController(name:String) -> Bool {
        if let nav = self.navigationController{
            let subVcs = nav.childViewControllers
            for vc in subVcs {
                if NSStringFromClass(vc.classForCoder) == name {
                    return true
                }
            }
        }
        return false
    }
    public func toNextViewController(viewController:UIViewController ,pop:Bool)  {
        if pop {
            let nav = UINavigationController(rootViewController: viewController)
            present(nav, animated: true, completion: nil)
        } else {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

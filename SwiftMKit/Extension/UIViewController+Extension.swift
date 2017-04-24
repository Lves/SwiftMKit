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
            var window = UIApplication.sharedApplication().keyWindow
            if window?.windowLevel != UIWindowLevelNormal {
                window = UIApplication.sharedApplication().windows.filter { $0.windowLevel == UIWindowLevelNormal }.first ?? window
            }
            
            let frontView = window?.subviews.last
            let nextResponder = frontView?.nextResponder()
            
            func getTopFromVC(vc: UIViewController) -> UIViewController {
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
    
    public func showAlert(alert: UIAlertController, animated: Bool = true, completion: (() -> Void)?) {
        self.presentViewController(alert, animated: animated, completion: completion)
    }
}

//Route
public extension UIViewController {
    public func routeToName(name: String, params nextParams: Dictionary<String, AnyObject> = [:], storyboardName: String? = "", animation: Bool = true, pop: Bool = false) -> Bool {
        DDLogInfo("Route name: \(name) (\(nextParams.stringFromHttpParameters()))")
        if let vc = initialedViewController(name, params: nextParams, storyboardName: storyboardName) {
            if pop {
                self.presentViewController(vc, animated: animation, completion: nil)
            } else {
                self.navigationController?.pushViewController(vc, animated: animation)
            }
            return true
        } else if canPerformSegueWithIdentifier(name){
            self.performSegueWithIdentifier(name, sender: ["params": nextParams])
            return true
        } else {
            DDLogError("Can't route to: \(name), please check the name")
            return false
        }
    }
    public func initialedViewController(name: String, params nextParams: Dictionary<String, AnyObject> = [:], storyboardName: String? = "") -> UIViewController? {
        var vc = instanceViewControllerInStoryboardWithName(name, storyboardName: storyboardName)
        if (vc == nil) {
            vc = instanceViewControllerInXibWithName(name)
        }
        if vc != nil {
            if let baseVC = vc as? BaseKitViewController {
                var params = nextParams
                if baseVC.autoHidesBottomBarWhenPushed {
                    if params["hidesBottomBarWhenPushed"] == nil {
                        params["hidesBottomBarWhenPushed"] = true
                    }
                }
                baseVC.params = params
            } else if let baseVC = vc as? BaseKitTableViewController {
                var params = nextParams
                if baseVC.autoHidesBottomBarWhenPushed {
                    if params["hidesBottomBarWhenPushed"] == nil {
                        params["hidesBottomBarWhenPushed"] = true
                    }
                }
                baseVC.params = params
            }
        }
        return vc
    }
    public func instanceViewControllerInXibWithName(name: String) -> UIViewController? {
        let type = UIViewController.fullClassName(name) as? UIViewController.Type
        if let vc = type?.init(nibName: name, bundle: nil) {
            return vc
        }
        let nibPath = NSBundle.mainBundle().pathForResource(name, ofType: "nib")
        if (nibPath != nil) {
            return NSObject.fromClassName(name) as? UIViewController
        }
        return nil
    }
    public func instanceViewControllerInStoryboardWithName(name: String) -> UIViewController? {
        return self.instanceViewControllerInStoryboardWithName(name, storyboardName: nil)
    }
    public func instanceViewControllerInStoryboardWithName(name: String, storyboardName: String?) -> UIViewController? {
        let story = storyboardName != nil && storyboardName?.length > 0 ? UIStoryboard(name: storyboardName!, bundle: nil) : self.storyboard
        if story?.valueForKey("identifierToNibNameMap")?.objectForKey(name) != nil {
            return story?.instantiateViewControllerWithIdentifier(name)
        }
        return nil
    }
    public class func instanceViewControllerInStoryboardWithName(name: String, storyboardName: String) -> UIViewController? {
        let story = UIStoryboard(name: storyboardName, bundle: nil)
        if story.valueForKey("identifierToNibNameMap")?.objectForKey(name) != nil {
            return story.instantiateViewControllerWithIdentifier(name)
        }
        return nil
    }
    public func canPerformSegueWithIdentifier(identifier: String) -> Bool {
        let segueTemplates = self.valueForKey("storyboardSegueTemplates")
        let filteredArray = segueTemplates?.filteredArrayUsingPredicate(NSPredicate(format: "identifier = %@", identifier))
        return filteredArray?.count > 0
    }
    
    public func routeToUrl(url: String, name: String = "BaseKitWebViewController", params nextParams: Dictionary<String, AnyObject> = [:], pop: Bool = false) {
        var params = nextParams
        params["url"] = url
        routeToName(name, params: params, pop: pop)
    }
    
    public func routeBack(params: Dictionary<String, AnyObject> = [:], animation: Bool = true, completeion: (() -> Void)? = nil) {
        DDLogInfo("Route back")
        if self.navigationController == nil || self.navigationController?.viewControllers.count == 1 {
            self.dismissViewControllerAnimated(animation, completion: completeion)
        } else {
            let count = self.navigationController?.viewControllers.count ?? 0
            if count > 1 {
                if let vc = self.navigationController?.viewControllers[count - 2] {
                    if vc is BaseKitViewController {
                        let baseVC = vc as! BaseKitViewController
                        baseVC.params = params
                    }
                    self.navigationController?.popToViewController(vc, animated: animation)
                    return
                }
            }
            self.navigationController?.popViewControllerAnimated(animation)
        }
    }
    public func routeBack(name name: String, params: Dictionary<String, AnyObject> = [:], animation: Bool = true) -> Bool {
        DDLogInfo("Route back to \(name)")
        if self.navigationController == nil || self.navigationController?.viewControllers.count == 1 {
            return false
        } else {
            var vc: UIViewController?
            let count = self.navigationController?.viewControllers.count ?? 0
            for index in 0..<count {
                if let viewController = self.navigationController?.viewControllers[count - 1 - index] {
                    if viewController.className == name {
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
                self.navigationController?.popToViewController(vc!, animated: animation)
                return true
            } else {
                return false
            }
        }
    }
    public func routeBack(pageNumber: Int, animation: Bool = true) {
        DDLogInfo("Route back: \(pageNumber)")
        if self.navigationController == nil || self.navigationController?.viewControllers.count == 1 {
            self.dismissViewControllerAnimated(animation, completion: nil)
        } else {
            let count = self.navigationController?.viewControllers.count ?? 0
            if count > pageNumber {
                if let vc = self.navigationController?.viewControllers[count - 1 - pageNumber] {
                    self.navigationController?.popToViewController(vc, animated: animation)
                    return
                }
            }
            self.navigationController?.popViewControllerAnimated(animation)
        }
    }
    public func routeToRoot(animation: Bool = true) {
        DDLogInfo("Route to root")
        self.navigationController?.popToRootViewControllerAnimated(animation)
    }
    public func getStackIndexForViewController(name name: String) -> Int? {
        if self.navigationController == nil || self.navigationController?.viewControllers.count == 1 {
            return nil
        } else {
//            var vc: UIViewController?
            let count = self.navigationController?.viewControllers.count ?? 0
            for index in 0..<count {
                if let viewController = self.navigationController?.viewControllers[count - 1 - index] {
                    if viewController.className == name {
                        return index
                    }
                }
            }
        }
        return nil
    }
    
    public func navContainsViewController(name:String) -> Bool {
        if let nav = self.navigationController{
            if let subVcs : [UIViewController] = nav.childViewControllers{
                for vc in subVcs {
                    if vc.className == name {
                        return true
                    }
                }
            }
        }
        return false
    }
}

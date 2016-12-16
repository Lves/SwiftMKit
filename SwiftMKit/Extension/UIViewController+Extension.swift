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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    public func routeToName(_ name: String, params nextParams: Dictionary<String, AnyObject> = [:], storyboardName: String? = "", animation: Bool = true, pop: Bool = false) -> Bool {
        DDLogInfo("Route name: \(name) (\(nextParams.stringFromHttpParameters()))")
        if let vc = initialedViewController(name, params: nextParams, storyboardName: storyboardName) {
            if pop {
                self.present(vc, animated: animation, completion: nil)
            } else {
                self.navigationController?.pushViewController(vc, animated: animation)
            }
            return true
        } else if canPerformSegueWithIdentifier(name){
            self.performSegue(withIdentifier: name, sender: ["params": nextParams])
            return true
        } else {
            DDLogError("Can't route to: \(name), please check the name")
            return false
        }
    }
    public func initialedViewController(_ name: String, params nextParams: Dictionary<String, AnyObject> = [:], storyboardName: String? = "") -> UIViewController? {
        var vc = instanceViewControllerInStoryboardWithName(name, storyboardName: storyboardName)
        if (vc == nil) {
            vc = instanceViewControllerInXibWithName(name)
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
            }else if let baseVC = vc as? LoanBaseKitViewController {
                baseVC.params = nextParams
            }
        }
        return vc
    }
    public func instanceViewControllerInXibWithName(_ name: String) -> UIViewController? {
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
    public func instanceViewControllerInStoryboardWithName(_ name: String) -> UIViewController? {
        return self.instanceViewControllerInStoryboardWithName(name, storyboardName: nil)
    }
    public func instanceViewControllerInStoryboardWithName(_ name: String, storyboardName: String?) -> UIViewController? {
        let story = storyboardName != nil && storyboardName?.length > 0 ? UIStoryboard(name: storyboardName!, bundle: nil) : self.storyboard
        if (story?.value(forKey: "identifierToNibNameMap") as AnyObject).object(forKey: name) != nil {
            return story?.instantiateViewController(withIdentifier: name)
        }
        return nil
    }
    public class func instanceViewControllerInStoryboardWithName(_ name: String, storyboardName: String) -> UIViewController? {
        let story = UIStoryboard(name: storyboardName, bundle: nil)
        if (story.value(forKey: "identifierToNibNameMap") as AnyObject).object(forKey: name) != nil {
            return story.instantiateViewController(withIdentifier: name)
        }
        return nil
    }
    public func canPerformSegueWithIdentifier(_ identifier: String) -> Bool {
        let segueTemplates: AnyObject = self.value(forKey: "storyboardSegueTemplates") as AnyObject
        let predicate = NSPredicate(format: "identifier = %@", identifier)
        let filteredArray: [Any] = segueTemplates.filtered(using: predicate)
        return filteredArray.count > 0
    }
    
    public func routeToUrl(_ url: String, name: String, params nextParams: Dictionary<String, AnyObject> = [:], pop: Bool = false) -> Bool {
        var params = nextParams
        params["url"] = url as AnyObject?
        return routeToName(name, params: params, pop: pop)
    }
    
    public func routeBack(_ params: Dictionary<String, AnyObject> = [:], animation: Bool = true, completeion: (() -> Void)? = nil) {
        DDLogInfo("Route back")
        if self.navigationController == nil || self.navigationController?.viewControllers.count == 1 {
            self.dismiss(animated: animation, completion: completeion)
        } else {
            let count = self.navigationController?.viewControllers.count ?? 0
            if count > 1 {
                if let vc = self.navigationController?.viewControllers[count - 2] {
                    if vc is BaseKitViewController {
                        let baseVC = vc as! BaseKitViewController
                        baseVC.params = params
                    }
                    let _ = self.navigationController?.popToViewController(vc, animated: animation)
                    return
                }
            }
            let _ = self.navigationController?.popViewController(animated: animation)
        }
    }
    public func routeBack(name: String, params: Dictionary<String, AnyObject> = [:], animation: Bool = true) -> Bool {
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
                let _ = self.navigationController?.popToViewController(vc!, animated: animation)
                return true
            } else {
                return false
            }
        }
    }
    public func routeBack(_ pageNumber: Int, animation: Bool = true) {
        DDLogInfo("Route back: \(pageNumber)")
        if self.navigationController == nil || self.navigationController?.viewControllers.count == 1 {
            self.dismiss(animated: animation, completion: nil)
        } else {
            let count = self.navigationController?.viewControllers.count ?? 0
            if count > pageNumber {
                if let vc = self.navigationController?.viewControllers[count - 1 - pageNumber] {
                    let _ = self.navigationController?.popToViewController(vc, animated: animation)
                    return
                }
            }
            let _ = self.navigationController?.popViewController(animated: animation)
        }
    }
    public func routeToRoot(_ animation: Bool = true) {
        DDLogInfo("Route to root")
        let _ = self.navigationController?.popToRootViewController(animated: animation)
    }
    public func getStackIndexForViewController(name: String) -> Int? {
        if self.navigationController == nil || self.navigationController?.viewControllers.count == 1 {
            return nil
        } else {
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
}

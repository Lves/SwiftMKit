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

//Route
public extension UIViewController {
    public func routeToName(name: String, params nextParams: Dictionary<String, AnyObject> = [:], pop: Bool = false) {
        DDLogInfo("Route name: \(name) (\(nextParams.stringFromHttpParameters()))")
        if let vc = initialedViewController(name, params: nextParams) {
            if pop {
                self.presentViewController(vc, animated: true, completion: nil)
            } else {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if canPerformSegueWithIdentifier(name){
            self.performSegueWithIdentifier(name, sender: ["params":nextParams])
        } else {
            DDLogError("Can't route to: \(name), please check the name")
        }
    }
    public func initialedViewController(name: String, params nextParams: Dictionary<String, AnyObject> = [:], storyboardName: String? = "") -> UIViewController? {
        var vc = instanceViewControllerInXibWithName(name)
        if (vc == nil) {
            vc = instanceViewControllerInStoryboardWithName(name, storyboardName: storyboardName)
        }
        if vc != nil {
            if vc is BaseKitViewController {
                var params = nextParams
                if params["hidesBottomBarWhenPushed"] == nil {
                    params["hidesBottomBarWhenPushed"] = true
                }
                let baseVC = vc as! BaseKitViewController
                baseVC.params = params
            }
        }
        return vc
    }
    public func instanceViewControllerInXibWithName(name: String) -> UIViewController? {
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
    
    public func routeBack(animation: Bool = true, completeion: (() -> Void)? = nil) {
        DDLogInfo("Route back")
        if self.navigationController == nil || self.navigationController?.viewControllers.count == 1 {
            self.dismissViewControllerAnimated(animation, completion: completeion)
        } else {
            self.navigationController?.popViewControllerAnimated(animation)
        }
    }
}
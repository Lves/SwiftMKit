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
        var vc = instanceViewControllerInXibWithName(name)
        if (vc == nil) {
            vc = instanceViewControllerInStoryboardWithName(name)
        }
        if vc != nil {
            if vc is BaseKitViewController {
                let baseVC = vc as! BaseKitViewController
                baseVC.params = nextParams
            }
            if pop {
                self.presentViewController(vc!, animated: true, completion: nil)
            } else {
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        } else if canPerformSegueWithIdentifier(name){
            self.performSegueWithIdentifier(name, sender: ["params":nextParams])
        } else {
            DDLogError("Can't route to: \(name), please check the name")
        }
    }
    public func instanceViewControllerInXibWithName(name: String) -> UIViewController? {
        let nibPath = NSBundle.mainBundle().pathForResource(name, ofType: "nib")
        if (nibPath != nil) {
            return NSBundle.mainBundle().loadNibNamed(name, owner: self, options: nil).first as? UIViewController
        }
        return nil
    }
    public func instanceViewControllerInStoryboardWithName(name: String, storyboardName: String = "Main") -> UIViewController? {
        let story = self.storyboard != nil ? self.storyboard : UIStoryboard(name: storyboardName, bundle: nil)
        if story?.valueForKey("identifierToNibNameMap")?.objectForKey(name) != nil {
            return story?.instantiateViewControllerWithIdentifier(name)
        }
        return nil
    }
    public func canPerformSegueWithIdentifier(identifier: String) -> Bool {
        let segueTemplates = self.valueForKey("storyboardSegueTemplates")
        let filteredArray = segueTemplates?.filteredArrayUsingPredicate(NSPredicate(format: "identifier = %@", identifier))
        return filteredArray?.count > 0
    }
}
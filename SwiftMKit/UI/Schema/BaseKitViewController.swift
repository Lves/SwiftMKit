//
//  BaseKitViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

public protocol IndicatorProtocol {
    func setIndicatorState(task: NSURLSessionTask?)
}

public class BaseKitViewController : UIViewController, IndicatorProtocol {
    public var params = Dictionary<String, AnyObject>() {
        didSet {
            for (key,value) in params {
                self.setValue(value, forKey: key)
            }
        }
    }
    public var viewModel: BaseKitViewModel! {
        get { return nil }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController
        if let bvc = vc as? BaseKitViewController {
            if let dict = sender as? NSDictionary {
                if let params = dict["params"] as? Dictionary<String, AnyObject> {
                    bvc.params = params
                }
            }
        }
    }
    
    public func setupUI() {
        viewModel.viewController = self
    }
    public func loadData() {
    }
    
    public func setIndicatorState(task: NSURLSessionTask?){
    }
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
    }
}

extension UIViewController {
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
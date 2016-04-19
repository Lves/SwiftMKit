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
import Alamofire
import MBProgressHUD
import ObjectiveC

public protocol HUDProtocol {
    func showHUDAddedTo(view: UIView, animated: Bool, text:String?)
    func showHUDTextAddedTo(view: UIView, animated: Bool, text:String?, hideAfterDelay:NSTimeInterval)
    func hideHUDForView(view: UIView, animated: Bool) -> Bool
}

public protocol IndicatorProtocol {
    var hud: HUDProtocol? { get set }
    var indicatorView: UIView? { get set }
    var indicatorText: String? { get set }
    func setIndicatorState(task: NSURLSessionTask?, text: String?)
    func setIndicatorState(task: NSURLSessionTask?, view: UIView, text: String?)
}

public class BaseKitViewController : UIViewController, IndicatorProtocol {
    struct InnerConstant {
        static let HideTipAfterDelay: NSTimeInterval = 2
    }
    public var params = Dictionary<String, AnyObject>() {
        didSet {
            for (key,value) in params {
                self.setValue(value, forKey: key)
            }
        }
    }
    public var hud: HUDProtocol? = HUDView()
    public var indicatorView: UIView?
    public var indicatorText: String?
    public var viewModel: BaseKitViewModel! {
        get { return nil }
    }
    private var taskObserver: TaskObserver!
    
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
        taskObserver = TaskObserver(viewController: self)
    }
    public func loadData() {
    }
    public func showEmptyView() {}
    public func hideEmptyView() {}
    public func showTip(tip: String) {
        showTip(tip, view: self.view.window!)
    }
    public func showTip(tip: String, view: UIView, hideAfterDelay: NSTimeInterval = InnerConstant.HideTipAfterDelay) {
        self.hud?.showHUDTextAddedTo(view, animated: true, text: tip, hideAfterDelay: hideAfterDelay)
    }
    
    public func setIndicatorState(task: NSURLSessionTask?, text: String?){
        setIndicatorState(task, view: self.view, text: text)
    }
    public func setIndicatorState(task: NSURLSessionTask?, view:UIView, text: String?){
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(taskObserver, name: Notifications.Task.DidResume, object: nil)
        notificationCenter.removeObserver(taskObserver, name: Notifications.Task.DidSuspend, object: nil)
        notificationCenter.removeObserver(taskObserver, name: Notifications.Task.DidCancel, object: nil)
        notificationCenter.removeObserver(taskObserver, name: Notifications.Task.DidComplete, object: nil)
        if let networkTask = task {
            networkTask.view = view
            networkTask.indicatorString = text
            if networkTask.state == .Running {
                notificationCenter.addObserver(taskObserver, selector: #selector(TaskObserver.task_resume(_:)), name: Notifications.Task.DidResume, object: networkTask)
                notificationCenter.addObserver(taskObserver, selector: #selector(TaskObserver.task_suspend(_:)), name: Notifications.Task.DidSuspend, object: networkTask)
                notificationCenter.addObserver(taskObserver, selector: #selector(TaskObserver.task_cancel(_:)), name: Notifications.Task.DidCancel, object: networkTask)
                notificationCenter.addObserver(taskObserver, selector: #selector(TaskObserver.task_end(_:)), name: Notifications.Task.DidComplete, object: networkTask)
                let notify = NSNotification(name: "", object: networkTask)
                taskObserver.task_resume(notify)
            } else {
                let notify = NSNotification(name: "", object: networkTask)
                taskObserver.task_end(notify)
            }
        }
    }
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
        NSNotificationCenter.defaultCenter().removeObserver(self.taskObserver)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

class TaskObserver: NSObject {
    private var viewController: BaseKitViewController
    init(viewController: BaseKitViewController) {
        self.viewController = viewController
    }
    
    @objc func task_resume(notify:NSNotification) {
        DDLogInfo("Task resume")
        UIApplication.sharedApplication().showNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            self.viewController.viewModel.runningApis.append(task)
            dispatch_async(dispatch_get_main_queue()) {
                self.viewController.hud?.showHUDAddedTo(task.view, animated: true, text: task.indicatorString)
            }
        }
    }
    @objc func task_suspend(notify:NSNotification) {
        DDLogInfo("Task suspend")
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            dispatch_async(dispatch_get_main_queue()) {
                self.viewController.hud?.hideHUDForView(task.view, animated: true)
            }
        }
    }
    @objc func task_cancel(notify:NSNotification) {
        DDLogInfo("Task cancel")
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            dispatch_async(dispatch_get_main_queue()) {
                self.viewController.hud?.hideHUDForView(task.view, animated: true)
            }
        }
    }
    @objc func task_end(notify:NSNotification) {
        DDLogInfo("Task complete")
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            if let index = self.viewController.viewModel.runningApis.indexOf(task) {
                self.viewController.viewModel.runningApis.removeAtIndex(index)
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.viewController.hud?.hideHUDForView(task.view, animated: true)
            }
        }
    }
}

private var viewAssociationKey: UInt8 = 0
private var indicatorStringAssociationKey: UInt8 = 0
extension NSURLSessionTask {
    var view: UIView! {
        get {
            return objc_getAssociatedObject(self, &viewAssociationKey) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &viewAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    var indicatorString: String? {
        get {
            return objc_getAssociatedObject(self, &indicatorStringAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &indicatorStringAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }
}

public class HUDView: HUDProtocol{
    public func showHUDAddedTo(view: UIView, animated: Bool, text:String?) {
        MBProgressHUD.hideHUDForView(view, animated: animated)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: animated)
        if let indicateString = text {
            hud.label.text = indicateString
        }
    }
    public func showHUDTextAddedTo(view: UIView, animated: Bool, text: String?, hideAfterDelay: NSTimeInterval) {
        MBProgressHUD.hideHUDForView(view, animated: animated)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: animated)
        hud.mode = .Text
        if let indicateString = text {
            hud.label.text = indicateString
        }
        hud.hideAnimated(animated, afterDelay: hideAfterDelay)
    }
    public func hideHUDForView(view: UIView, animated: Bool) -> Bool {
        return MBProgressHUD.hideHUDForView(view, animated: animated)
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
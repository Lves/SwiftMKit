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

public class BaseKitViewController : UIViewController {
    public var params = Dictionary<String, AnyObject>() {
        didSet {
            for (key,value) in params {
                self.setValue(value, forKey: key)
            }
        }
    }
    public var hud: HUDProtocol = MBHUDView()
    lazy public var indicator: IndicatorProtocol = {
        return TaskIndicator(hud: self.hud)
    }()
    
    public var viewModel: BaseKitViewModel? {
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
                if var params = dict["params"] as? Dictionary<String, AnyObject> {
                    if params["hidesBottomBarWhenPushed"] == nil {
                        params["hidesBottomBarWhenPushed"] = true
                    }
                    bvc.params = params
                }
            }
        }
    }
    
    public func setupUI() {
        viewModel?.viewController = self
        setupNavigation()
        setupNotification()
        bindingData()
    }
    public func setupNotification() {
    }
    public func setupNavigation() {
    }
    public func bindingData() {
    }
    public func loadData() {
    }
    public func showEmptyView() {}
    public func hideEmptyView() {}
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
        NSNotificationCenter.defaultCenter().removeObserver(self)
        DDLogInfo("Running tasks: \(indicator.runningTasks.count)")
        for task in indicator.runningTasks {
            DDLogInfo("Cancel task: \(task)")
            task.cancel()
        }
    }
}

public extension UIViewController {
        /// 禁用滑动返回
    var forbiddenSwipBackGesture: Bool {
        get {
            if let enable = navigationController?.interactivePopGestureRecognizer?.enabled {
                return !enable
            }
            return false
        }
        set {
            navigationController?.interactivePopGestureRecognizer?.enabled = !newValue
        }
    }
}

//HUD

public extension BaseKitViewController {
    
    public func showTip(tip: String, hideAfterDelay: NSTimeInterval = HUDConstant.HideTipAfterDelay, completion : () -> Void = {}) {
        showTip(tip, view: self.view, hideAfterDelay: hideAfterDelay, completion: completion)
    }
    public func showTip(tip: String, view: UIView, hideAfterDelay: NSTimeInterval = HUDConstant.HideTipAfterDelay, completion : () -> Void = {}) {
        self.hud.showHUDTextAddedTo(view, animated: true, text: tip, hideAfterDelay: hideAfterDelay, completion: completion)
    }
    public func showLoading(text: String = "") {
        showLoading(text, view: self.view)
    }
    public func showLoading(text: String, view: UIView) {
        self.hud.showHUDAddedTo(view, animated: true, text: text)
    }
    public func hideLoading() {
        hideLoading(self.view)
    }
    public func hideLoading(view: UIView) {
        self.hud.hideHUDForView(view, animated: true)
    }
}


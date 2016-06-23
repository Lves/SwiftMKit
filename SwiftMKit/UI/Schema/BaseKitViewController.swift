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
import SnapKit

public class BaseKitViewController : UIViewController, UIGestureRecognizerDelegate {
    public var params = Dictionary<String, AnyObject>() {
        didSet {
            for (key,value) in params {
                self.setValue(value, forKey: key)
            }
        }
    }
    public var completion: () -> Void = {}
    
    public var hud: HUDProtocol = MBHUDView()
    lazy public var indicator: IndicatorProtocol = {
        return TaskIndicator(hud: self.hud)
    }()
    
    public var viewModel: BaseKitViewModel? {
        get { return nil }
    }
    
    
    public let screenW: CGFloat = UIScreen.mainScreen().bounds.w
    public let screenH: CGFloat = UIScreen.mainScreen().bounds.h
    
    
    public var emptyViewYOffset: CGFloat {
        get { return 0 }
    }
    public var emptyTitle: String { get { return "暂无数据" } }
    
    public var emptyView: UIView? {
        get { return nil }
    }
    
    public var emptySuperView: UIView? {
        return view
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
        if let emptySuperView = emptySuperView {
            if let emptyView = emptyView {
                emptySuperView.addSubview(emptyView)
                emptyView.hidden = true
                emptyView.snp_makeConstraints { (make) in
                    make.centerX.equalTo(emptySuperView)
                    make.centerY.equalTo(emptySuperView).offset(emptyViewYOffset)
                }
            }
        }
        setupNavigation()
        setupNotification()
        bindingData()
    }
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    public func setupNotification() {
    }
    public func setupNavigation() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    public func bindingData() {
    }
    public func loadData() {
    }
    public func showEmptyView() {
        guard let emptyView = emptyView else { return }
        emptyView.hidden = false
    }
    public func showEmptyView(offset: CGFloat) {
        guard let emptyView = emptyView else { return }
        guard let emptySuperView = emptySuperView else { return }
        emptyView.snp_remakeConstraints { (make) in
            make.centerX.equalTo(emptySuperView)
            make.centerY.equalTo(emptySuperView).offset(offset)
        }
        emptyView.hidden = false
    }
    public func hideEmptyView() {
        guard let emptyView = emptyView else { return }
        emptyView.hidden = true
    }
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer) {
            //只有二级以及以下的页面允许手势返回
            return self.navigationController?.viewControllers.count > 1
        }
        return true
    }
    
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
    
    public func showTip(tip: String, completion : () -> Void = {}) {
        showTip(tip, view: self.view, hideAfterDelay: HUDConstant.HideTipAfterDelay, completion: completion)
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


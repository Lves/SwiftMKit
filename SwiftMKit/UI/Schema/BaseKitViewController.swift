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
    /// 页面参数（大部分用于初始化使用）
    public var params = [String: AnyObject]() {
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
    private var _forbiddenSwipBackGesture: Bool?
    /// 禁用手势滑动返回
    var forbiddenSwipBackGesture: Bool {
        get {
            if _forbiddenSwipBackGesture == nil {
                if let enable = navigationController?.interactivePopGestureRecognizer?.enabled {
                    _forbiddenSwipBackGesture = !enable
                }
            }
            return _forbiddenSwipBackGesture ?? false
        }
        set {
            _forbiddenSwipBackGesture = newValue
            navigationController?.interactivePopGestureRecognizer?.enabled = !newValue
        }
    }
    
    
    public var screenW: CGFloat { get { return UIScreen.mainScreen().bounds.w } }
    public var screenH: CGFloat { get { return UIScreen.mainScreen().bounds.h } }
    
    
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
        if self.navigationController?.viewControllers.first == self {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        }
        
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
    
//    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if (gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer) {
//            //只有二级以及以下的页面允许手势返回
//            return self.navigationController?.viewControllers.count > 1 && !forbiddenSwipBackGesture
//        }
//        return true
//    }
    
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

public extension UIViewController {
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


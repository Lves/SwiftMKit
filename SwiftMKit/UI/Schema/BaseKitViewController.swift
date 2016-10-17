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

public class BaseKitViewController : UIViewController {
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
    
    
    public var screenW: CGFloat { get { return UIScreen.mainScreen().bounds.w } }
    public var screenH: CGFloat { get { return UIScreen.mainScreen().bounds.h } }
    public var autoHidesBottomBarWhenPushed: Bool { get { return true } }
    
    public var emptyView: MKitEmptyView?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController
        if let bvc = vc as? BaseKitViewController {
            if let dict = sender as? NSDictionary {
                if var params = dict["params"] as? Dictionary<String, AnyObject> {
                    if autoHidesBottomBarWhenPushed {
                        if params["hidesBottomBarWhenPushed"] == nil {
                            params["hidesBottomBarWhenPushed"] = true
                        }
                    }
                    bvc.params = params
                }
            }
        }
    }
    
    public func setupUI() {
        viewModel?.viewController = self
        emptyView = MKitEmptyView(title: "暂无数据", image: UIImage(named: "view_empty")!, yOffset: 0, view: BaseKitEmptyView.getView(), inView: self.view)
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
    }
    public func bindingData() {
    }
    public func loadData() {
    }
    
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


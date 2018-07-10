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
import ObjectiveC
import SnapKit
@objcMembers
open class BaseKitViewController : UIViewController {
    /// 页面参数（大部分用于初始化使用）
    open var params = [String: Any]() {
        didSet {
            self.setValuesForKeys(params)
        }
    }
    
    fileprivate var _hud: HudProtocol = MBHud.shared
    open var hud: HudProtocol {
        get { return _hud }
    }
    lazy open var indicator: IndicatorProtocol = {
        return SingleApiIndicator(hud: self.hud)
    }()
    lazy open var taskIndicator: Indicator = {
        return TaskIndicator(hud: self.hud)
    }()
    
    
    open var viewModel: BaseKitViewModel? {
        get { return nil }
    }
    
    
    open var screenW: CGFloat { get { return UIScreen.main.bounds.w } }
    open var screenH: CGFloat { get { return UIScreen.main.bounds.h } }
    open var autoHidesBottomBarWhenPushed: Bool { get { return true } }
    
    open var emptyView: MKitEmptyView?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination
        if let bvc = vc as? BaseKitViewController {
            if let dict = sender as? [String: Any] {
                if var params = dict["params"] as? [String: Any] {
                    if params["hidesBottomBarWhenPushed"] == nil {
                        params["hidesBottomBarWhenPushed"] = true
                    }
                    bvc.params = params
                }
            }
        }
    }
    
    open func getEmptyView() -> BaseKitEmptyView {
        return BaseKitEmptyView.getView()
    }
    
    open func setupUI() {
        viewModel?.viewController = self
        emptyView = MKitEmptyView(title: "暂无数据", image: UIImage(named: "view_empty"), yOffset: 0, view: getEmptyView(), inView: self.view)
        setupNavigation()
        setupNotification()
        bindingData()
        bindedData()
    }
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    open func setupNotification() {
    }
    open func setupNavigation() {
    }
    open func bindingData() {
    }
    open func bindedData() {
        viewModel?.dataBinded()
    }
    open func loadData() {
    }
    
    public func willTerminate() {
    }
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(type(of: self)))")
        NotificationCenter.default.removeObserver(self)
    }
}


//HUD

public extension UIViewController {
    
    public func showTip(_ text: String?) {
        showTip(inView: self.view, text: text)
    }
    public func showTip(_ text: String, completion : @escaping () -> Void = {}) {
        showTip(inView: self.view, text: text, completion: completion)
    }

    public func showTip(_ text: String,duration: TimeInterval = HudConstant.hideTipAfterDelay , completion : @escaping () -> Void = {}) {
        showTip(inView: self.view, text: text, hideAfterDelay:duration, completion: completion)
    }
    public func showTip(inView view: UIView, text: String?, detailText: String? = nil, image: UIImage? = nil, hideAfterDelay: TimeInterval = HudConstant.hideTipAfterDelay, offset: CGPoint? = nil, animated: Bool = true, completion: @escaping (() -> Void) = {}) {
        MBHud.shared.showTip(inView: view, text: text, detailText: detailText, image: image, hideAfterDelay: hideAfterDelay, offset: offset, animated: animated, completion: completion)
    }
    public func showLoading(inView view: UIView,text: String? = nil) {
        showIndicator(inView: view, text: text, detailText: nil)
    }
    public func showLoading(text: String? = nil, detailText: String? = nil) {
        showIndicator(inView: self.view, text: text, detailText: detailText)
    }
    public func showIndicator(inView view: UIView, text: String?, detailText: String? = nil, animated: Bool = true) {
        MBHud.shared.showIndicator(inView: view, text: text, detailText: detailText, animated: animated)
    }
    public func showProgress(inView view: UIView, text: String?, detailText: String? = nil, cancelEnable: Bool? = false, cancelTitle: String? = nil, type: HudType = .determinate, animated: Bool = true) {
        MBHud.shared.showProgress(inView: view, text: text, detailText: detailText, cancelEnable: cancelEnable, cancelTitle: cancelTitle, type: type, animated: animated)
    }
    public func changeProgress(_ progress: Float) {
        MBHud.shared.change(progress: progress)
    }
    public func hideLoading() {
        hideLoading(self.view)
    }
    public func hideLoading(_ view: UIView) {
        MBHud.shared.hide(forView: view, animated: true)
    }
}


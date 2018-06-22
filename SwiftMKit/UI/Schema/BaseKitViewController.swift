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

open class BaseKitViewController : UIViewController {
    /// 页面参数（大部分用于初始化使用）
    open var params = [String: Any]() {
        didSet {
            for (key,value) in params {
                self.setValue(value, forKey: key)
            }
        }
    }
    
    fileprivate var _hud: HUDProtocol = MBHUDView.shared
    open var hud: HUDProtocol {
        get { return _hud }
    }
    lazy open var indicator: IndicatorProtocol = {
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
    
    @objc public func showTip(_ tip: String, completion : @escaping () -> Void = {}) {
        showTip(tip, view: self.view, completion: completion)
    }
    @objc public func showTip(_ tip: String, duration: TimeInterval, completion : @escaping () -> Void = {}) {
        MBHUDView.shared.showHUDTextAddedTo(view, animated: true, text: tip, detailText: nil, image: nil, hideAfterDelay: duration, offset: nil, completion: completion)
    }
    @objc public func showTip(_ tip: String, image: UIImage?, completion : @escaping () -> Void = {}) {
        MBHUDView.shared.showHUDTextAddedTo(view, animated: true, text: tip, detailText: nil, image: image, hideAfterDelay: HUDConstant.HideTipAfterDelay, offset: nil, completion: completion)
    }
    @objc public func showTip(_ tip: String, view: UIView, offset: CGPoint = CGPoint.zero, completion : @escaping () -> Void = {}) {
        MBHUDView.shared.showHUDTextAddedTo(view, animated: true, text: tip, detailText: nil, image: nil, hideAfterDelay: HUDConstant.HideTipAfterDelay, offset: offset, completion: completion)
    }
    public func showLoading(_ text: String = "", detailText: String = "") {
        showLoading(text, detailText: detailText, view: self.view)
    }
    public func showLoading(_ text: String, detailText: String = "", view: UIView) {
        MBHUDView.shared.showHUDAddedTo(view, animated: true, text: text, detailText: detailText)
    }
    public func showProgress(_ text: String = "", detailText: String = "") {
        showProgress(text, detailText: detailText, view: self.view)
    }
    public func showProgress(_ text: String, detailText: String = "", view: UIView, cancelEnable: Bool = false, cancelButtonTitle: String? = nil) {
        MBHUDView.shared.showHUDProgressAddedTo(view, animated: true, text: text, detailText: detailText, cancelEnable: cancelEnable, cancelTitle: cancelButtonTitle)
    }
    public func showProgressAnnularDeterminate(_ text: String, detailText: String = "", view: UIView, cancelEnable: Bool = false, cancelButtonTitle: String? = nil) {
        MBHUDView.shared.showHUDProgressAnnularDeterminateAddedTo(view, animated: true, text: text, detailText: detailText, cancelEnable: cancelEnable, cancelTitle: cancelButtonTitle)
    }
    public func showProgressHorizontalBar(_ text: String, detailText: String = "", view: UIView, cancelEnable: Bool = false, cancelButtonTitle: String? = nil) {
        MBHUDView.shared.showHUDProgressHorizontalBarAddedTo(view, animated: true, text: text, detailText: detailText, cancelEnable: cancelEnable, cancelTitle: cancelButtonTitle)
    }
    public func changeProgress(_ progress: Float) {
        MBHUDView.shared.changeHUDProgress(progress)
    }
    public func hideLoading() {
        hideLoading(self.view)
    }
    public func hideLoading(_ view: UIView) {
        let _ = MBHUDView.shared.hideHUDForView(view, animated: true)
    }
}


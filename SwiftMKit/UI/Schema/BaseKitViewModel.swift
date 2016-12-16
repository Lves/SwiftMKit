//
//  BaseKitViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Alamofire

open class BaseKitViewModel: NSObject {
    open weak var viewController: BaseKitViewController!
    open var hud: HUDProtocol {
        get { return self.viewController.hud }
    }
    open var indicator: IndicatorProtocol {
        get { return self.viewController.indicator }
    }
    open var view: UIView {
        get { return self.viewController.view }
    }
    open func fetchData() {
    }
    open func dataBinded() {
    }
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(type(of: self)))")
    }
}

//HUD

extension BaseKitViewModel {
    
    public func showTip(_ tip: String, completion : @escaping () -> Void = {}) {
        viewController.showTip(tip, view: viewController.view, completion: completion)
    }
    public func showTip(_ tip: String, image: UIImage?, completion : @escaping () -> Void = {}) {
        viewController.showTip(tip, image: image, completion: completion)
    }
    public func showTip(_ tip: String, view: UIView, offset: CGPoint = CGPoint.zero, completion : @escaping () -> Void = {}) {
        viewController.showTip(tip, view: view, offset: offset, completion: completion)
    }
    public func showLoading(_ text: String = "") {
        viewController.showLoading(text)
    }
    public func showLoading(_ text: String, view: UIView) {
        viewController.showLoading(text, view: view)
    }
    public func hideLoading() {
        viewController.hideLoading()
    }
    public func hideLoading(_ view: UIView) {
        viewController.hideLoading(view)
    }
    
}

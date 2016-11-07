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

public class BaseKitViewModel: NSObject {
    public weak var viewController: BaseKitViewController!
    public var hud: HUDProtocol {
        get { return self.viewController.hud }
    }
    public var indicator: IndicatorProtocol {
        get { return self.viewController.indicator }
    }
    public var view: UIView {
        get { return self.viewController.view }
    }
    public func fetchData() {
    }
    public func dataBinded() {
    }
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
    }
}

//HUD

extension BaseKitViewModel {
    
    public func showTip(tip: String, completion : () -> Void = {}) {
        viewController.showTip(tip, view: viewController.view, completion: completion)
    }
    public func showTip(tip: String, image: UIImage?, completion : () -> Void = {}) {
        viewController.showTip(tip, image: image, completion: completion)
    }
    public func showTip(tip: String, view: UIView, offset: CGPoint = CGPointZero, completion : () -> Void = {}) {
        viewController.showTip(tip, view: view, offset: offset, completion: completion)
    }
    public func showLoading(text: String = "") {
        viewController.showLoading(text)
    }
    public func showLoading(text: String, view: UIView) {
        viewController.showLoading(text, view: view)
    }
    public func hideLoading() {
        viewController.hideLoading()
    }
    public func hideLoading(view: UIView) {
        viewController.hideLoading(view)
    }
    
}
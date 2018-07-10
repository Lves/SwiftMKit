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
    open var hud: HudProtocol {
        get { return self.viewController.hud }
    }
    open var taskIndicator: Indicator {
        get { return self.viewController.taskIndicator }
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
        viewController.showTip(inView: viewController.view, text: tip, completion: completion)
    }
    public func showTip(_ tip: String, image: UIImage?, completion : @escaping () -> Void = {}) {
        viewController.showTip(inView: viewController.view, text: tip, image: image, completion: completion)
    }
    public func showTip(_ tip: String, view: UIView, offset: CGPoint = CGPoint.zero, completion : @escaping () -> Void = {}) {
        viewController.showTip(inView: view, text: tip, offset: offset, completion: completion)
    }
    public func showLoading(text: String? = nil, detailText: String? = nil) {
        viewController.showLoading(text: text, detailText: detailText)
    }
    public func showLoading(_ text: String, view: UIView) {
        viewController.showIndicator(inView: view, text: text)
    }
    public func hideLoading() {
        viewController?.hideLoading()
    }
    public func hideLoading(_ view: UIView) {
        viewController?.hideLoading(view)
    }
    
}

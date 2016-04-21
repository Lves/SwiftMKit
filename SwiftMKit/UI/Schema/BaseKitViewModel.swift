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
    lazy public var runningApis = [NSURLSessionTask]()
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
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
    }
}

//HUD

extension BaseKitViewModel {
    
    public func showTip(tip: String) {
        showTip(tip, view: self.view.window!)
    }
    public func showTip(tip: String, view: UIView, hideAfterDelay: NSTimeInterval = HUDConstant.HideTipAfterDelay) {
        self.hud.showHUDTextAddedTo(view, animated: true, text: tip, hideAfterDelay: hideAfterDelay)
    }
}
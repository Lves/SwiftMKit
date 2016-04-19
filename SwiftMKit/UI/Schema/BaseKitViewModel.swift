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
    public var hud: HUDProtocol? {
        get { return self.viewController.hud }
    }
    public func fetchData() {
    }
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
        DDLogInfo("Running tasks: \(runningApis.count)")
        for task in runningApis {
            DDLogInfo("Cancel task: \(task)")
            task.cancel()
        }
    }
}

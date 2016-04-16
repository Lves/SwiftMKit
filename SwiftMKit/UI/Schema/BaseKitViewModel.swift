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
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
    }
}

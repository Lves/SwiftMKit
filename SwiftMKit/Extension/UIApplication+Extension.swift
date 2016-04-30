//
//  UIApplication+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit

public extension UIApplication {
    @nonobjc static var activityCount: Int = 0
    func showNetworkActivityIndicator() {
        if UIApplication.sharedApplication().statusBarHidden {
            return
        }
        let lockQueue = dispatch_queue_create("com.cdts.LockQueue", nil)
        dispatch_sync(lockQueue) {
            if UIApplication.activityCount == 0 {
                self.networkActivityIndicatorVisible = true
            }
            UIApplication.activityCount += 1
        }
    }
    func hideNetworkActivityIndicator() {
        if UIApplication.sharedApplication().statusBarHidden {
            return
        }
        let lockQueue = dispatch_queue_create("com.cdts.LockQueue", nil)
        dispatch_sync(lockQueue) {
            UIApplication.activityCount -= 1
            if UIApplication.activityCount <= 0 {
                self.networkActivityIndicatorVisible = false
                UIApplication.activityCount = 0
            }
        }
    }
}
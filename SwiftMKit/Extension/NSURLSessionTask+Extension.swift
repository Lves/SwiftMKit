//
//  NSURLSessionTask+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

private var indicatorViewAssociationKey: UInt8 = 0
private var indicatorTextAssociationKey: UInt8 = 0

extension URLSessionTask {
    var indicatorView: UIView? {
        get {
            return objc_getAssociatedObject(self, &indicatorViewAssociationKey) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &indicatorViewAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    var indicatorText: String? {
        get {
            return objc_getAssociatedObject(self, &indicatorTextAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &indicatorTextAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }
}

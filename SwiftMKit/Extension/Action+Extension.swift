//
//  Action+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/19/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import UIKit

public extension Action {
    public func bindEnabled(_ button: UIButton) {
        self.privateCocoaAction.isEnabled.producer.startWithValues { enabled in
            button.isEnabled = enabled
            button.viewController?.view.isUserInteractionEnabled = enabled
            button.viewController?.view.endEditing(false)
        }
    }
    public var toCocoaAction: CocoaAction<Any> {
        get {
            privateCocoaAction = CocoaAction(self) { input in
                if let button = input as? UIButton {
                    self.bindEnabled(button)
                }
                return input as! Input
            }
            return privateCocoaAction
        }
    }
}


private var privateCocoaActionAssociationKey: UInt8 = 0

extension Action {
    var privateCocoaAction: CocoaAction<Any> {
        get {
            return objc_getAssociatedObject(self, &privateCocoaActionAssociationKey) as! CocoaAction
        }
        set(newValue) {
            objc_setAssociatedObject(self, &privateCocoaActionAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

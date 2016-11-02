//
//  Action+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/19/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import ReactiveCocoa

public extension Action {
    public func bindEnabled(button: UIButton) {
        self.unsafeCocoaAction.rac_valuesForKeyPath("enabled", observer: nil).toSignalProducer().map{ $0! as! Bool }.startWithNext { enabled in
            button.enabled = enabled
            button.viewController?.view.userInteractionEnabled = enabled
            button.viewController?.view.endEditing(false)
        }
    }
    public var toCocoaAction: CocoaAction {
        get {
            unsafeCocoaAction = CocoaAction(self) { input in
                if let button = input as? UIButton {
                    self.bindEnabled(button)
                }
                return input as! Input
            }
            return unsafeCocoaAction
        }
    }
}

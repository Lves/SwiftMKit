//
//  UIButton+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/19/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa

public extension UIButton {
    /// cornerRadius
    @IBInspectable
    public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    /// borderColor
    @IBInspectable
    public var borderColor: UIColor {
        get {
            return UIColor(CGColor: layer.borderColor ?? UIColor.clearColor().CGColor)
        }
        set {
            layer.borderColor = newValue.CGColor
        }
    }
    /// borderWidth
    @IBInspectable
    public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
}

extension UIControl {
    func addTarget_(target: AnyObject?) {
        addTarget(target, action: CocoaAction.selector, forControlEvents: .TouchUpInside)
    }
}
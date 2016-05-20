//
//  UIButton+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/19/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit

public extension UIButton {
    /// cornerRadius
    public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    /// borderColor
    public var borderColor: UIColor {
        get {
            return UIColor(CGColor: layer.borderColor ?? UIColor.clearColor().CGColor)
        }
        set {
            layer.borderColor = newValue.CGColor
        }
    }
    /// borderWidth
    public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
}
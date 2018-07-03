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
            layer.masksToBounds = newValue > 0
            layer.cornerRadius = newValue
        }
    }
    /// borderColor
    @IBInspectable
    public var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
        }
        set {
            layer.borderColor = newValue.cgColor
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
    func setBackgroundColor(_ color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let currentGraphicsContext = UIGraphicsGetCurrentContext() {
            currentGraphicsContext.setFillColor(color.cgColor)
            currentGraphicsContext.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: state)
    }
    
}

extension UIControl {
    func addTarget_(_ target: AnyObject?) {
        addTarget(target, action: CocoaAction<Any>.selector, for: .touchUpInside)
    }
}

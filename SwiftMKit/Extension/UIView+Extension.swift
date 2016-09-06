//
//  UIView+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/17/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
public extension UIView {
    struct InnerConstant {
        static let BlurViewTag = 1001
    }
    
    func shake(count: Int, directionX: CGFloat = 3, directionY: CGFloat = 0) {
        UIView.animateWithDuration(0.05, animations: {
            self.transform = CGAffineTransformMakeTranslation(directionX, directionY)
        }) { finished in
            if count <= 0 {
                self.transform = CGAffineTransformIdentity
                return
            }
            self.shake(count - 1, directionX: directionX * -1, directionY: directionY * -1)
        }
    }
    
    func addBlur(style: UIBlurEffectStyle = .Dark) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.tag = InnerConstant.BlurViewTag
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
    func removeBlur() {
        let view = self.viewWithTag(InnerConstant.BlurViewTag)
        view?.removeFromSuperview()
    }
    /*UIView 在sb中设置圆角*/
    @IBInspectable var mCornerRadius:CGFloat{
        set{
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    /// borderColor
    @IBInspectable
    public var mBorderColor: UIColor {
        get {
            return UIColor(CGColor: layer.borderColor ?? UIColor.clearColor().CGColor)
        }
        set {
            layer.borderColor = newValue.CGColor
        }
    }
    /// borderWidth
    @IBInspectable
    public var mBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /**
     获取view所在的控制器
     
     - returns: view所在的控制器
     */
    func getViewController() -> UIViewController? {
        var vc: UIViewController?
        var next = self.nextResponder()
        while next != nil {
            if (next?.isKindOfClass(UIViewController.self) ?? false) == true {
                vc = next as? UIViewController
                break
            }
            next = next?.nextResponder()
        }
        return vc
    }
    
    /**
     查找一个视图的所有子视图
     
     - returns: 一个视图的所有子视图
     */
    func recursiveAllSubViews() -> [UIView] {
        var array = [UIView]()
        for subview in self.subviews {
            array.append(subview)
            let views = subview.recursiveAllSubViews()
            for innerSubView in views {
                array.append(innerSubView)
            }
        }
        return array
    }
}
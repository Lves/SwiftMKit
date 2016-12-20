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
    
    func shake(withCount count: Int, directionX: CGFloat = 3, directionY: CGFloat = 0) {
        UIView.animate(withDuration: 0.05, animations: {
            self.transform = CGAffineTransform(translationX: directionX, y: directionY)
        }, completion: { finished in
            if count <= 0 {
                self.transform = CGAffineTransform.identity
                return
            }
            self.shake(withCount: count - 1, directionX: directionX * -1, directionY: directionY * -1)
        }) 
    }
    
    func addBlur(style: UIBlurEffectStyle = .dark) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.tag = InnerConstant.BlurViewTag
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
    func removeBlur() {
        let view = self.viewWithTag(InnerConstant.BlurViewTag)
        view?.removeFromSuperview()
    }
    /*UIView 在sb中设置圆角*/
    @IBInspectable var layerCornerRadius: CGFloat{
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
    public var layerBorderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    /// borderWidth
    @IBInspectable
    public var layerBorderWidth: CGFloat {
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
        var next = self.next
        while next != nil {
            if (next?.isKind(of: UIViewController.self) ?? false) == true {
                vc = next as? UIViewController
                break
            }
            next = next?.next
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

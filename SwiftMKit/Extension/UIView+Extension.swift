//
//  UIView+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/17/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit

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

}
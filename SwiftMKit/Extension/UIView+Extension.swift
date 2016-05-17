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
}
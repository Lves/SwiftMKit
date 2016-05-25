//
//  PasswordText.swift
//  SwiftMKitDemo
//
//  Created by jimubox on 16/5/24.
//  Copyright © 2016年 cdts. All rights reserved.
//

import Foundation
import UIKit

public class PasswordText : UIView {
    private struct InnerConstant {
        static let kNumCount = 6
        static let PasswordViewKeyboardNumberKey = "PasswordViewKeyboardNumberKey"
        static let PasswordViewPointnWH: CGFloat = 10
        static let PassWordViewTextFieldH: CGFloat = 55
    }
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var point1: UIView!
    @IBOutlet weak var point2: UIView!
    @IBOutlet weak var point3: UIView!
    @IBOutlet weak var point4: UIView!
    @IBOutlet weak var point5: UIView!
    @IBOutlet weak var point6: UIView!
    var buttonNumbers: [UIView] {
        get {
            return [point1,point2,point3,point4,point5,point6]
        }
    }
    public var passwordLength: UInt = 0 {
        didSet {
            passwordLength = min(passwordLength, 6)
            for index in 0..<passwordLength {
                let point = buttonNumbers[Int(index)]
                point.hidden = false
            }
            for index in passwordLength..<6 {
                let point = buttonNumbers[Int(index)]
                point.hidden = true
            }
            setNeedsDisplay()
        }
    }

    public static func passwordText() -> PasswordText! {
        let view = NSBundle.mainBundle().loadNibNamed("PasswordText", owner: self, options: nil).first as? PasswordText
        return view!
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        //把背景色设为透明
        self.backgroundColor = UIColor.clearColor()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}



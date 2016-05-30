//
//  PasswordText.swift
//  SwiftMKitDemo
//
//  Created by jimubox on 16/5/24.
//  Copyright © 2016年 cdts. All rights reserved.
//

import Foundation
import UIKit

public class PasswordTextView : UIView {
    private struct InnerConstant {
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
    public var passwordLength: Int = 0 {
        didSet {
            let maxCount = buttonNumbers.count
            passwordLength = max(passwordLength, 0)
            passwordLength = min(passwordLength, maxCount)
            for button in buttonNumbers {
                button.hidden = (button.tag > passwordLength)
            }
            setNeedsDisplay()
        }
    }

    public static func passwordTextView() -> PasswordTextView! {
        let view = NSBundle.mainBundle().loadNibNamed("PasswordTextView", owner: self, options: nil).first as! PasswordTextView
        return view
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    func setupUI() {
        //把背景色设为透明
        self.backgroundColor = UIColor.clearColor()
    }
}



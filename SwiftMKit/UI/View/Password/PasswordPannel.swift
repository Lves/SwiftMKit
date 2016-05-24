//
//  PasswordPannel.swift
//  SwiftMKitDemo
//
//  Created by jimubox on 16/5/24.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

public class PasswordPannel: UIView {
    private struct InnerConstant {
        let PasswordViewTextFieldMarginTop = 25
        let PasswordViewTitleHeight = 55
        let PasswordViewTextFieldWidth = 297
        let PasswordViewTextFieldHeight = 50
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public static func pannel() -> UIView? {
        let view = NSBundle.mainBundle().loadNibNamed("PasswordPannel", owner: self, options: nil).first as? PasswordPannel
        //把背景色设为透明
        view?.backgroundColor = UIColor.clearColor()
        return view
    }
}
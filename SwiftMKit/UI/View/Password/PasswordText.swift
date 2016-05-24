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
    public var passwordLength: UInt = 0 {
        didSet {
            if passwordLength > 6 {
                passwordLength = 6
            }
            
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        //把背景色设为透明
        self.backgroundColor = UIColor.clearColor()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func drawRect(rect: CGRect) {
        
        if let imgText = UIImage.init(named: "password_textfield") {
            imgText.drawInRect(rect)
        }
    }
}



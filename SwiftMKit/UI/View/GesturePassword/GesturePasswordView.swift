//
//  GesturePasswordView.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

@IBDesignable
public class GesturePasswordView: UIView {
    
    public var padding: CGFloat = 20
    public var buttons = [GesturePasswordButton]()
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public func setupUI() {
        self.backgroundColor = UIColor.clearColor()
        let length = (self.w - 2 * padding) / 3
        for index in 0..<9 {
            let row = index / 3
            let col = index % 3
            let button = GesturePasswordButton(frame: CGRectMake(CGFloat(row) * (length + padding), CGFloat(col) * (length + padding), length, length))
            button.tag = index
            buttons.append(button)
            self.addSubview(button)
        }
    }
}

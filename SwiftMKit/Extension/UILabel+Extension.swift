//
//  UILabel+Extension.swift
//  Merak
//
//  Created by Mao on 6/1/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import Foundation
import UIKit

public extension UILabel {
    func addCharactersSpacing(_ spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, text.characters.count))
        self.attributedText = attributedString
    }
}

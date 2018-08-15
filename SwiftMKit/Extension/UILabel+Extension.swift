//
//  UILabel+Extension.swift
//  Merak
//
//  Created by Mao on 6/1/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation
import UIKit

public extension UILabel {
    func addCharactersSpacing(_ spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.kern, value: spacing, range: NSMakeRange(0, text.count))
        self.attributedText = attributedString
    }
}

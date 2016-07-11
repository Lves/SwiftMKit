//
//  NSRange+Extension.swift
//  Merak
//
//  Created by Mao on 6/13/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import Foundation
import UIKit

extension NSRange {
    func toTextRange(textInput textInput:UITextInput) -> UITextRange? {
        if let rangeStart = textInput.positionFromPosition(textInput.beginningOfDocument, offset: location),
            rangeEnd = textInput.positionFromPosition(rangeStart, offset: length) {
            return textInput.textRangeFromPosition(rangeStart, toPosition: rangeEnd)
        }
        return nil
    }
}
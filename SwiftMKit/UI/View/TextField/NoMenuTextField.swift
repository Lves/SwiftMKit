//
//  NoMenuTextField.swift
//  Merak
//
//  Created by Mao on 6/23/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import Foundation
import UIKit

public class NoMenuTextField: UITextField {
    override public func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(UIResponder.paste(_:)) || action == #selector(UIResponder.copy(_:)) || action == #selector(UIResponder.selectAll(_:)) || action == #selector(UIResponder.select(_:)) {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}

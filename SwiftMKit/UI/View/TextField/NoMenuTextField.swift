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
        if action == #selector(NSObject.paste(_:)) || action == #selector(NSObject.copy(_:)) || action == #selector(NSObject.selectAll(_:)) || action == #selector(NSObject.select(_:)) {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}
//
//  NumberKeyboardProtocol.swift
//  SwiftMKitDemo
//
//  Created by Juxin on 5/19/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit

public protocol NumberKeyboardProtocol {
    var type: NumberKeyboardType { get set }
    func clear()
    func matchInputDot(old : String, new : String) -> (String, NSRange)
    func matchInputNumber(old : String, new : String) -> (String, NSRange)
    func matchInputDel(old : String, new : String) -> (String, NSRange)
    //删除小数点
    func matchDeleteDot(old : String, new : String) -> (String, NSRange)
    //删除数字
    func matchDeleteNumber(old : String, new : String) -> (String, NSRange)
    static func keyboard(textField: UITextField, type:NumberKeyboardType) -> UIView?
}

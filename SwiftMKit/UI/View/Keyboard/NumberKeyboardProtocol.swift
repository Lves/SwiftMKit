//
//  NumberKeyboardProtocol.swift
//  SwiftMKitDemo
//
//  Created by Juxin on 5/19/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

public enum NumberKeyboardType: Int {
    case normal, noDot, money
}
public enum NumberKeyboardStyle: Int {
    case `default`
}
public protocol NumberKeyboardProtocol {
    var type: NumberKeyboardType { get set }
    func clear()
    //输入小数点---匹配
    func matchInputDot(_ old : String, new : String) -> (String, NSRange)
    //输入数字---匹配
    func matchInputNumber(_ old : String, new : String) -> (String, NSRange)
    //删除小数点---匹配
    func matchDeleteDot(_ old : String, new : String) -> (String, NSRange)
    //删除数字---匹配
    func matchDeleteNumber(_ old : String, new : String) -> (String, NSRange)
    //确定---匹配
    func matchConfirm(_ input : String) -> String
    static func keyboard(_ textField: UITextField, type: NumberKeyboardType) -> NumberKeyboard
    static func keyboard(_ textField: UITextField, type: NumberKeyboardType, style: NumberKeyboardStyle) -> NumberKeyboard
}

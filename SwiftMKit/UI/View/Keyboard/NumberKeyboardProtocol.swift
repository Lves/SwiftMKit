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
    func matchInputDot(old : String, new : String) -> String
    func matchInputNumber(old : String, new : String) -> String
    func matchInputDel(old : String, new : String) -> String
}

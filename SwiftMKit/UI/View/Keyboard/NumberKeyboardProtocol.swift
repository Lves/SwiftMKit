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
    var numberIn: String { get set }
    var numberOut: String { get }
    
    func clear()
    //delete
    //location
    //input
}
//
//  HUDProtocol.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit

struct HUDConstant {
    static let HideTipAfterDelay: NSTimeInterval = 2
    static let LoadingText: String = "正在加载"
}

public protocol HUDProtocol : class {
    func showHUDAddedTo(view: UIView, animated: Bool, text:String?)
    func showHUDTextAddedTo(view: UIView, animated: Bool, text:String?, hideAfterDelay: NSTimeInterval)
    func showHUDTextAddedTo(view: UIView, animated: Bool, text:String?, hideAfterDelay: NSTimeInterval, completion: (() -> Void))
    func hideHUDForView(view: UIView, animated: Bool) -> Bool
}
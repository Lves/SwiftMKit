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
    func showHUDAddedTo(view: UIView, animated: Bool, text: String?, detailText: String?)
    func showHUDTextAddedTo(view: UIView, animated: Bool, text:String?, hideAfterDelay: NSTimeInterval)
    func showHUDTextAddedTo(view: UIView, animated: Bool, text:String?, hideAfterDelay: NSTimeInterval, completion: (() -> Void))
    func showHUDTextAddedTo(view: UIView, animated: Bool, text: String?, detailText: String?, hideAfterDelay: NSTimeInterval, completion: (() -> Void))
    func showHUDProgressAddedTo(view: UIView, animated: Bool, text: String?, detailText: String?, cancelEnable: Bool?, cancelTitle: String?)
    func showHUDProgressAnnularDeterminateAddedTo(view: UIView, animated: Bool, text: String?, detailText: String?, cancelEnable: Bool?, cancelTitle: String?)
    func showHUDProgressHorizontalBarAddedTo(view: UIView, animated: Bool, text: String?, detailText: String?, cancelEnable: Bool?, cancelTitle: String?)
    func changeHUDProgress(progress: Float)
    func changeHUDText(text: String?)
    func hideHUDForView(view: UIView, animated: Bool) -> Bool
    func hideIndicatorHUDForView(view: UIView, animated: Bool) -> Bool
}
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
    static let HideTipAfterDelay: TimeInterval = 2
    static let LoadingText: String = "正在加载"
}

public protocol HUDProtocol : class {
    func showHUDAddedTo(_ view: UIView, animated: Bool, text: String?)
    func showHUDTextAddedTo(_ view: UIView, animated: Bool, text: String?, detailText: String?, image: UIImage?, hideAfterDelay: TimeInterval, offset: CGPoint?, completion: (() -> Void))
    func showHUDProgressAddedTo(_ view: UIView, animated: Bool, text: String?, detailText: String?, cancelEnable: Bool?, cancelTitle: String?)
    func showHUDProgressAnnularDeterminateAddedTo(_ view: UIView, animated: Bool, text: String?, detailText: String?, cancelEnable: Bool?, cancelTitle: String?)
    func showHUDProgressHorizontalBarAddedTo(_ view: UIView, animated: Bool, text: String?, detailText: String?, cancelEnable: Bool?, cancelTitle: String?)
    func changeHUDProgress(_ progress: Float)
    func changeHUDText(_ text: String?)
    func hideHUDForView(_ view: UIView, animated: Bool) -> Bool
    func hideIndicatorHUDForView(_ view: UIView, animated: Bool) -> Bool
}

//
//  HUDProtocol.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit

public struct HudConstant {
    public static let hideTipAfterDelay: TimeInterval = 2
    public static let loadingText: String = "正在加载"
}

public enum HudType {
    case indeterminate, determinate, determinateHorizontalBar, annularDeterminate, customView, text
}

public protocol HudProtocol {
    func showIndicator(inView view: UIView, text: String?, detailText: String?, animated: Bool)
    func showTip(inView view: UIView, text: String?, detailText: String?, image: UIImage?, hideAfterDelay: TimeInterval, offset: CGPoint?, animated: Bool, completion: @escaping (() -> Void))
    func showProgress(inView view: UIView, text: String?, detailText: String?, cancelEnable: Bool?, cancelTitle: String?, type: HudType, animated: Bool)
    func change(progress: Float)
    func change(text: String?)
    @discardableResult
    func hide(forView view: UIView, animated: Bool) -> Bool
    @discardableResult
    func hide(forView view: UIView, type: HudType, animated: Bool) -> Bool
}
public struct Hud {
    static func show(tip: String) {
        UIViewController.topController?.showTip(tip)
    }
}

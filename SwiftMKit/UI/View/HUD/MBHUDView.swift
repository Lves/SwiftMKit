//
//  MBHudView.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import MBProgressHUD

public class MBHUDView: HUDProtocol{
    public func showHUDAddedTo(view: UIView, animated: Bool, text:String?) {
        MBProgressHUD.hideHUDForView(view, animated: animated)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: animated)
        if let indicateString = text {
            hud.label.text = indicateString
        }
    }
    public func showHUDTextAddedTo(view: UIView, animated: Bool, text: String?, hideAfterDelay: NSTimeInterval) {
        MBProgressHUD.hideHUDForView(view, animated: animated)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: animated)
        hud.mode = .Text
        if let indicateString = text {
            hud.label.text = indicateString
        }
        hud.hideAnimated(animated, afterDelay: hideAfterDelay)
    }
    public func hideHUDForView(view: UIView, animated: Bool) -> Bool {
        return MBProgressHUD.hideHUDForView(view, animated: animated)
    }
}
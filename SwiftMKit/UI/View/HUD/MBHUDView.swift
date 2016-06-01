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
    struct InnerConstant {
        static let TitleToDetailTextLenght: Int = 10
    }
    
    private var indicatorShowed: Bool = false
    
    public func showHUDAddedTo(view: UIView, animated: Bool, text:String?) {
        indicatorShowed = true
        MBProgressHUD.hideHUDForView(view, animated: animated)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: animated)
        if let indicateString = text {
            hud.labelText = indicateString
        }
    }
    public func showHUDTextAddedTo(view: UIView, animated: Bool, text: String?, hideAfterDelay: NSTimeInterval) {
        self.showHUDTextAddedTo(view, animated: animated, text: text, hideAfterDelay: hideAfterDelay, completion: {})
    }
    public func showHUDTextAddedTo(view: UIView, animated: Bool, text: String?, hideAfterDelay: NSTimeInterval, completion: (() -> Void)) {
        indicatorShowed = false
        MBProgressHUD.hideHUDForView(view, animated: animated)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: animated)
        hud.mode = .Text
        if let indicateString = text {
            if text?.length > InnerConstant.TitleToDetailTextLenght {
                hud.detailsLabelText = indicateString
            } else {
                hud.labelText = indicateString
            }
        }
        hud.hide(animated, afterDelay: hideAfterDelay)
        Async.main(after: hideAfterDelay, block: completion)
    }
    public func hideHUDForView(view: UIView, animated: Bool) -> Bool {
        indicatorShowed = false
        return MBProgressHUD.hideHUDForView(view, animated: animated)
    }
    public func hideIndicatorHUDForView(view: UIView, animated: Bool) -> Bool {
        if indicatorShowed {
            indicatorShowed = false
            return MBProgressHUD.hideHUDForView(view, animated: animated)
        } else {
            return false
        }
    }
}
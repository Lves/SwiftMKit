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
    public weak var showingHUD: MBProgressHUD?
    public static var shared: MBHUDView = MBHUDView()
    
    public func showHUDAddedTo(view: UIView, animated: Bool, text: String?) {
        showHUDAddedTo(view, animated: animated, text: text, detailText: nil)
    }
    public func showHUDAddedTo(view: UIView, animated: Bool, text: String?, detailText: String?) {
        indicatorShowed = true
        MBProgressHUD.hideHUDForView(view, animated: animated)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: animated)
        if let indicateString = text {
            hud.label.text = indicateString
        }
        if let detailString = detailText {
            hud.detailsLabel.text = detailString
        }
        showingHUD = hud
    }
    public func showHUDTextAddedTo(view: UIView, animated: Bool, text: String?, detailText: String?, image: UIImage?, hideAfterDelay: NSTimeInterval, offset: CGPoint?, completion: (() -> Void)) {
        indicatorShowed = false
        showingHUD?.hideAnimated(false)
        MBProgressHUD.hideHUDForView(view, animated: animated)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: animated)
        hud.mode = .Text
        if let offset = offset {
            hud.offset = offset
        }
        if let detailText = detailText {
            hud.label.text = text
            hud.detailsLabel.text = detailText
        } else {
            setHUDText(hud, text: text)
        }
        if let image = image {
            hud.mode = .CustomView;
            hud.customView = UIImageView(image: image)
            hud.square = true
        }
        hud.hideAnimated(animated, afterDelay: hideAfterDelay)
        showingHUD = hud
        Async.main(after: hideAfterDelay, block: completion)
    }
    public func showHUDProgressAddedTo(view: UIView, animated: Bool, text: String?, detailText: String?, cancelEnable: Bool? = false, cancelTitle: String? = nil) {
        showHUDProgressAddedTo(view, animated: animated, text: text, detailText: detailText, mode: .Determinate)
    }
    public func showHUDProgressAnnularDeterminateAddedTo(view: UIView, animated: Bool, text: String?, detailText: String?, cancelEnable: Bool? = false, cancelTitle: String? = nil) {
        showHUDProgressAddedTo(view, animated: animated, text: text, detailText: detailText, mode: .AnnularDeterminate)
    }
    public func showHUDProgressHorizontalBarAddedTo(view: UIView, animated: Bool, text: String?, detailText: String?, cancelEnable: Bool? = false, cancelTitle: String? = nil) {
        showHUDProgressAddedTo(view, animated: animated, text: text, detailText: detailText, mode: .DeterminateHorizontalBar)
    }
    public func showHUDProgressAddedTo(view: UIView, animated: Bool, text: String?, detailText: String?, cancelEnable: Bool? = false, cancelTitle: String? = nil, mode: MBProgressHUDMode) {
        showHUDAddedTo(view, animated: animated, text: text, detailText: detailText)
        showingHUD?.mode = mode
        if cancelEnable == true {
            let progressObject = NSProgress(totalUnitCount: 100)
            showingHUD?.progressObject = progressObject
            if let title = cancelTitle {
                showingHUD?.button.setTitle(title, forState: .Normal)
                showingHUD?.button.addTarget(progressObject, action: #selector(NSProgress.cancel), forControlEvents: .TouchUpInside)
            }
        }
    }
    public func changeHUDProgress(progress: Float) {
        if let progressObject = showingHUD?.progressObject {
            if progressObject.cancelled {
                showingHUD?.hideAnimated(true)
                showingHUD = nil
                indicatorShowed = false
                return
            }
            let increase: Int64 = Int64((Double(progress) - progressObject.fractionCompleted) * 100)
            progressObject.becomeCurrentWithPendingUnitCount(increase)
            progressObject.resignCurrent()
        } else {
            showingHUD?.progress = progress
        }
    }
    public func changeHUDText(text: String?) {
        if let hud = showingHUD {
            setHUDText(hud, text: text)
        }
    }
    public func setHUDText(hud: MBProgressHUD, text: String?) {
        if let indicateString = text {
            if text?.length > InnerConstant.TitleToDetailTextLenght {
                hud.detailsLabel.text = indicateString
            } else {
                hud.label.text = indicateString
            }
        }
    }
    public func hideHUDForView(view: UIView, animated: Bool) -> Bool {
        showingHUD = nil
        indicatorShowed = false
        return MBProgressHUD.hideHUDForView(view, animated: animated)
    }
    public func hideIndicatorHUDForView(view: UIView, animated: Bool) -> Bool {
        showingHUD = nil
        if indicatorShowed {
            indicatorShowed = false
            return MBProgressHUD.hideHUDForView(view, animated: animated)
        } else {
            return false
        }
    }
}
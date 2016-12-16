//
//  MBHudView.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import MBProgressHUD
import CocoaLumberjack

public enum MBHUDViewStyle: Int {
    case `default`, black
}

open class MBHUDView: HUDProtocol{
    struct InnerConstant {
        static let TitleToDetailTextLenght: Int = 10
    }
    
    fileprivate var indicatorShowed: Bool = false
    open weak var showingHUD: MBProgressHUD?
    open static var shared: MBHUDView = MBHUDView()
    open var style: MBHUDViewStyle = .default
    
    
    open func showHUDAddedTo(_ view: UIView, animated: Bool, text: String?) {
        showHUDAddedTo(view, animated: animated, text: text, detailText: nil)
    }
    open func showHUDAddedTo(_ view: UIView, animated: Bool, text: String?, detailText: String?) {
        DDLogInfo("show: \(view)")
        indicatorShowed = true
        MBProgressHUD.hide(for: view, animated: animated)
        let hud = MBProgressHUD.showAdded(to: view, animated: animated)
        setHUDStyle(hud, style: style)
        if let indicateString = text {
            hud.label.text = indicateString
        }
        if let detailString = detailText {
            hud.detailsLabel.text = detailString
        }
        hud.button.removeTarget(nil, action: nil, for: .allEvents)
        showingHUD = hud
    }
    open func showHUDTextAddedTo(_ view: UIView, animated: Bool, text: String?, detailText: String?, image: UIImage?, hideAfterDelay: TimeInterval, offset: CGPoint?, completion: @escaping (() -> Void)) {
        DDLogInfo("show: \(view)")
        indicatorShowed = false
        showingHUD?.hide(animated: false)
        MBProgressHUD.hide(for: view, animated: animated)
        let hud = MBProgressHUD.showAdded(to: view, animated: animated)
        setHUDStyle(hud, style: style)
        
        hud.mode = .text
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
            hud.mode = .customView;
            hud.customView = UIImageView(image: image)
            hud.isSquare = true
        }
        hud.button.removeTarget(nil, action: nil, for: .allEvents)
        hud.hide(animated: animated, afterDelay: hideAfterDelay)
        showingHUD = hud
        _ = Async.main(after: hideAfterDelay, completion)
    }
    open func showHUDProgressAddedTo(_ view: UIView, animated: Bool, text: String?, detailText: String?, cancelEnable: Bool? = false, cancelTitle: String? = nil) {
        showHUDProgressAddedTo(view, animated: animated, text: text, detailText: detailText, mode: .determinate)
    }
    open func showHUDProgressAnnularDeterminateAddedTo(_ view: UIView, animated: Bool, text: String?, detailText: String?, cancelEnable: Bool? = false, cancelTitle: String? = nil) {
        showHUDProgressAddedTo(view, animated: animated, text: text, detailText: detailText, mode: .annularDeterminate)
    }
    open func showHUDProgressHorizontalBarAddedTo(_ view: UIView, animated: Bool, text: String?, detailText: String?, cancelEnable: Bool? = false, cancelTitle: String? = nil) {
        showHUDProgressAddedTo(view, animated: animated, text: text, detailText: detailText, mode: .determinateHorizontalBar)
    }
    open func showHUDProgressAddedTo(_ view: UIView, animated: Bool, text: String?, detailText: String?, cancelEnable: Bool? = false, cancelTitle: String? = nil, mode: MBProgressHUDMode) {
        showHUDAddedTo(view, animated: animated, text: text, detailText: detailText)
        showingHUD?.mode = mode
        if cancelEnable == true {
            let progressObject = Progress(totalUnitCount: 100)
            showingHUD?.progressObject = progressObject
            if let title = cancelTitle {
                showingHUD?.button.setTitle(title, for: .normal)
                showingHUD?.button.addTarget(progressObject, action: #selector(Progress.cancel), for: .touchUpInside)
            } else {
                showingHUD?.button.removeTarget(nil, action: nil, for: .allEvents)
            }
        }
    }
    open func changeHUDProgress(_ progress: Float) {
        if let progressObject = showingHUD?.progressObject {
            if progressObject.isCancelled {
                showingHUD?.hide(animated: true)
                showingHUD = nil
                indicatorShowed = false
                return
            }
            let increase: Int64 = Int64((Double(progress) - progressObject.fractionCompleted) * 100)
            progressObject.becomeCurrent(withPendingUnitCount: increase)
            progressObject.resignCurrent()
        } else {
            showingHUD?.progress = progress
        }
    }
    open func changeHUDText(_ text: String?) {
        if let hud = showingHUD {
            setHUDText(hud, text: text)
        }
    }
    open func setHUDText(_ hud: MBProgressHUD, text: String?) {
        if let indicateString = text {
            if (text?.length ?? 0) > InnerConstant.TitleToDetailTextLenght {
                hud.detailsLabel.text = indicateString
            } else {
                hud.label.text = indicateString
            }
        }
    }
    open func setHUDStyle(_ hud: MBProgressHUD, style: MBHUDViewStyle) {
        switch style {
        case .default:
            break
        case .black:
            hud.bezelView.color = UIColor.black.withAlphaComponent(0.9)
            hud.bezelView.style = .solidColor
            hud.contentColor = UIColor.white
        }
    }
    open func hideHUDForView(_ view: UIView, animated: Bool) -> Bool {
        DDLogInfo("hide: \(view)")
        showingHUD = nil
        indicatorShowed = false
        return MBProgressHUD.hide(for: view, animated: animated)
    }
    open func hideIndicatorHUDForView(_ view: UIView, animated: Bool) -> Bool {
        DDLogInfo("hide: \(view)")
        if showingHUD?.mode == .text {
            return false
        }
        showingHUD = nil
        indicatorShowed = false
        return MBProgressHUD.hide(for: view, animated: animated)
    }
}

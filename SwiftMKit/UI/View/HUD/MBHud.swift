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

public enum MBHudViewStyle: Int {
    case `default`, black
}

open class MBHud: HudProtocol{
    struct InnerConstant {
        static let titleMaxLength: Int = 10
    }
    
    open static var shared: MBHud = MBHud()
    private var indicatorShowed: Bool = false
    private weak var showingHud: MBProgressHUD?
    private var style: MBHudViewStyle = .default
    
    public func showIndicator(inView view: UIView, text: String?, detailText: String? = nil, animated: Bool = true) {
        DDLogInfo("show: \(view)")
        indicatorShowed = true
        MBProgressHUD.hide(for: view, animated: animated)
        let hud = MBProgressHUD.showAdded(to: view, animated: animated)
        setHudStyle(hud, style: style)
        if let indicateString = text {
            hud.label.text = indicateString
        }
        if let detailString = detailText {
            hud.detailsLabel.text = detailString
        }
        hud.button.removeTarget(nil, action: nil, for: .allEvents)
        showingHud = hud
    }
    public func showTip(inView view: UIView, text: String?, detailText: String? = nil, image: UIImage? = nil, hideAfterDelay: TimeInterval = HudConstant.hideTipAfterDelay, offset: CGPoint? = nil, animated: Bool = true, completion: @escaping (() -> Void)) {
        DDLogInfo("show: \(view)")
        indicatorShowed = false
        showingHud?.hide(animated: false)
        MBProgressHUD.hide(for: view, animated: animated)
        let hud = MBProgressHUD.showAdded(to: view, animated: animated)
        setHudStyle(hud, style: style)
        
        hud.mode = .text
        if let offset = offset {
            hud.offset = offset
        }
        if let detailText = detailText {
            hud.label.text = text
            hud.detailsLabel.text = detailText
        } else {
            setHudText(hud, text: text)
        }
        if let image = image {
            hud.mode = .customView;
            hud.customView = UIImageView(image: image)
            hud.isSquare = true
        }
        hud.button.removeTarget(nil, action: nil, for: .allEvents)
        hud.hide(animated: animated, afterDelay: hideAfterDelay)
        showingHud = hud
        Async.main(after: hideAfterDelay, completion)
    }
    public func showProgress(inView view: UIView, text: String?, detailText: String? = nil, cancelEnable: Bool? = false, cancelTitle: String? = nil, type: HudType = .determinate, animated: Bool = true) {
        showIndicator(inView: view, text: text, detailText: detailText, animated: animated)
        showingHud?.mode = hudTypeTransfer(type: type)
        if cancelEnable == true {
            let progressObject = Progress(totalUnitCount: 100)
            showingHud?.progressObject = progressObject
            if let title = cancelTitle {
                showingHud?.button.setTitle(title, for: .normal)
                showingHud?.button.addTarget(progressObject, action: #selector(Progress.cancel), for: .touchUpInside)
            } else {
                showingHud?.button.removeTarget(nil, action: nil, for: .allEvents)
            }
        }
    }
    public func change(progress: Float) {
        if let progressObject = showingHud?.progressObject {
            if progressObject.isCancelled {
                showingHud?.hide(animated: true)
                showingHud = nil
                indicatorShowed = false
                return
            }
            let increase = Int64((Double(progress) - progressObject.fractionCompleted) * 100)
            progressObject.becomeCurrent(withPendingUnitCount: increase)
            progressObject.resignCurrent()
        } else {
            showingHud?.progress = progress
        }
    }
    public func change(text: String?) {
        if let hud = showingHud {
            setHudText(hud, text: text)
        }
    }
    private func setHudText(_ hud: MBProgressHUD, text: String?) {
        if let indicateString = text {
            if (text?.length ?? 0) > InnerConstant.titleMaxLength {
                hud.detailsLabel.text = indicateString
            } else {
                hud.label.text = indicateString
            }
        }
    }
    private func setHudStyle(_ hud: MBProgressHUD, style: MBHudViewStyle) {
        switch style {
        case .default:
            break
        case .black:
            hud.bezelView.color = UIColor.black.withAlphaComponent(0.9)
            hud.bezelView.style = .solidColor
            hud.contentColor = UIColor.white
        }
    }
    @discardableResult
    public func hide(forView view: UIView, animated: Bool) -> Bool {
        DDLogInfo("hide: \(view)")
        showingHud = nil
        indicatorShowed = false
        return MBProgressHUD.hide(for: view, animated: animated)
    }
    @discardableResult
    public func hide(forView view: UIView, type: HudType, animated: Bool) -> Bool {
        DDLogInfo("hide: \(view)")
        if showingHud?.mode == hudTypeTransfer(type: type) {
            return false
        }
        showingHud = nil
        indicatorShowed = false
        return MBProgressHUD.hide(for: view, animated: animated)
    }
    
    private func hudTypeTransfer(type: HudType) -> MBProgressHUDMode {
        switch type {
        case .annularDeterminate: return .annularDeterminate
        case .customView: return .customView
        case .determinate: return .determinate
        case .determinateHorizontalBar: return .determinateHorizontalBar
        case .indeterminate: return .indeterminate
        case .text: return .text
        }
    }
}

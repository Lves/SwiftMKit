//
//  GesturePasswordView.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

public protocol GesturePasswordViewDelegate : class {
    func gp_verification(success: Bool, message: String, canTryAgain: Bool)
    func gp_setPassword(success: Bool, message: String)
    func gp_confirmSetPassword(success: Bool, message: String)
}

@IBDesignable
public class GesturePasswordView: UIView, GestureTentacleDelegate {
    
    struct InnerConstant {
        static let SuccessColor = UIColor(red: 2/255, green: 174/255, blue: 240/255, alpha: 1)
        static let FailureColor = UIColor(red: 208/255, green: 36/255, blue: 36/255, alpha: 1)
        static let NormalColor = UIColor.whiteColor()
        static let ColorFillAlpha: CGFloat = 0.3
        static let ColorLineAlpha: CGFloat = 0.7
        static let ButtonBorderWidth: CGFloat = 2
        static let LineWidth: CGFloat = 5
        static let ButtonPanelMargin: CGFloat = 50
    }
    
    @IBInspectable
    public var padding: CGFloat = 20 { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var lineSuccessColor: UIColor = InnerConstant.SuccessColor {
        didSet {
            updateTentacleView()
            setNeedsDisplay()
        }
    }
    @IBInspectable
    public var lineFailureColor: UIColor = InnerConstant.FailureColor {
        didSet {
            updateTentacleView()
            setNeedsDisplay()
        }
    }
    @IBInspectable
    public var dotSuccessColor: UIColor = InnerConstant.SuccessColor { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var dotFailureColor: UIColor = InnerConstant.FailureColor { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var colorFillAlpha: CGFloat = InnerConstant.ColorFillAlpha { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var dotNormalColor: UIColor = InnerConstant.NormalColor { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var buttonBorderWidth: CGFloat = InnerConstant.ButtonBorderWidth { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var lineWidth: CGFloat = InnerConstant.LineWidth {
        didSet {
            updateTentacleView()
            setNeedsDisplay()
        }
    }
    @IBInspectable
    public var colorLineAlpha: CGFloat = InnerConstant.ColorLineAlpha {
        didSet {
            updateTentacleView()
            setNeedsDisplay()
        }
    }
    @IBInspectable
    public var buttonPanelLeading: CGFloat = InnerConstant.ButtonPanelMargin { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var buttonPanelTrailing: CGFloat = InnerConstant.ButtonPanelMargin { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var buttonPanelBottom: CGFloat = InnerConstant.ButtonPanelMargin { didSet { setNeedsDisplay() } }
    
    public var style: GestureTentacleStyle = .Verify {
        didSet {
            tentacleView?.style = style
            setNeedsDisplay()
        }
    }
    public var minGestureNumber: Int = 3
    public var maxGestureTryNumber: Int = 5
    private var gestureTriedNumber: Int = 0
    public var buttons = [GesturePasswordButton]()
    public var tentacleView: GestureTentacleView?
    private var buttonPannel: UIView = UIView()
    public weak var delegate: GesturePasswordViewDelegate?
    private var previousPassword: String = ""
    
    /// 标识是否画实心内圆
    public var innerCircleSolid = false {
        didSet {
            let _ = buttons.map {
                $0.innerCircleSolid = innerCircleSolid
                $0.layoutIfNeeded()
            }
        }
    }
    public var innerCircleSizePercent: CGFloat = 0.25 {
        didSet {
            let _ = buttons.map {
                $0.innerCircleSizePercent = innerCircleSizePercent
                $0.layoutIfNeeded()
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
    }
    
    public func setupUI() {
        self.backgroundColor = UIColor.clearColor()
        buttonPannel.frame = self.frame
        buttonPannel.backgroundColor = UIColor.clearColor()
        buttonPannel.userInteractionEnabled = false
        for index in 0..<9 {
            let button = GesturePasswordButton(frame: CGRectZero)
            button.tag = index + 1
            button.innerCircleSolid = innerCircleSolid
            button.innerCircleSizePercent = innerCircleSizePercent
            buttons.append(button)
            buttonPannel.addSubview(button)
        }
        tentacleView = GestureTentacleView(frame: buttonPannel.frame)
        tentacleView?.buttonArray = buttons
        tentacleView?.delegate = self
        tentacleView?.style = style
        self.addSubview(tentacleView!)
        self.addSubview(buttonPannel)
    }
    public override func drawRect(rect: CGRect) {
        let left = buttonPanelLeading
        let width = self.w - buttonPanelLeading - buttonPanelTrailing
        let height = width
        let top = self.h - buttonPanelBottom - height
        let length = (width - 2 * padding) / 3
        buttonPannel.frame = self.frame
        for index in 0..<buttons.count {
            let button = buttons[index]
            let row = index / 3
            let col = index % 3
            button.frame = CGRectMake(left + CGFloat(row) * (length + padding), top + CGFloat(col) * (length + padding), length, length)
            button.lineSuccessColor = lineSuccessColor
            button.lineFailureColor = lineFailureColor
            button.dotSuccessColor = dotSuccessColor
            button.dotFailureColor = dotFailureColor
            button.colorFillAlpha = colorFillAlpha
            button.dotNormalColor = dotNormalColor
            button.buttonBorderWidth = buttonBorderWidth
            button.success = true
            button.selected = false
        }
        tentacleView?.frame = buttonPannel.frame
    }
    private func updateTentacleView() {
        tentacleView?.lineWidth = lineWidth
        tentacleView?.lineFailureColor = lineFailureColor
        tentacleView?.lineSuccessColor = lineSuccessColor
        tentacleView?.lineColorAlpha = colorLineAlpha
    }
    
    // MARK: Delegate
    
    public func verification(result: String) -> Bool {
        Async.main(after: 1) { [weak self] in
            self?.tentacleView?.enterArgin()
        }
        if result.length < minGestureNumber {
            gestureTriedNumber -= 1
            delegate?.gp_verification(false, message: "至少要绘制3个点，请重试", canTryAgain: gestureTriedNumber < maxGestureTryNumber)
            return false
        }
        let success = GesturePassword.verify(result)
        var message = ""
        var canTry = true
        
        if success {
            gestureTriedNumber = 0
            message = "手势密码解锁成功"
        } else {
            gestureTriedNumber += 1
            message = "错误次数 \(gestureTriedNumber), 您还可以重试 \(maxGestureTryNumber - gestureTriedNumber) 次"
            canTry = (gestureTriedNumber < maxGestureTryNumber)
            if !canTry {
                let message = "错误次数已达上限，解锁失败"
                delegate?.gp_verification(false, message: message, canTryAgain: false)
                gestureTriedNumber = 0
                self.userInteractionEnabled = false
                return false
            }
        }
        
        delegate?.gp_verification(success, message: message, canTryAgain: canTry)
        return success
    }
    public func resetPassword(result: String) -> Bool {
        if result.length < minGestureNumber {
            delegate?.gp_setPassword(false, message: "至少要绘制3个点，请重试")
            Async.main(after: 1) { [weak self] in
                self?.tentacleView?.enterArgin()
            }
            return false
        }
        if previousPassword.length == 0 {
            previousPassword = result
            delegate?.gp_setPassword(true, message: "请确认手势密码")
            tentacleView?.enterArgin()
            return true
        } else {
            Async.main(after: 1) { [weak self] in
                self?.tentacleView?.enterArgin()
            }
            if previousPassword == result {
                previousPassword = ""
                let success = GesturePassword.change(result)
                let message = success ? "手势密码设置成功" : "设置失败，请重新设置手势密码"
                delegate?.gp_confirmSetPassword(success, message: message)
                return success
            } else {
                previousPassword = ""
                delegate?.gp_confirmSetPassword(false, message: "设置失败，请重新设置手势密码")
                return false
            }
        }
    }
    public func reset() {
        self.userInteractionEnabled = true
        tentacleView?.enterArgin()
    }
}

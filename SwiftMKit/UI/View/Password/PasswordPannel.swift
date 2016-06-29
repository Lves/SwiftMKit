//
//  PasswordPannel.swift
//  SwiftMKitDemo
//
//  Created by jimubox on 16/5/24.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import IQKeyboardManager

public protocol PasswordPannelDelegate: class {
    func pp_didCancel(pannel: PasswordPannel?) 
    func pp_forgetPassword(pannel: PasswordPannel?)
    func pp_didInputPassword(pannel: PasswordPannel?, password : String, completion: ((Bool, String, PasswordPannelStatus) -> Void))
    func pp_didFinished(pannel: PasswordPannel?, success: Bool)
}
public extension PasswordPannelDelegate {
    func pp_didCancel(pannel: PasswordPannel?) {}
    func pp_didFinished(pannel: PasswordPannel?, success: Bool) {}
}

public enum PasswordPannelStatus: Int {
    case Normal, PasswordWrong, PasswordLocked
}

public class PasswordPannel: UIView, PasswordTextViewDelegate{
    private struct InnerConstant {
        static let AnimationDuration = 0.25
        static let MaskColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
        static let Title = "输入交易密码"
    }
    public weak var delegate: PasswordPannelDelegate?
    public var animationDuration = InnerConstant.AnimationDuration
    public var maskColor = InnerConstant.MaskColor
    public var title: String? {
        get {
            return lblTitle.text
        }
        set {
            lblTitle.text = newValue
        }
    }
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgRotation: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnForget: UIButton!
    @IBOutlet weak var passwordInputView: PasswordTextView!
    public var coverView : UIControl = UIControl()
    
    public var loadingText = ""
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public static func pannel() -> PasswordPannel {
        let view = NSBundle.mainBundle().loadNibNamed("PasswordPannel", owner: self, options: nil).first as! PasswordPannel
        view.setupUI()
        return view
    }
    private func setupUI() {
        self.btnClose.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [weak self] _ in
            self?.passwordInputView.inactive()
            self?.hide() {
                self?.passwordInputView.password = ""
                self?.delegate?.pp_didCancel(self)
            }
        }
        self.btnForget.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [weak self] _ in
            self?.hide() {
                self?.delegate?.pp_forgetPassword(self)
            }
        }
        lblTitle.text = InnerConstant.Title
        imgRotation.hidden = true
        lblMessage.hidden = true
        passwordInputView.delegate = self
        passwordInputView.inputViewColor = UIColor(hex6: 0xD8E0EB)
    }
    private func showKeyboard() {
        passwordInputView.active()
    }
    private func hideKeyboard() {
        passwordInputView.inactive()
    }
    /** 弹出 */
    public func show(viewController : UIViewController) {
        var view = viewController.view
        if let nav = viewController.navigationController {
            view = nav.view
        }
        self.size.width = view.size.width
        coverView.frame = view.bounds
        coverView.backgroundColor = UIColor.clearColor()
        view.addSubview(coverView)
        view.addSubview(self)
        passwordInputView.password = ""
        showKeyboard()
        Async.main {
            self.y = self.coverView.h
            UIView.animateWithDuration(self.animationDuration) {
                self.coverView.backgroundColor = self.maskColor
                self.y = self.coverView.h - self.h;
            }
        }
    }
    /** 隐藏 */
    public func hide(completion: () -> Void = {}) {
        Async.main {
            self.hideKeyboard()
            UIView.animateWithDuration(self.animationDuration, animations: {
                self.y = self.coverView.h
                self.coverView.backgroundColor = UIColor.clearColor()
            }) { _ in
                self.removeFromSuperview()
                self.coverView.removeFromSuperview()
                completion()
            }
        }
    }
    /** 加载期间禁止按钮点击 */
    private func freezePanel(freeze: Bool) {
        btnClose.userInteractionEnabled = !freeze;
        self.btnForget.userInteractionEnabled = !freeze;
    }
    /** 开始加载 */
    private func startLoading() {
        freezePanel(true)
        imgRotation.hidden = false
        lblMessage.hidden = false
        imgRotation.image = UIImage.init(named: "password_loading_b")
        lblMessage.text = ""
        var rotationAnimation = CABasicAnimation()
        rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber.init(double: M_PI * 2.0)
        rotationAnimation.duration = 2.0;
        rotationAnimation.cumulative = true;
        rotationAnimation.repeatCount = MAXFLOAT;
        imgRotation.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
    }
    /** 加载完成 */
    public func stopLoading(success: Bool, message: String) {
        freezePanel(false)
        imgRotation.layer.removeAllAnimations()
        if success {
            // 请求成功
            self.lblMessage.text = message;
            self.imgRotation.image = UIImage.init(named: "password_success")
        } else {
            // 请求成功
            self.lblMessage.text = message;
            self.imgRotation.image = UIImage.init(named: "password_error")
        }
    }
    /** 输入六位密码完成时调用的代理方法 */
    public func pt_didInputSixNumber(textView: PasswordTextView?, password: String) {
        hideKeyboard()
        startLoading()
        lblMessage.text = loadingText
        delegate?.pp_didInputPassword(self, password: password) { [weak self] (success, message, status) in
            if status == .PasswordWrong {
                let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "重新输入", style: .Default, handler:  { [weak self] _ in
                    //还原界面
                    self?.passwordInputView.password = ""
                    self?.lblMessage.hidden = true
                    self?.imgRotation.hidden = true
                    self?.stopLoading(success, message: message)
                    self?.showKeyboard()
                    }))
                alert.addAction(UIAlertAction(title: "忘记密码", style: .Cancel) { [weak self] _ in
                    self?.delegate?.pp_forgetPassword(self)
                    })
                UIViewController.topController?.showAlert(alert, completion: nil)
                return
            } else if status == .PasswordLocked {
                let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "取消", style: .Default, handler:  { [weak self] _ in
                    self?.hide()
                    }))
                alert.addAction(UIAlertAction(title: "忘记密码", style: .Cancel) { [weak self] _ in
                    self?.delegate?.pp_forgetPassword(self)
                    })
                UIViewController.topController?.showAlert(alert, completion: nil)
                return
            }
            self?.stopLoading(success, message: message)
            Async.main(after: 1) { [weak self] in
                self?.hide() {
                    self?.delegate?.pp_didFinished(self, success: success)
                }
            }
        }
    }
}
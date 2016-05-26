//
//  PasswordPannel.swift
//  SwiftMKitDemo
//
//  Created by jimubox on 16/5/24.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

public protocol PasswordPannelDelegate: class {
    func pp_didCancel(pannel: PasswordPannel?) 
    func pp_forgetPassword(pannel: PasswordPannel?)
    func pp_didInputPassword(pannel: PasswordPannel?, password : String, completion: ((Bool, String) -> Void))
    func pp_didFinished(pannel: PasswordPannel?, success: Bool)
}
public extension PasswordPannelDelegate {
    func pp_didCancel(pannel: PasswordPannel?) {}
    func pp_didFinished(pannel: PasswordPannel?, success: Bool) {}
}

public class PasswordPannel: UIView, UITextFieldDelegate{
    private struct InnerConstant {
        static let AnimationDuration = 0.25
        static let MaskColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
    }
    public weak var delegate: PasswordPannelDelegate?
    public var animationDuration = InnerConstant.AnimationDuration
    public var maskColor = InnerConstant.MaskColor
    @IBOutlet weak var imgRotation: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnForget: UIButton!
    @IBOutlet weak var passwordInputView: UIView! {
        didSet {
            passwordInputView.addSubview(passwordTextView)
        }
    }
    @IBOutlet weak var txtPassword: UITextField! {
        didSet {
            keyboard = NumberKeyboard.keyboard(self.txtPassword, type: .NoDot)
            txtPassword.inputView = keyboard
            txtPassword.delegate = self
        }
    }
    public var passwordTextView = PasswordTextView.passwordTextView()
    public var coverView : UIControl = UIControl()
    
    public var loadingText = ""
    public var password : String = "" {
        didSet {
            passwordTextView.passwordLength = password.length
        }
    }
    private var keyboard: NumberKeyboard?
    private var originEnableAutoToolbar: Bool?
    
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
            self?.txtPassword.resignFirstResponder()
            self?.hide()
            self?.password = ""
            self?.delegate?.pp_didCancel(self)
        }
        self.btnForget.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [weak self] _ in
            self?.delegate?.pp_forgetPassword(self)
        }
        imgRotation.hidden = true
        lblMessage.text = ""
        passwordInputView.addTapGesture(target: self, action: #selector(tapGestureRecognized(_:)))
        
    }
    func tapGestureRecognized(recognizer : UITapGestureRecognizer) {
        showKeyboard()
    }
    private func showKeyboard() {
        originEnableAutoToolbar = keyboard?.enableAutoToolbar
        keyboard?.enableAutoToolbar = false
        txtPassword.becomeFirstResponder()
    }
    private func hideKeyboard() {
        keyboard?.enableAutoToolbar = originEnableAutoToolbar ?? true
        txtPassword.resignFirstResponder()
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
        password = ""
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
    public func hide() {
        Async.main {
            self.hideKeyboard()
            UIView.animateWithDuration(self.animationDuration, animations: {
                self.y = self.coverView.h
                self.coverView.backgroundColor = UIColor.clearColor()
            }) { _ in
                self.removeFromSuperview()
                self.coverView.removeFromSuperview()
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
    /** 输入删除 TextField 监听的代理方法 */
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.length == 0 {
            if password.length == 0 {
                return false
            } else {
                password = password.toNSString.substringToIndex(password.length - 1)
                return true
            }
        } else if password.length < 6 {
            password += string
            if password.length == 6 {
                hideKeyboard()
                startLoading()
                lblMessage.text = loadingText
                delegate?.pp_didInputPassword(self, password: password) { [weak self] (success, message) in
                    self?.stopLoading(success, message: message)
                    Async.main(after: 1) { [weak self] in
                        self?.hide()
                        self?.delegate?.pp_didFinished(self, success: success)
                    }
                }
            }
            return true
        } else {
            return false
        }
    }
    
}
//
//  PasswordPannel.swift
//  SwiftMKitDemo
//
//  Created by jimubox on 16/5/24.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

public class PasswordPannel: UIView, UITextFieldDelegate{
    private struct InnerConstant {
        static let PasswordViewAnimationDuration = 0.25
    }
    @IBOutlet weak var imgRotation: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnForget: UIButton!
    @IBOutlet weak var passwordInputView: UIView! {
        didSet {
            passwordInputView.addSubview(passwordText!)
        }
    }
    @IBOutlet weak var txtPassword: UITextField! {
        didSet {
            let keyboard = NumberKeyboard.keyboard(self.txtPassword, type: .NoDot)
            keyboard.enableAutoToolbar = false
            txtPassword.inputView = keyboard
            txtPassword.delegate = self
        }
    }
    public var passwordText = PasswordText.passwordText()
    public var coverView : UIControl = UIControl()
    
    public var loadingText = ""
    public var password : String = ""{
        didSet {
            passwordText.passwordLength = UInt(password.length)
        }
    }
    
    //Block
    public var forgetPasswordBlock : (() -> Void)?
    public var cancelBlock : (() -> Void)?
    public var requestSuccess : (() -> (Void))?
    public var requestFail : (() -> (Void))?
    public var finishBlock : ((password : String, completion: ((Bool, String) -> Void)) -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public static func pannel() -> PasswordPannel? {
        let view = NSBundle.mainBundle().loadNibNamed("PasswordPannel", owner: self, options: nil).first as? PasswordPannel
        view?.setUI()
        return view
    }
    private func setUI() {
        bindCancelButtonAction(btnClose)
        bindForgetButtonAction(btnForget)
        //把背景色设为透明
        self.backgroundColor = UIColor.clearColor()
        coverView.backgroundColor = UIColor.blackColor()
        coverView.alpha = 0.4
        passwordInputView.addTapGesture(target: self, action: #selector(tapGestureRecognized(_:)))
        
    }
    func tapGestureRecognized(recognizer : UITapGestureRecognizer) {
        self.txtPassword.becomeFirstResponder()
    }
    /** 键盘弹出接口 */
    public func showPasswordPannelInView(viewController : UIViewController) {
        var view = viewController.view
        if let nav = viewController.navigationController {
            view = nav.view
        }
        coverView.frame = view.bounds
        view.addSubview(coverView)
        view.addSubview(self)
        view.insertSubview(coverView, belowSubview: self)
        password = ""
        showKeyboard()
    }
    /** 隐藏键盘接口 */
    public func hidenPasswordPannel() {
        hidenKeyboard()
    }
    /** 开始加载 */
    public func startLoading() {
        self.startRotation(imgRotation)
        disEnalbeCloseButton(false)
    }
    /** 加载完成 */
    public func stopLoading() {
        self.stopRotation(imgRotation)
        disEnalbeCloseButton(true)
    }
    /** 请求完成 */
    public func requestComplete(state : Bool, message : NSString) {
        if state {
            self.requestComplete(state, message: "支付成功")
        } else {
            self.requestComplete(state, message: "支付失败")
        }
    }
    /** 开始旋转 */
    public func startRotation(view: UIView) {
        imgRotation.hidden = false
        lblMessage.hidden = false
        var rotationAnimation = CABasicAnimation()
        rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber.init(double: M_PI * 2.0)
        rotationAnimation.duration = 2.0;
        rotationAnimation.cumulative = true;
        rotationAnimation.repeatCount = MAXFLOAT;
        view.layer .addAnimation(rotationAnimation, forKey: "rotationAnimation")
    }
    /** 结束旋转 */
    public func stopRotation(view: UIView) {
        view.layer .removeAllAnimations()
    }
    /** 键盘弹出 */
    private func showKeyboard() {
        txtPassword.becomeFirstResponder()
        self.y = coverView.h
        UIView.animateWithDuration(InnerConstant.PasswordViewAnimationDuration) { 
            self.y = self.coverView.h - self.h;
        }
    }
    /** 键盘消失 */
    private func hidenKeyboard() {
        txtPassword.resignFirstResponder()
        UIView.animateWithDuration(InnerConstant.PasswordViewAnimationDuration) {
            self.transform = CGAffineTransformIdentity;
        }
    }
    public func hide() {
        self.removeFromSuperview()
    }
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.length == 0 {
            if password.length == 0 {
                return false
            } else {
                password = password.toNSString.substringToIndex(password.length - 1)
                return true
            }
        } else if password.length <= 6 {
            password += string
            if password.length == 6 {
                if let existBlock = finishBlock {
                    self.hidenKeyboard()
                    self.startLoading()
                    existBlock(password: password, completion: { (success, message) in
                        self.stopLoading()
                        self.requestComplete(success, message: message)
                        self.hide()
                    })
                    self.finishBlock = nil
                }
            }
            return true
        } else {
            return false
        }
    }
    //叉叉
    private func bindCancelButtonAction(button: UIButton) {
        button.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [unowned self] _ in
            self.txtPassword.resignFirstResponder()
            self.hidenPasswordPannel()
            self.password = ""
            self.removeFromSuperview()
            self.coverView.removeFromSuperview()
            self.passwordText.setNeedsDisplay()
        }
        if let exsistBlock = self.cancelBlock {
            exsistBlock()
        }
    }
    //忘记密码
    private func bindForgetButtonAction(button: UIButton) {
        btnForget.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [unowned self] _ in
            self.txtPassword.resignFirstResponder()
            self.hidenPasswordPannel()
            self.password = ""
            self.removeFromSuperview()
            self.coverView.removeFromSuperview()
            self.passwordText.setNeedsDisplay()
            
            //跳转到忘记密码页面
            if let exsistBlock = self.forgetPasswordBlock {
                exsistBlock()
                self.forgetPasswordBlock = nil
            }
        }
    }
    private func disEnalbeCloseButton(enable: Bool) {
        btnClose.userInteractionEnabled = enable;
        self.btnForget.userInteractionEnabled = enable;
    }
    
}
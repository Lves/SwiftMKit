//
//  PasswordPannel.swift
//  SwiftMKitDemo
//
//  Created by jimubox on 16/5/24.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import IQKeyboardManager
import ReactiveSwift
import ReactiveCocoa

///  Type
///
///  - Normal: 普通类型
///  - Fund:   Only for HongdianFund
enum PasswordPannelType: Int {
    case normal, fund
}

public protocol PasswordPannelDelegate: class {
    func pp_didCancel(_ pannel: PasswordPannel?) 
    func pp_forgetPassword(_ pannel: PasswordPannel?)
    func pp_didInputPassword(_ pannel: PasswordPannel?, password : String, completion: ((Bool, String, PasswordPannelStatus) -> Void))
    func pp_didFinished(_ pannel: PasswordPannel?, success: Bool)
}
public extension PasswordPannelDelegate {
    func pp_didCancel(_ pannel: PasswordPannel?) {}
    func pp_didFinished(_ pannel: PasswordPannel?, success: Bool) {}
}

public enum PasswordPannelStatus: Int {
    case normal, passwordWrong, passwordLocked
}

open class PasswordPannel: UIView, PasswordTextViewDelegate{
    fileprivate struct InnerConstant {
        static let AnimationDuration = 0.25
        static let MaskColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
        static let Title = "输入交易密码"
    }
    open weak var delegate: PasswordPannelDelegate?
    open var animationDuration = InnerConstant.AnimationDuration
    open var maskColor = InnerConstant.MaskColor
    open var title: String? {
        get {
            return lblTitle.text
        }
        set {
            lblTitle.text = newValue
        }
    }
    var passwordPannelType: PasswordPannelType = .normal
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgRotation: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnForget: UIButton!
    @IBOutlet weak var passwordInputView: PasswordTextView!
    open var coverView : UIControl = UIControl()
    open var eventCancel: ((PasswordPannel?) -> ()) = { _ in }
    open var eventForgetPassword: ((PasswordPannel?) -> ()) = { _ in }
    open var eventInputPassword: ((PasswordPannel?, _ password: String, _ completion: @escaping ((Bool, String, PasswordPannelStatus) -> Void)) -> ()) = { _,_,_ in }
    open var eventFinish: ((PasswordPannel?, _ success: Bool) -> ()) = { _,_ in }
    
    
    open var loadingText = ""
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    open static func pannel(_ index: Int = 0) -> PasswordPannel {
        let view = Bundle.main.loadNibNamed("PasswordPannel", owner: self, options: nil)![index] as! PasswordPannel
        view.passwordPannelType = PasswordPannelType(rawValue: index) ?? .normal
        view.setupUI()
        return view
    }
    fileprivate func setupUI() {
        self.btnClose.reactive.trigger(for: .touchUpInside).observeValues { [weak self] _ in
            self?.passwordInputView.inactive()
            self?.hide() {
                self?.passwordInputView.password = ""
                self?.delegate?.pp_didCancel(self)
                self?.eventCancel(self)
                self?.eventCancel = { _ in }
            }
        }
        self.btnForget.reactive.trigger(for: .touchUpInside).observeValues { [weak self] _ in
            self?.hide() {
                self?.delegate?.pp_forgetPassword(self)
                self?.eventForgetPassword(self)
            }
        }
        lblTitle.text = InnerConstant.Title
        imgRotation.isHidden = true
        lblMessage.isHidden = true
        passwordInputView.delegate = self
        passwordInputView.inputViewColor = UIColor(hex6: 0xD8E0EB)
        passwordInputView.passwordPannelType = passwordPannelType
        
        NotificationCenter.default.addObserver(self, selector: #selector(removePanel), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        // 作用：禁止全屏手势滑动返回
        coverView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan)))
    }
    
    func pan() {}
    
    func removePanel() {
        self.removeFromSuperview()
        self.coverView.removeFromSuperview()
    }
    
    fileprivate func showKeyboard() {
        passwordInputView.active()
    }
    open func hideKeyboard() {
        passwordInputView.inactive()
    }
    /** 弹出 */
    open func showInView(_ view : UIView) {
        self.size.width = view.size.width
        coverView.frame = view.bounds
        coverView.backgroundColor = UIColor.clear
        view.addSubview(coverView)
        view.addSubview(self)
        passwordInputView.password = ""
        showKeyboard()
        _ = Async.main {
            self.y = self.coverView.h
            UIView.animate(withDuration: self.animationDuration, animations: {
                self.coverView.backgroundColor = self.maskColor
                self.y = self.coverView.h - self.h;
            }) 
        }
    }
    /** 隐藏 */
    open func hide(_ completion: @escaping () -> Void = {}) {
        _ = Async.main {
            self.hideKeyboard()
            UIView.animate(withDuration: self.animationDuration, animations: {
                self.y = self.coverView.h
                self.coverView.backgroundColor = UIColor.clear
            }, completion: { _ in
                self.removeFromSuperview()
                self.coverView.removeFromSuperview()
                completion()
            }) 
        }
    }
    /** 加载期间禁止按钮点击 */
    fileprivate func freezePanel(_ freeze: Bool) {
        btnClose.isUserInteractionEnabled = !freeze;
        self.btnForget.isUserInteractionEnabled = !freeze;
    }
    /** 开始加载 */
    open func startLoading() {
        freezePanel(true)
        imgRotation.isHidden = false
        lblMessage.isHidden = false
        imgRotation.image = UIImage.init(named: "password_loading_b")
        lblMessage.text = ""
        var rotationAnimation = CABasicAnimation()
        rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber.init(value: .pi * 2.0 as Double)
        rotationAnimation.duration = 2.0;
        rotationAnimation.isCumulative = true;
        rotationAnimation.repeatCount = MAXFLOAT;
        imgRotation.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    /** 加载完成 */
    open func stopLoading(_ success: Bool, message: String) {
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
    open func pt_didInputSixNumber(_ textView: PasswordTextView?, password: String) {
        hideKeyboard()
        startLoading()
        lblMessage.text = loadingText
        let complete = { [weak self] (success: Bool, message: String, status: PasswordPannelStatus) in
            if status == .passwordWrong {
                let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "重新输入", style: .default, handler:  { [weak self] _ in
                    //还原界面
                    self?.passwordInputView.password = ""
                    self?.lblMessage.isHidden = true
                    self?.imgRotation.isHidden = true
                    self?.stopLoading(success, message: message)
                    self?.showKeyboard()
                    }))
                alert.addAction(UIAlertAction(title: "忘记密码", style: .cancel) { [weak self] _ in
                    self?.hide() {
                        self?.delegate?.pp_forgetPassword(self)
                        self?.eventForgetPassword(self)
                    }
                    })
                UIViewController.topController?.showAlert(alert, completion: nil)
                return
            } else if status == .passwordLocked {
                let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .default, handler:  { [weak self] _ in
                    self?.hide()
                    }))
                alert.addAction(UIAlertAction(title: "忘记密码", style: .cancel) { [weak self] _ in
                    self?.hide() {
                        self?.delegate?.pp_forgetPassword(self)
                        self?.eventForgetPassword(self)
                        self?.eventForgetPassword = { _ in }
                    }
                    })
                UIViewController.topController?.showAlert(alert, completion: nil)
                return
            }
            self?.stopLoading(success, message: message)
            _ = Async.main(after: 1) { [weak self] in
                self?.hide() {
                    self?.delegate?.pp_didFinished(self, success: success)
                    self?.eventFinish(self, success)
                }
            }
        }
        delegate?.pp_didInputPassword(self, password: password, completion: complete)
        self.eventInputPassword(self,  password, complete)
        self.eventInputPassword = { _,_,_ in }
    }
    
    open func requestComplete(_ success: Bool, message: String, status: PasswordPannelStatus) {
        self.stopLoading(success, message: message)
        _ = Async.main(after: 1) { [weak self] in
            self?.hide() {
                self?.delegate?.pp_didFinished(self, success: success)
                self?.eventFinish(self, success)
                self?.eventFinish = { _,_ in }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("PasswordPannel  deinit")
    }
}

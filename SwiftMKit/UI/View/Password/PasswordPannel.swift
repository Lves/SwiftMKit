//
//  PasswordPannel.swift
//  SwiftMKitDemo
//
//  Created by jimubox on 16/5/24.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

public class PasswordPannel: UIView{
    private struct InnerConstant {
        static let PasswordViewAnimationDuration = 0.25
    }
    @IBOutlet weak var constraint_passwordView_top: NSLayoutConstraint!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var passwordText: PasswordText!
    @IBOutlet weak var txtPassword: UITextField! {
        didSet {
            txtPassword.inputView = NumberKeyboard.keyboard(self.txtPassword, type: .NoDot)
        }
    }
    public var coverView : UIControl = UIControl()
    public var loadingText = ""
    public var password : String = "" {
        didSet {
            passwordText.passwordLength = UInt(password.length)
        }
    }
    //Block
    public var forgetPasswordBlock : (() -> Void)?
    public var cancelBlock : (() -> Void)?
    public var finishBlock : ((password : String) -> Void)?
    
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
        //把背景色设为透明
        self.backgroundColor = UIColor.clearColor()
        coverView.backgroundColor = UIColor.blackColor()
        coverView.alpha = 0.4
        coverView.frame = self.bounds
        self.passwordText.addTapGesture(target: self, action: #selector(tapGestureRecognized(_:)))
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
        view.addSubview(coverView)
        view.addSubview(self)
        view.insertSubview(coverView, belowSubview: self)
        showKeyboard()
    }
    /** 隐藏键盘接口 */
    public func hidenPasswordPannel() {
        hidenKeyboard()
    }
    /** 开始加载 */
    public func startLoading() {
        
    }
    /** 加载完成 */
    public func stopLoading() {
        
    }
    /** 请求完成 */
    public func requestComplete(state : Bool, message : NSString) {
        
    }
    /** 键盘弹出 */
    private func showKeyboard() {
        txtPassword.becomeFirstResponder()
        UIView.animateWithDuration(InnerConstant.PasswordViewAnimationDuration) { 
            self.constraint_passwordView_top.constant = self.passwordView.size.height - UIScreen.mainScreen().bounds.height;
        }
    }
    /** 键盘消失 */
    private func hidenKeyboard() {
        txtPassword.resignFirstResponder()
        UIView.animateWithDuration(InnerConstant.PasswordViewAnimationDuration) {
//            self.passwordView.transform = CGAffineTransformIdentity;
            self.constraint_passwordView_top.constant = 0
        }
    }
    
    
    
    
    
    
    
    
}
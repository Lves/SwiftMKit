//
//  IndicatorButton.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/17/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

public class IndicatorButton: UIButton {
    // MARK: - 可视化编辑属性
    /// 标识是否是向下切换title
    var upToDown: Bool = false
    /// borderColor
    var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    /// borderWidth
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    /// cornerRadius
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
//    public override var enabled: Bool {
//        didSet {
//            if oldValue != enabled {
//                if oldValue {
//                    
//                }
//            }
//        }
//    }
    
    // MARK: - 私有属性
    lazy var backView = UIView()
    lazy var lblMessage = UILabel()
    lazy var indicatorView = UIActivityIndicatorView()
    
    // MARK: - 构造方法
    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }
    
    init() {
        super.init(frame: CGRectZero)
        setup()
    }
    
    // MARK: - 公开方法
    func ib_loadingWithTitle(title: String) {
        // TODO: 如果title和旧title相同  不需要显示动画滚动
        // TODO: lblMessage 和 indicatorView 的位置
        enabled = false
        lblMessage.text = title
        lblMessage.sizeToFit()
        lblMessage.center = CGPointMake(self.w * 0.5, self.h * 0.5)
        
        indicatorView.centerY = lblMessage.centerY
        indicatorView.left = lblMessage.left - 20 - indicatorView.w
        indicatorView.startAnimating()
        // TODO: 滚动方向
        backView.transform = CGAffineTransformMakeTranslation(0, self.h)
        UIView.animateWithDuration(0.5) {
            self.titleLabel!.alpha = 0
            self.backView.alpha = 1
            self.backView.transform = CGAffineTransformIdentity
        }
    }
    
    func ib_resetToNormalState() {
        enabled = true
        UIView.animateWithDuration(0.5, animations: {
            self.titleLabel!.alpha = 1
            self.backView.alpha = 0
            // TODO: 滚动方向
            self.backView.transform = CGAffineTransformMakeTranslation(0, self.h)
        }) { (finished) in
            self.backView.transform = CGAffineTransformIdentity
            self.indicatorView.stopAnimating()
        }
    }
    
    // MARK: - 私有方法
    private func setup() {
        // 初始化按钮
        titleLabel?.font = UIFont.systemFontOfSize(14)
        backgroundColor = UIColor.blueColor()
        layer.masksToBounds = true
        // 初始化backView及其子视图
        lblMessage.textColor = titleLabel?.textColor
        lblMessage.font = titleLabel?.font
        backView.addSubview(lblMessage)
        
        indicatorView.activityIndicatorViewStyle = .White
        indicatorView.hidesWhenStopped = true
        backView.addSubview(indicatorView)
        
        backView.frame = CGRectMake(0, 0, self.w, self.h)
        backView.backgroundColor = UIColor.clearColor()
        backView.alpha = 0
        
        addSubview(backView)
    }
}

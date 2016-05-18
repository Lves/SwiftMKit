//
//  IndicatorButton.swift
//  SwiftMKitDemo
//
//  Created by apple on 5/17/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

/**
 *
 * ━━━━━━神兽出没━━━━━━
 * 　　　┏┓　　　┏┓
 * 　　┏┛┻━━━┛┻┓
 * 　　┃　　　　　　　┃
 * 　　┃　　　━　　　┃
 * 　　┃　┳┛　┗┳　┃
 * 　　┃　　　　　　　┃
 * 　　┃　　　┻　　　┃
 * 　　┃　　　　　　　┃
 * 　　┗━┓　　　┏━┛Code is far away from bug with the animal protecting
 * 　　　　┃　　　┃    神兽保佑,代码无bug
 * 　　　　┃　　　┃
 * 　　　　┃　　　┗━━━┓
 * 　　　　┃　　　　　　　┣┓
 * 　　　　┃　　　　　　　┏┛
 * 　　　　┗┓┓┏━┳┓┏┛
 * 　　　　　┃┫┫　┃┫┫
 * 　　　　　┗┻┛　┗┻┛
 *
 * ━━━━━━感觉萌萌哒━━━━━━
 */


public class IndicatorButton: UIButton {
    // MARK: - 公开属性
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
    
    public override var enabled: Bool {
        didSet {
            if oldValue != enabled {
                if oldValue {
                    // 动画切换title，显示菊花
                    lastDisabledTitle = titleForState(.Disabled)
                    ib_loadingWithTitle(lastDisabledTitle)
                    setTitle("", forState: .Disabled)
                } else {
                    // 重置按钮，隐藏菊花
                    ib_resetToNormalState()
                    setTitle(lastDisabledTitle, forState: .Disabled)
                }
            }
        }
    }
    
    // MARK: - 私有属性
    lazy var backView = UIView()
    lazy var lblMessage = UILabel()
    lazy var indicatorView = UIActivityIndicatorView()
    private var lastTitle: String?
    private var lastDisabledTitle: String?
    private let margin: CGFloat = 8
    private var transformY: CGFloat {
        get {
            return self.h * (upToDown ? (-1) : 1)
        }
    }
    
    // MARK: - 构造方法
    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }
    
    init() {
        super.init(frame: CGRectZero)
        setup()
    }
    
    // MARK: - 私有方法
    private func setup() {
        layer.masksToBounds = true
        // 初始化backView及其子视图
        lblMessage.textColor = titleLabel?.textColor
        lblMessage.font = titleLabel?.font
        backView.addSubview(lblMessage)
        
        indicatorView.activityIndicatorViewStyle = .White
        indicatorView.hidesWhenStopped = true
        indicatorView.sizeToFit()
        backView.addSubview(indicatorView)
        
        // 要先设置高度  再设置center
        backView.h = self.h
        backView.center = CGPointMake(self.w * 0.5, self.h * 0.5)
        backView.backgroundColor = UIColor.clearColor()
        backView.alpha = 0
        
        addSubview(backView)
        
        lastTitle = currentTitle
    }
    
    private func ib_loadingWithTitle(title: String?) {
        let color = self.titleColorForState(.Disabled)
        let shadowColor = self.titleShadowColorForState(.Disabled)
        lblMessage.text = title
        lblMessage.textColor = color
        lblMessage.shadowColor = shadowColor
        lblMessage.sizeToFit()
        // 计算lblMessage 和 indicatorView 的位置
        indicatorView.centerY = backView.centerY
        lblMessage.centerY = indicatorView.centerY
        lblMessage.left = indicatorView.right + margin
        backView.right = lblMessage.right
        backView.w = indicatorView.w + margin + lblMessage.w
        backView.left = (self.w - backView.w ) * 0.5
        
        indicatorView.startAnimating()
        if title == lastTitle {
            // 如果title和旧title相同  不需要显示动画滚动
        } else {
            backView.transform = CGAffineTransformMakeTranslation(0, transformY)
        }
        UIView.animateWithDuration(0.5) {
            self.titleLabel!.alpha = 0
            self.backView.alpha = 1
            self.backView.transform = CGAffineTransformIdentity
        }
    }
    
    private func ib_resetToNormalState() {
        UIView.animateWithDuration(0.5, animations: {
            self.titleLabel!.alpha = 1
            self.backView.alpha = 0
            if self.currentTitle == self.lastDisabledTitle {
                // 如果title和旧title相同  不需要显示动画滚动
            } else {
                self.backView.transform = CGAffineTransformMakeTranslation(0, self.transformY)
            }
        }) { (finished) in
            self.backView.transform = CGAffineTransformIdentity
            self.indicatorView.stopAnimating()
        }
    }
}

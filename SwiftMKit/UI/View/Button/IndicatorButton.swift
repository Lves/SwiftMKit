//
//  IndicatorButton.swift
//  SwiftMKitDemo
//
//  Created by apple on 5/17/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

open class IndicatorButton: UIButton {
    
    public enum AnimateDirection: Int {
        case fromDownToUp, fromUpToDown
    }
    public enum IndicatorPosition: Int {
        case left, right
    }
    
    // MARK: - 公开属性
    /// 标识是否是向下切换title
    var animateDirection: AnimateDirection = .fromDownToUp
    var indicatorStyle: UIActivityIndicatorViewStyle = .white {
        didSet {
            indicatorView.activityIndicatorViewStyle = indicatorStyle
        }
    }
    var indicatorPosition: IndicatorPosition = .left
    var indicatorMargin: CGFloat = 8
    
    open override var isEnabled: Bool {
        willSet {
            if newValue != isEnabled {
                Async.main {
                    if let title = self.title(for: .disabled) {
                        if title.length > 0 {
                            self.disabledTitle = title
                            self.setTitle("", for: .disabled)
                        }
                    }
                }
            }
        }
        didSet {
            if oldValue != isEnabled {
                Async.main {
                    if oldValue {
                        // 动画切换title，显示菊花
                        self.ib_loadingWithTitle(self.disabledTitle)
                    } else {
                        // 重置按钮，隐藏菊花
                        self.ib_resetToNormalState()
                    }
                }
            }
        }
    }
    
    // MARK: - 私有属性
    lazy var backView = UIView()
    lazy var lblMessage = UILabel()
    lazy var indicatorView = UIActivityIndicatorView()
    fileprivate var lastTitle: String?
    fileprivate var disabledTitle: String?
    fileprivate var fastEnabled: Bool = false
    fileprivate var transformY: CGFloat {
        get {
            return self.h * (animateDirection == .FromDownToUp ? 1 : -1)
        }
    }
    
    // MARK: - 构造方法
    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    // MARK: - 私有方法
    fileprivate func setup() {
        layer.masksToBounds = true
        // 初始化backView及其子视图
        lblMessage.textColor = titleLabel?.textColor
        lblMessage.font = titleLabel?.font
        lblMessage.textAlignment = .center
        backView.addSubview(lblMessage)
        
        indicatorView.activityIndicatorViewStyle = indicatorStyle
        indicatorView.hidesWhenStopped = true
        indicatorView.sizeToFit()
        backView.addSubview(indicatorView)
        
        // 要先设置高度  再设置center
        backView.h = self.h
        backView.center = CGPoint(x: self.w * 0.5, y: self.h * 0.5)
        backView.backgroundColor = UIColor.clear
        backView.alpha = 0
        
        addSubview(backView)
        
        lastTitle = currentTitle
        disabledTitle = title(for: .disabled)
        self.setTitle("", for: .disabled)
    }
    
    fileprivate func ib_loadingWithTitle(_ title: String?) {
        let color = titleColor(for: .disabled)
        let shadowColor = titleShadowColor(for: .disabled)
        lblMessage.text = title
        lblMessage.textColor = color
        lblMessage.shadowColor = shadowColor
        lblMessage.sizeToFit()
        // 计算lblMessage 和 indicatorView 的位置
        indicatorView.centerY = backView.centerY
        lblMessage.centerY = indicatorView.centerY
        switch indicatorPosition {
        case .left:
            lblMessage.left = indicatorView.right + indicatorMargin
            backView.right = lblMessage.right
        case .right:
            indicatorView.left = lblMessage.right + indicatorMargin
            backView.right = indicatorView.right
        }
        backView.w = indicatorView.w + indicatorMargin + lblMessage.w
        backView.left = (self.w - backView.w) * 0.5
        if backView.left < 0 { // 文字太长
            backView.w = lblMessage.w
            lblMessage.left = 0
            if backView.w > self.w {
                lblMessage.w = self.w
                lblMessage.adjustsFontSizeToFitWidth = true
                backView.w = lblMessage.w
            }
            backView.left = (self.w - backView.w) * 0.5
        } else {
            indicatorView.startAnimating()
        }
        
        if title == lastTitle {
            // 如果title和旧title相同  不需要显示动画滚动
        } else {
            backView.transform = CGAffineTransform(translationX: 0, y: transformY)
        }
        fastEnabled = false
        Async.main(after: 0.1) {
            if self.fastEnabled {
                return
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.titleLabel!.alpha = 0
                self.backView.alpha = 1
                self.backView.transform = CGAffineTransform.identity
            }) 
        }
    }
    
    fileprivate func ib_resetToNormalState() {
        fastEnabled = true
        UIView.animate(withDuration: 0.2, animations: {
            self.titleLabel!.alpha = 1
            self.backView.alpha = 0
            if self.currentTitle == self.disabledTitle {
                // 如果title和旧title相同  不需要显示动画滚动
            } else {
                self.backView.transform = CGAffineTransform(translationX: 0, y: self.transformY)
            }
        }, completion: { (finished) in
            if self.isEnabled {
                self.backView.transform = CGAffineTransform.identity
                self.indicatorView.stopAnimating()
            }
        }) 
    }
}

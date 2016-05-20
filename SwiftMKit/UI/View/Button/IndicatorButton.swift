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
    
    public enum AnimateDirection: Int {
        case FromDownToUp, FromUpToDown
    }
    public enum IndicatorPosition: Int {
        case Left, Right
    }
    
    // MARK: - 公开属性
    /// 标识是否是向下切换title
    var animateDirection: AnimateDirection = .FromDownToUp
    var indicatorStyle: UIActivityIndicatorViewStyle = .White {
        didSet {
            indicatorView.activityIndicatorViewStyle = indicatorStyle
        }
    }
    var indicatorPosition: IndicatorPosition = .Left
    var indicatorMargin: CGFloat = 8
    
    public override var enabled: Bool {
        willSet {
            if newValue != enabled {
                Async.main {
                    if let title = self.titleForState(.Disabled) {
                        if title.length > 0 {
                            self.disabledTitle = title
                            self.setTitle("", forState: .Disabled)
                        }
                    }
                }
            }
        }
        didSet {
            if oldValue != enabled {
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
    private var lastTitle: String?
    private var disabledTitle: String?
    private var transformY: CGFloat {
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
        super.init(frame: CGRectZero)
        setup()
    }
    
    // MARK: - 私有方法
    private func setup() {
        layer.masksToBounds = true
        // 初始化backView及其子视图
        lblMessage.textColor = titleLabel?.textColor
        lblMessage.font = titleLabel?.font
        lblMessage.textAlignment = .Center
        backView.addSubview(lblMessage)
        
        indicatorView.activityIndicatorViewStyle = indicatorStyle
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
        disabledTitle = titleForState(.Disabled)
        self.setTitle("", forState: .Disabled)
    }
    
    private func ib_loadingWithTitle(title: String?) {
        let color = titleColorForState(.Disabled)
        let shadowColor = titleShadowColorForState(.Disabled)
        lblMessage.text = title
        lblMessage.textColor = color
        lblMessage.shadowColor = shadowColor
        lblMessage.sizeToFit()
        // 计算lblMessage 和 indicatorView 的位置
        indicatorView.centerY = backView.centerY
        lblMessage.centerY = indicatorView.centerY
        switch indicatorPosition {
        case .Left:
            lblMessage.left = indicatorView.right + indicatorMargin
            backView.right = lblMessage.right
        case .Right:
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
            if self.currentTitle == self.disabledTitle {
                // 如果title和旧title相同  不需要显示动画滚动
            } else {
                self.backView.transform = CGAffineTransformMakeTranslation(0, self.transformY)
            }
        }) { (finished) in
            if self.enabled {
                self.backView.transform = CGAffineTransformIdentity
                self.indicatorView.stopAnimating()
            }
        }
    }
}

//
//  WebViewToolsPannel.swift
//  Merak
//
//  Created by HeLi on 16/7/4.
//  Copyright © 2016年 jimubox. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import CocoaLumberjack

protocol WebViewToolsPannelViewDelegate: class {
    func webViewToolsPannelViewButtonAction(webViewToolsPannelView: WebViewToolsPannelView, title: String)
}

@IBDesignable
class WebViewToolsPannelView: UIView ,UIScrollViewDelegate {
    
    struct InnerConstant {

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI(){
        
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
    }
}

protocol ToolsPannelScrollViewDelegate: class {
    func toolsPannelScrollViewButtonAction(toolsPannelScrollView: ToolsPannelScrollView, title: String)
}

@IBDesignable
class ToolsPannelScrollView: UIScrollView {
    
    struct InnerConstant {
        static let HXOriginX = 15.0 //ico起点X坐标
        static let HXOriginY = 15.0 //ico起点Y坐标
        static let HXIcoWidth = 57.0 //正方形图标宽度
        static let HXIcoAndTitleSpace = 10.0 //图标和标题间的间隔
        static let HXTitleSize = 10.0 //标签字体大小
        static let HXTitleColor = UIColor(r: 52, g: 52, b: 50, a: 1) //标签字体颜色
        static let HXLastlySpace = 15.0 //尾部间隔
        static let HXHorizontalSpace = 15.0 //横向间距
    }
    
    var originX: Float = 5 { didSet { setNeedsDisplay() } } // ico起点X坐标
    var originY: Float = 5 { didSet { setNeedsDisplay() } } // ico起点Y坐标
    var icoWidth: Float = 5 { didSet { setNeedsDisplay() } } // 正方形图标宽度
    var icoAndTitleSpace: Float = 5 { didSet { setNeedsDisplay() } } // 图标和标题间的间隔
    var titleSize: Float = 5 { didSet { setNeedsDisplay() } } // 标签字体大小
    var lastlySpace: Float = 5 { didSet { setNeedsDisplay() } } // 尾部间隔
    var horizontalSpace: Float = 5 { didSet { setNeedsDisplay() } } // 横向间距
    var titleColor: UIColor? { didSet { setNeedsDisplay() } } // 标签字体颜色
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor.clearColor()
        self.showsHorizontalScrollIndicator = true
        self.showsVerticalScrollIndicator = true

    }
    
    override func drawRect(rect: CGRect) {
        
    }
}
//
//  WebViewToolsPannel.swift
//  Merak
//
//  Created by HeLi on 16/7/4.
//  Copyright © 2016年 jimubox. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack
import ReactiveCocoa

protocol SharePannelViewDelegate: class {
    func sharePannelViewButtonAction(_ SharePannelView: SharePannelView, model: ToolsModel)
}

public protocol ToolsPannelScrollViewDelegate: class {
    func toolsPannelScrollViewButtonAction(_ toolsPannelScrollView: ToolsPannelScrollView, model: ToolsModel)
}

public enum ToolUsed : Int {
    case `default`
    case shareToSina
    case shareToQQ
    case shareToQZone
    case shareToWeChat
    case shareToTimeLine
    case shareToZhifubao
    case shareToSms
    case shareToEmail
    case collection
    case copyLink
    case openBySafari
    case setTextFont
    case webRefresh
}

// MARK: - 模型：ToolsModel
open class ToolsModel{
    
    var image: String?
    var highlightedImage: String?
    var title: String?
    var used : ToolUsed = .default
    
    init(image:String? = "", highlightedImage:String? = "", title:String? = "", used:ToolUsed) {
        self.image = image
        self.highlightedImage = highlightedImage
        self.title = title
        self.used = used
    }
}

// MARK: -
open class SharePannelView: UIView ,ToolsPannelScrollViewDelegate{
    
    struct InnerConstant {
        static let BackgroundViewAlpha : CGFloat = 0.6
        static let BackgroundViewColor : UIColor = UIColor(r: 0, g: 0, b: 0, a: BackgroundViewAlpha)
        static let PannelViewColor : UIColor = UIColor(r: 240, g: 240, b: 240, a: 0.95)
        static let BoderViewColor : UIColor = UIColor.clear
        
        static let CancelBtnH : CGFloat = 45
        static let CancelBtnTitleFont : UIFont = UIFont.systemFont(ofSize: 16)
        static let CancelBtnTitleColor : UIColor = UIColor(r: 0, g: 0, b: 0, a: 1)
        static let CancelBtnBGColor : UIColor = UIColor(r: 248, g: 248, b: 248, a: 1)
        
        static let LineViewColor : UIColor = UIColor(r: 0, g: 0, b: 0, a: 1)
        static let TimeInterval : Double = 0.25
    }
    
    weak var delegate : SharePannelViewDelegate?
    
    var toolsArray : [[ToolsModel]]? {
        didSet{
            
            if let array = toolsArray {
                var array1 = [ToolsModel]()
                var array2 = [ToolsModel]()
                if array.count > 2 {
                    return
                } else if array.count == 2 {
                    array1 = toolsArray?.first ?? []
                    array2 = toolsArray?.last ?? []
                } else {
                    array1 = toolsArray?.first ?? []
                }
                //第一行
                let toolsPannelScrollView1 : ToolsPannelScrollView = ToolsPannelScrollView(frame: CGRect(x: 0, y: 0, width: self.w, height: CGFloat(ToolsPannelScrollView.getToolsScrollViewHeight())))
                toolsPannelScrollView1.toolsArray = array1
                toolsPannelScrollView1.toolsDelegate = self
                boderView.addSubview(toolsPannelScrollView1)
                boderView.frame = CGRect(x: 0, y: 0, width: self.w, height: toolsPannelScrollView1.h)
                
                //第二行
                if array2.count > 0 {
                    lineView.frame = CGRect(x: 0, y: toolsPannelScrollView1.h, width: self.w, height: 0.5)
                    
                    let toolsPannelScrollView2 : ToolsPannelScrollView = ToolsPannelScrollView(frame: CGRect(x: 0, y: toolsPannelScrollView1.h+1, width: self.w, height: CGFloat(ToolsPannelScrollView.getToolsScrollViewHeight())))
                    toolsPannelScrollView2.toolsArray = array2
                    toolsPannelScrollView2.toolsDelegate = self
                    boderView.addSubview(toolsPannelScrollView2)
                    boderView.frame = CGRect(x: 0, y: 0, width: self.w, height: toolsPannelScrollView1.h + toolsPannelScrollView2.h + 1)
                }
            }
        }
    }
    
    dynamic var backgroundView : UIView = UIView() //背影
    dynamic var pannelView : UIView = UIView() //面板整体
    dynamic var boderView : UIView = UIView() //图标界面
    dynamic var btnCancel : UIButton = UIButton(type:.custom) //取消按钮
    dynamic var lineView : UIView = UIView() //分割线
    
    dynamic var headerView : UIView? {
        didSet{
            if let tempHeaderView = headerView {
                tempHeaderView.removeFromSuperview()
                self.pannelView.addSubview(tempHeaderView)
            }
        }
    }
    dynamic var footerView : UIView? {
        didSet{
            if let tempFooterView = footerView {
                tempFooterView.removeFromSuperview()
                self.pannelView.addSubview(tempFooterView)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI(frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI(frame)
    }
    
    dynamic func setupUI(_ frame : CGRect){
        
        self.backgroundColor = UIColor.clear
        
        backgroundView.frame = frame
        backgroundView.backgroundColor = InnerConstant.BackgroundViewColor
        backgroundView.isUserInteractionEnabled = true
        let tap  = UITapGestureRecognizer(target: self, action: #selector(tapBackgroundView(_:)))
        backgroundView.addGestureRecognizer(tap)
        self.addSubview(backgroundView)
        
        pannelView.frame = CGRect(x: 0, y: self.h, width: self.w, height: 0)
        pannelView.backgroundColor = InnerConstant.PannelViewColor
        pannelView.isUserInteractionEnabled = true
        self.addSubview(pannelView)
        
        boderView.frame = pannelView.frame
        boderView.backgroundColor = InnerConstant.BoderViewColor
        boderView.isUserInteractionEnabled = true
        self.pannelView.addSubview(boderView)
        
        lineView.frame = CGRect.zero
        lineView.backgroundColor = InnerConstant.LineViewColor
        boderView.addSubview(lineView)
        
        btnCancel.frame = CGRect(x: 0, y: 0, width: self.w, height: InnerConstant.CancelBtnH)
        btnCancel.titleLabel?.font = InnerConstant.CancelBtnTitleFont
        btnCancel.setTitle("取消", for: UIControlState())
        btnCancel.setTitleColor(InnerConstant.CancelBtnTitleColor, for: UIControlState())
        btnCancel.backgroundColor = InnerConstant.CancelBtnBGColor
        self.pannelView.addSubview(btnCancel)
        
        btnCancel.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext{ [weak self] _ in
            self?.tappedCancel()
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override open func draw(_ rect: CGRect) {
        // Drawing code
        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        var height : CGFloat = 0
        
        //HeaderView
        if let headerView_t = headerView {
            headerView_t.frame = CGRect(x: 0, y: 0, width: headerView_t.w, height: headerView_t.h)
            height += headerView_t.h
        }
        
        //BoderView
        boderView.frame = CGRect(x: 0, y: height, width: boderView.w, height: boderView.h)
        height += boderView.h
        
        //FooterView
        if let footerView_t = footerView {
            footerView_t.frame = CGRect(x: 0, y: height, width: footerView_t.w, height: footerView_t.h)
            height += footerView_t.h
        }
        
        //取消按钮
        btnCancel.frame = CGRect(x: 0, y: height, width: btnCancel.w, height: btnCancel.h)
        height += btnCancel.h
        
        //面板
        pannelView.frame = CGRect(x: 0, y: self.h, width: pannelView.w, height: height)
        
        UIView.animate(withDuration: InnerConstant.TimeInterval, animations: {
            self.pannelView.frame = CGRect(x: 0, y: self.h - height, width: self.pannelView.w, height: height)
            self.backgroundView.alpha = InnerConstant.BackgroundViewAlpha
        })
    }
    
    //MARK: Action
    dynamic func tapBackgroundView(_ gusture:UITapGestureRecognizer){
        self.tappedCancel()
    }
    
    dynamic func tappedCancel(){
        UIView.animate(withDuration: InnerConstant.TimeInterval, animations: { _ in
            
            self.backgroundView.alpha = 0
            self.pannelView.frame = CGRect(x: 0, y: self.h, width: self.pannelView.w, height: self.pannelView.h)
            
        }, completion:{ (finished:Bool) -> Void in
            self.removeFromSuperview()
        })
    }
    
    //MARK: Delegate
    open func toolsPannelScrollViewButtonAction(_ toolsPannelScrollView: ToolsPannelScrollView, model: ToolsModel) {
        
        self.tappedCancel()
        
        if delegate != nil {
            delegate?.sharePannelViewButtonAction(self, model: model)
        }
    }
}


open class ToolsPannelScrollView: UIScrollView {
    
    struct InnerConstant {
        static let OriginX : CGFloat = 15.0 //ico起点X坐标
        static let OriginY : CGFloat = 15.0 //ico起点Y坐标
        static let IcoWidth : CGFloat = 57.0 //正方形图标宽度
        static let IcoAndTitleSpace : CGFloat = 5.0 //图标和标题间的间隔
        static let TitleSize : CGFloat = 10.0 //标签字体大小
        static let TitleColor = UIColor(r: 52, g: 52, b: 50, a: 1) //标签字体颜色
        static let TitleLabelHeight : CGFloat = 25.0 //标签字体高度
        static let LastlySpace : CGFloat = 10.0 //尾部间隔
        static let HorizontalSpace : CGFloat = 15.0 //横向间距
    }
    
    fileprivate weak var toolsDelegate : ToolsPannelScrollViewDelegate?
    
    var toolsArray : [ToolsModel]? {
        didSet{
            if let toolsArray_t = toolsArray {
                
                //先移除之前的View
                if (self.subviews.count > 0) {
                    self.removeSubviews()
                }
                
                //设置当前scrollView的contentSize
                self.contentSize = CGSize(width: InnerConstant.OriginX + CGFloat(toolsArray_t.count) * (InnerConstant.IcoWidth + InnerConstant.HorizontalSpace),height: self.h)
                
                //遍历标签数组,将标签显示在界面上,并给每个标签打上tag加以区分
                for index in 0..<toolsArray_t.count {
                    let model = toolsArray_t[safe: index]
                    if let toolModel = model {
                        let itemView = self.getToolItme(CGRect(x: InnerConstant.OriginX + CGFloat(index) * (InnerConstant.IcoWidth + InnerConstant.HorizontalSpace),
                            y: InnerConstant.OriginY,
                            width: InnerConstant.IcoWidth,
                            height: InnerConstant.IcoWidth + InnerConstant.IcoAndTitleSpace + InnerConstant.TitleLabelHeight), model: toolModel, btnTag: index + 1)
                        self.addSubview(itemView)
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    dynamic func setupUI() {
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    dynamic static func getToolsScrollViewHeight() -> Float {
        let height : CGFloat = InnerConstant.OriginY + InnerConstant.IcoWidth + InnerConstant.IcoAndTitleSpace + InnerConstant.TitleLabelHeight + InnerConstant.LastlySpace
        return Float(height)
    }
    
    fileprivate func getToolItme(_ frame : CGRect , model : ToolsModel ,btnTag :Int) -> UIView {
        let toolItme = UIView(frame: frame)
        toolItme.backgroundColor = UIColor.clear
        
        let btn : UIButton = UIButton(type: .custom)
        btn.tag = btnTag
        btn.frame = CGRect(x: (toolItme.w - InnerConstant.IcoWidth)/2, y: 0, width: InnerConstant.IcoWidth, height: InnerConstant.IcoWidth)
        btn.backgroundColor = UIColor.clear
        
        if let imageStr = model.image {
            if let image = UIImage(named: imageStr) {
                btn.setImage(image, for: UIControlState())
            }
        }
        
        if let imageStr = model.highlightedImage {
            if let image = UIImage(named: imageStr) {
                btn.setImage(image, for: .highlighted)
            }
        }
        toolItme.addSubview(btn)
        
        btn.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext{ _ in
            
            if let model = self.toolsArray?[btn.tag - 1] {
                if self.toolsDelegate != nil {
                    self.toolsDelegate?.toolsPannelScrollViewButtonAction(self, model: model)
                }
            }
        }
        
        let label : UILabel = UILabel(frame: CGRect(x: -5, y: btn.h + InnerConstant.IcoAndTitleSpace , width: toolItme.w+10, height: InnerConstant.TitleLabelHeight))
        label.font = UIFont.systemFont(ofSize: InnerConstant.TitleSize)
        label.text = model.title ?? ""
        label.textColor = InnerConstant.TitleColor
        label.textAlignment = NSTextAlignment.center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.sizeToFit()
        toolItme.addSubview(label)
        
        label.frame = CGRect(x: -5, y: btn.h + InnerConstant.IcoAndTitleSpace , width: toolItme.w+10, height: label.h)
        
        return toolItme
    }
}

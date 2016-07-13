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
    func sharePannelViewButtonAction(SharePannelView: SharePannelView, model: ToolsModel)
}

private protocol ToolsPannelScrollViewDelegate: class {
    func toolsPannelScrollViewButtonAction(toolsPannelScrollView: ToolsPannelScrollView, model: ToolsModel)
}

enum ToolUsed : Int {
    case Default
    case ShareToSina
    case ShareToQQ
    case ShareToQZone
    case ShareToWeixin
    case ShareToTimeLine
    case ShareToZhifubao
    case ShareToMms
    case ShareToEmail
    case Collection
    case CopyLink
    case OpenBySafari
    case SetTextFont
    case WebRefresh
}

// MARK: - 模型：ToolsModel
public class ToolsModel{
    
    var image: String?
    var highlightedImage: String?
    var title: String?
    var used : ToolUsed = .Default
    
    init(image:String? = "", highlightedImage:String? = "", title:String? = "", used:ToolUsed) {
        self.image = image
        self.highlightedImage = highlightedImage
        self.title = title
        self.used = used
    }
}

// MARK: -
public class SharePannelView: UIView ,ToolsPannelScrollViewDelegate{
    
    struct InnerConstant {
        static let BackgroundViewAlpha : CGFloat = 0.6
        static let BackgroundViewColor : UIColor = UIColor(r: 0, g: 0, b: 0, a: BackgroundViewAlpha)
        static let PannelViewColor : UIColor = UIColor(r: 240, g: 240, b: 240, a: 0.95)
        static let BoderViewColor : UIColor = UIColor.clearColor()
        
        static let CancelBtnH : CGFloat = 45
        static let CancelBtnTitleFont : UIFont = UIFont.systemFontOfSize(16)
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
                let toolsPannelScrollView1 : ToolsPannelScrollView = ToolsPannelScrollView(frame: CGRectMake(0, 0, self.w, CGFloat(ToolsPannelScrollView.getToolsScrollViewHeight())))
                toolsPannelScrollView1.toolsArray = array1
                toolsPannelScrollView1.toolsDelegate = self
                boderView.addSubview(toolsPannelScrollView1)
                boderView.frame = CGRectMake(0, 0, self.w, toolsPannelScrollView1.h)
                
                //第二行
                if array2.count > 0 {
                    lineView.frame = CGRectMake(0, toolsPannelScrollView1.h, self.w, 0.5)
                    
                    let toolsPannelScrollView2 : ToolsPannelScrollView = ToolsPannelScrollView(frame: CGRectMake(0, toolsPannelScrollView1.h+1, self.w, CGFloat(ToolsPannelScrollView.getToolsScrollViewHeight())))
                    toolsPannelScrollView2.toolsArray = array2
                    toolsPannelScrollView2.toolsDelegate = self
                    boderView.addSubview(toolsPannelScrollView2)
                    boderView.frame = CGRectMake(0, 0, self.w, toolsPannelScrollView1.h + toolsPannelScrollView2.h + 1)
                }
            }
        }
    }
    
    dynamic var backgroundView : UIView = UIView() //背影
    dynamic var pannelView : UIView = UIView() //面板整体
    dynamic var boderView : UIView = UIView() //图标界面
    dynamic var btnCancel : UIButton = UIButton(type:.Custom) //取消按钮
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI(frame)
    }
    
    dynamic func setupUI(frame : CGRect){
        
        self.backgroundColor = UIColor.clearColor()
        
        backgroundView.frame = frame
        backgroundView.backgroundColor = InnerConstant.BackgroundViewColor
        backgroundView.userInteractionEnabled = true
        let tap  = UITapGestureRecognizer(target: self, action: #selector(tapBackgroundView(_:)))
        backgroundView.addGestureRecognizer(tap)
        self.addSubview(backgroundView)
        
        pannelView.frame = CGRectMake(0, self.h, self.w, 0)
        pannelView.backgroundColor = InnerConstant.PannelViewColor
        pannelView.userInteractionEnabled = true
        self.addSubview(pannelView)
        
        boderView.frame = pannelView.frame
        boderView.backgroundColor = InnerConstant.BoderViewColor
        boderView.userInteractionEnabled = true
        self.pannelView.addSubview(boderView)
        
        lineView.frame = CGRectZero
        lineView.backgroundColor = InnerConstant.LineViewColor
        boderView.addSubview(lineView)
        
        btnCancel.frame = CGRectMake(0, 0, self.w, InnerConstant.CancelBtnH)
        btnCancel.titleLabel?.font = InnerConstant.CancelBtnTitleFont
        btnCancel.setTitle("取消", forState: .Normal)
        btnCancel.setTitleColor(InnerConstant.CancelBtnTitleColor, forState: .Normal)
        btnCancel.backgroundColor = InnerConstant.CancelBtnBGColor
        self.pannelView.addSubview(btnCancel)
        
        btnCancel.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext{ [weak self] _ in
            self?.tappedCancel()
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var height : CGFloat = 0
        
        //HeaderView
        if let headerView_t = headerView {
            headerView_t.frame = CGRectMake(0, 0, headerView_t.w, headerView_t.h)
            height += headerView_t.h
        }
        
        //BoderView
        boderView.frame = CGRectMake(0, height, boderView.w, boderView.h)
        height += boderView.h
        
        //FooterView
        if let footerView_t = footerView {
            footerView_t.frame = CGRectMake(0, height, footerView_t.w, footerView_t.h)
            height += footerView_t.h
        }
        
        //取消按钮
        btnCancel.frame = CGRectMake(0, height, btnCancel.w, btnCancel.h)
        height += btnCancel.h
        
        //面板
        pannelView.frame = CGRectMake(0, self.h, pannelView.w, height)
        
        UIView.animateWithDuration(InnerConstant.TimeInterval, animations: {
            self.pannelView.frame = CGRectMake(0, self.h - height, self.pannelView.w, height)
            self.backgroundView.alpha = InnerConstant.BackgroundViewAlpha
        })
    }
    
    //MARK: Action
    dynamic func tapBackgroundView(gusture:UITapGestureRecognizer){
        self.tappedCancel()
    }
    
    dynamic func tappedCancel(){
        UIView.animateWithDuration(InnerConstant.TimeInterval, animations: { _ in
            
            self.backgroundView.alpha = 0
            self.pannelView.frame = CGRectMake(0, self.h, self.pannelView.w, self.pannelView.h)
            
        }, completion:{ (finished:Bool) -> Void in
            self.removeFromSuperview()
        })
    }
    
    //MARK: Delegate
    func toolsPannelScrollViewButtonAction(toolsPannelScrollView: ToolsPannelScrollView, model: ToolsModel) {
        
        self.tappedCancel()
        
        if delegate != nil {
            delegate?.sharePannelViewButtonAction(self, model: model)
        }
    }
}


class ToolsPannelScrollView: UIScrollView {
    
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
    
    private weak var toolsDelegate : ToolsPannelScrollViewDelegate?
    
    var toolsArray : [ToolsModel]? {
        didSet{
            if let toolsArray_t = toolsArray {
                
                //先移除之前的View
                if (self.subviews.count > 0) {
                    self.removeSubviews()
                }
                
                //设置当前scrollView的contentSize
                self.contentSize = CGSizeMake(InnerConstant.OriginX + CGFloat(toolsArray_t.count) * (InnerConstant.IcoWidth + InnerConstant.HorizontalSpace),self.h)
                
                //遍历标签数组,将标签显示在界面上,并给每个标签打上tag加以区分
                for index in 0..<toolsArray_t.count {
                    let model = toolsArray_t[safe: index]
                    if let toolModel = model {
                        let itemView = self.getToolItme(CGRectMake(InnerConstant.OriginX + CGFloat(index) * (InnerConstant.IcoWidth + InnerConstant.HorizontalSpace),
                            InnerConstant.OriginY,
                            InnerConstant.IcoWidth,
                            InnerConstant.IcoWidth + InnerConstant.IcoAndTitleSpace + InnerConstant.TitleLabelHeight), model: toolModel, btnTag: index + 1)
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    dynamic func setupUI() {
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor.clearColor()
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    dynamic static func getToolsScrollViewHeight() -> Float {
        let height : CGFloat = InnerConstant.OriginY + InnerConstant.IcoWidth + InnerConstant.IcoAndTitleSpace + InnerConstant.TitleLabelHeight + InnerConstant.LastlySpace
        return Float(height)
    }
    
    private func getToolItme(frame : CGRect , model : ToolsModel ,btnTag :Int) -> UIView {
        let toolItme = UIView(frame: frame)
        toolItme.backgroundColor = UIColor.clearColor()
        
        let btn : UIButton = UIButton(type: .Custom)
        btn.tag = btnTag
        btn.frame = CGRectMake((toolItme.w - InnerConstant.IcoWidth)/2, 0, InnerConstant.IcoWidth, InnerConstant.IcoWidth)
        btn.backgroundColor = UIColor.clearColor()
        
        if let imageStr = model.image {
            if let image = UIImage(named: imageStr) {
                btn.setImage(image, forState: .Normal)
            }
        }
        
        if let imageStr = model.highlightedImage {
            if let image = UIImage(named: imageStr) {
                btn.setImage(image, forState: .Highlighted)
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
        
        let label : UILabel = UILabel(frame: CGRectMake(-5, btn.h + InnerConstant.IcoAndTitleSpace , toolItme.w+10, InnerConstant.TitleLabelHeight))
        label.font = UIFont.systemFontOfSize(InnerConstant.TitleSize)
        label.text = model.title ?? ""
        label.textColor = InnerConstant.TitleColor
        label.textAlignment = NSTextAlignment.Center
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clearColor()
        label.sizeToFit()
        toolItme.addSubview(label)
        
        label.frame = CGRectMake(-5, btn.h + InnerConstant.IcoAndTitleSpace , toolItme.w+10, label.h)
        
        return toolItme
    }
}
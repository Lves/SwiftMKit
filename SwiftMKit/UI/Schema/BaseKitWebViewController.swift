//
//  BaseKitWebViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/28/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import SnapKit
import CocoaLumberjack

public class BaseKitWebViewController: BaseKitViewController, UIWebViewDelegate , WebViewToolsPannelViewDelegate{
    public var webView: UIWebView?
    public var webViewBridge: WebViewBridge?
    
    public var showNavigationBarTopLeftCloseButton: Bool = true
    public var shouldAllowRirectToUrlInView: Bool = true
    
    public var url: String?
    
    var webViewToolsPannelView :WebViewToolsPannelView?
    
    public override func setupUI() {
        super.setupUI()
        webView = UIWebView(frame: CGRectZero)
        self.view.addSubview(webView!)
        webView!.delegate = self
        webView!.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        webViewBridge = WebViewBridge(webView: webView!, viewController: self)
        if url != nil {
            self.loadData()
        }
    }
    public override func setupNavigation() {
        super.setupNavigation()
        if let btnBack = navBtnBack() {
            self.navigationItem.leftBarButtonItems = [btnBack]
        }
        
        //MARK - Edit By Wangzhanshi 误删
//        if let btnMore : UIBarButtonItem = navBtnMore() {
//            self.navigationItem.rightBarButtonItem = btnMore
//        }
    }
    public override func loadData() {
        super.loadData()
        if url != nil {
            self.webViewBridge?.requestUrl(self.url)
        }
    }
    
    public func webViewDidStartLoad(webView: UIWebView) {
        webViewBridge?.indicator.startAnimating()
        webView.bringSubviewToFront(webViewBridge!.indicator)
    }
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if shouldAllowRirectToUrlInView {
            DDLogInfo("Web view direct to url: \(request.URLRequest.URLString)")
            return true
        } else {
            DDLogWarn("Web view direct to url forbidden: \(request.URLRequest.URLString)")
            return false
        }
    }
    public func webViewDidFinishLoad(webView: UIWebView) {
        webViewBridge?.indicator.stopAnimating()
        if self.title == nil {
            self.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        }
        refreshNavigationBarTopLeftCloseButton()
    }
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        webViewBridge?.indicator.stopAnimating()
        if let tip = error?.localizedDescription {
            self.showTip(tip)
        }
    }
    
    public func refreshNavigationBarTopLeftCloseButton() {
        if showNavigationBarTopLeftCloseButton {
            if webView?.canGoBack ?? false {
                if self.navigationItem.leftBarButtonItems != nil {
                    if let btnBack = navBtnBack() {
                        self.navigationItem.leftBarButtonItems = [btnBack, navBtnClose()]
                    }
                }
            } else {
                if let btnBack = navBtnBack() {
                    self.navigationItem.leftBarButtonItems = [btnBack]
                }
            }
        }
    }
    
    public func navBtnBack() -> UIBarButtonItem? {
        if let btnBack = self.navigationItem.leftBarButtonItems?.first {
            return btnBack
        }
        return UIBarButtonItem(title: "返回", style: .Plain, target: self, action: #selector(BaseKitWebViewController.click_nav_back(_:)))
    }
    public func navBtnClose() -> UIBarButtonItem {
        return UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: #selector(BaseKitWebViewController.click_nav_close(_:)))
    }
    public func navBtnMore() -> UIBarButtonItem {
        return UIBarButtonItem(title: "•••", style: .Plain, target: self, action: #selector(BaseKitWebViewController.click_nav_more(_:)))
    }
    
    public func click_nav_back(sender: UIBarButtonItem) {
        if webView?.canGoBack ?? false {
            webView?.goBack()
        } else {
            self.routeBack()
        }
    }
    public func click_nav_close(sender: UIBarButtonItem) {
        self.routeBack()
    }
    public func click_nav_more(sender: UIBarButtonItem) {
        
        let labHeaderView : UILabel = UILabel(frame: CGRectMake(0, 0, self.view.w, 30))
        labHeaderView.font = UIFont.systemFontOfSize(10)
        labHeaderView.text = "网页由 www.jimubox.com 提供"
        labHeaderView.textColor = UIColor.grayColor()
        labHeaderView.textAlignment = NSTextAlignment.Center
        
        webViewToolsPannelView = WebViewToolsPannelView(frame: CGRectMake(0, 0, self.view.w, self.view.h+64))
        webViewToolsPannelView?.delegate = self
        webViewToolsPannelView!.headerView = labHeaderView
        webViewToolsPannelView!.firstCount = 6
        webViewToolsPannelView!.toolsArray = [ToolsModel(image: "login_view_logo_text", highlightedImage: "setting_icon_helper", title: "发送给朋友", used: .ShareToWeixin)
            ,ToolsModel(image: "login_view_logo_text", highlightedImage: "setting_icon_helper", title: "分享到朋友圈", used: .ShareToTimeLine)
            ,ToolsModel(image: "login_view_logo_text", highlightedImage: "setting_icon_helper", title: "收藏", used: .Collection)
            ,ToolsModel(image: "login_view_logo_text", highlightedImage: "setting_icon_helper", title: "在Safari中\n打开", used: .OpenBySafari)
            ,ToolsModel(image: "login_view_logo_text", highlightedImage: "setting_icon_helper", title: "分享到\n手机QQ", used: .ShareToQQ)
            ,ToolsModel(image: "login_view_logo_text", highlightedImage: "setting_icon_helper", title: "分享到\nQQ空间", used: .ShareToQZone)
            ,ToolsModel(image: "login_view_logo_text", highlightedImage: "setting_icon_helper", title: "查看公众号", used: .Default)
            ,ToolsModel(image: "login_view_logo_text", highlightedImage: "setting_icon_helper", title: "复制链接", used: .CopyLink)
            ,ToolsModel(image: "login_view_logo_text", highlightedImage: "setting_icon_helper", title: "调整字体", used: .SetTextFont)
            ,ToolsModel(image: "login_view_logo_text", highlightedImage: "setting_icon_helper", title: "刷新", used: .WebRefresh)
            ,ToolsModel(image: "login_view_logo_text", highlightedImage: "setting_icon_helper", title: "投诉", used: .Default)]
        
        self.navigationController?.view.addSubview(webViewToolsPannelView!)
    }
    
    
    
    //MARK : - WebViewToolsPannelViewDelegate
    func webViewToolsPannelViewButtonAction(webViewToolsPannelView: WebViewToolsPannelView, model: ToolsModel) {
        
        DDLogInfo(model.title!)
        
        switch model.used {
        case .ShareToWeixin:
            break
            
        case .ShareToTimeLine:
            break
            
        case .Collection:
            break
            
        case .OpenBySafari:
            UIApplication.sharedApplication().openURL((webView?.request?.URL)!)
            break
            
        case .ShareToQQ:
            break
            
        case .ShareToQZone:
            break
            
        case .CopyLink:
            UIPasteboard.generalPasteboard().string = url
            self.showTip("已复制链接到剪切版")
            break
            
        case .SetTextFont:
            break
            
        case .WebRefresh:
            webView?.reload()
            break
            
        default:
            break
            
        }
    }
    
    deinit {
    }
}

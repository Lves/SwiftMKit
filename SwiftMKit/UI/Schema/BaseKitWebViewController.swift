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
import WebKit
import WebViewJavascriptBridge

open class BaseKitWebViewController: BaseKitViewController, UIWebViewDelegate , SharePannelViewDelegate ,UIScrollViewDelegate ,WebViewProgressDelegate{
    
    struct InnerConst {
        static let RootViewBackgroundColor : UIColor = UIColor(hex6: 0x2F3549)
        static let WebViewBackgroundColor : UIColor = UIColor.clear
        static let PannelTitleColor : UIColor = UIColor.gray
        static let BackGroundTitleColor : UIColor = UIColor.lightText
    }
    
    open var webView: UIWebView?
    open var webViewBridge: WebViewBridge?
    open var webViewUserAgent: [String: AnyObject]? {
        didSet {
            webViewBridge?.userAgent = webViewUserAgent
        }
    }
    open var webViewRequestHeader: [String: String]? {
        didSet {
            webViewBridge?.requestHeader = webViewRequestHeader
        }
    }
    
    open var progressView : UIProgressView?
    open var webViewProgress: WebViewProgress = WebViewProgress()
    
    open var disableUserSelect = false
    open var disableLongTouch = false
    open var showNavigationBarTopLeftCloseButton: Bool = true
    open var shouldAllowRirectToUrlInView: Bool = true
    open var showNavRightToolPannelItem: Bool = true {
        didSet {
            self.refreshNavigationBarTopRightMoreButton()
        }
    }
    
    open var recordOffset: Bool = true
    open static var webOffsets: [String: CGFloat] = [:]
    open var url: String?
    open var moreUrlTitle: String? {
        get {
            if let host = URL(string:url ?? "")?.host {
                return host
            }
            return url
        }
    }
    
    var webViewToolsPannelView :SharePannelView?
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webViewToolsPannelView?.tappedCancel()
    }
    
    open override func setupUI() {
        super.setupUI()
        self.view.backgroundColor = InnerConst.RootViewBackgroundColor
        self.view.addSubview(self.getBackgroundLab())
        webView = UIWebView(frame: CGRect.zero)
        webView?.backgroundColor = InnerConst.WebViewBackgroundColor
        self.view.addSubview(webView!)
        webView!.delegate = self
        webView?.scrollView.delegate = self
        webView!.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        webViewBridge = WebViewBridge(webView: webView!, viewController: self)
        webViewProgress.progressDelegate = self
        progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.screenW, height: 0))
        progressView?.trackTintColor = UIColor.clear
        self.view.addSubview(progressView!)
        bindEvents()
        
        if url != nil {
            self.loadData()
        }
    }
    open override func setupNavigation() {
        super.setupNavigation()
        if let btnBack = navBtnBack() {
            self.navigationItem.leftBarButtonItems = [btnBack]
        }
        self.refreshNavigationBarTopRightMoreButton()
    }
    open override func loadData() {
        super.loadData()
        if url != nil {
            self.webViewBridge?.requestUrl(self.url)
        }
    }
    open func bindEvents() {
        DDLogWarn("Need to implement the function of 'bindEvents'")
    }
    open func bindEvent(_ eventName: String, handler: WVJBHandler) {
        webViewBridge?.addEvent(eventName, handler: handler)
    }
    
    //WebViewProgressDelegate
    func webViewProgress(_ webViewProgress: WebViewProgress, updateProgress progress: Float) {
        DDLogInfo("WebView Progress: \(progress)")
        if progress > 0.0 && progress < 1.0 {
            self.progressView?.alpha = 1.0
            self.progressView?.setProgress(progress, animated: true)
        }
        else if progress == 0.0 {
            self.progressView?.alpha = 0.0
            self.progressView?.setProgress(progress, animated: false)
        }
        else if progress == 1.0 {
            self.progressView?.setProgress(progress, animated: true)
            UIView.animate(withDuration: 2.5, animations: {
                self.progressView?.alpha = 0.0
            })
        }
    }
    
    //WebViewDelegate
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        var ret = true
        
        if shouldAllowRirectToUrlInView {
            DDLogInfo("Web view direct to url: \(request.URLRequest.URLString)")
            ret = true
        } else {
            DDLogWarn("Web view direct to url forbidden: \(request.URLRequest.URLString)")
            ret = false
        }
        
        ret = webViewProgress.progressWebView(webView, shouldStartLoadWithRequest: request, navigationType: navigationType ,delegatRet: ret)
        
        return ret
    }
    
    open func webViewDidStartLoad(_ webView: UIWebView) {
        webViewProgress.progressWebViewDidStartLoad(webView)
        webViewBridge?.indicator.startAnimating()
        webView.bringSubview(toFront: webViewBridge!.indicator)
    }
    
    open func webViewDidFinishLoad(_ webView: UIWebView) {
        webViewProgress.progressWebViewDidFinishLoad(webView)
        webViewBridge?.indicator.stopAnimating()
        if self.title == nil {
            self.title = webView.stringByEvaluatingJavaScript(from: "document.title")
        }
        if disableUserSelect {
            webView.stringByEvaluatingJavaScript(from: "document.documentElement.style.webkitUserSelect='none';")
        }
        if disableLongTouch {
            webView.stringByEvaluatingJavaScript(from: "document.documentElement.style.webkitTouchCallout='none';")
        }

        refreshNavigationBarTopLeftCloseButton()
        
        url = webView.request?.url?.URLString
        
        if recordOffset {
            if let offset = BaseKitWebViewController.webOffsets[url ?? ""] {
                webView.scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
            }
        }
    }
    
    open func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        webViewProgress.progressWebView(webView, didFailLoadWithError: error)
        webViewBridge?.indicator.stopAnimating()
    
        if let tip = error.localizedDescription {
            
            if (error.code == URLError.cancelled.rawValue){
                return
            }
            
            self.showTip(tip)
        }
    }
    
    open func refreshNavigationBarTopLeftCloseButton() {
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
    
    open func refreshNavigationBarTopRightMoreButton() {
        if showNavRightToolPannelItem {
            if let btnMore : UIBarButtonItem = navBtnMore() {
                self.navigationItem.rightBarButtonItem = btnMore
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    open func navBtnBack() -> UIBarButtonItem? {
        if let btnBack = self.navigationItem.leftBarButtonItems?.first {
            return btnBack
        }
        return UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(BaseKitWebViewController.click_nav_back(_:)))
    }
    open func navBtnClose() -> UIBarButtonItem {
        return UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(BaseKitWebViewController.click_nav_close(_:)))
    }
    open func navBtnMore() -> UIBarButtonItem {
        return UIBarButtonItem(title: "•••", style: .plain, target: self, action: #selector(BaseKitWebViewController.click_nav_more(_:)))
    }
    
    open func getToolMoreHeaderView() -> UIView {
        let labHeaderView : UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.w, height: 30))
        labHeaderView.clipsToBounds = true
        if let urlTitle = moreUrlTitle {
            labHeaderView.font = UIFont.systemFont(ofSize: 10)
            labHeaderView.text = "网页由 \(urlTitle) 提供"
            labHeaderView.textColor = InnerConst.PannelTitleColor
            labHeaderView.textAlignment = NSTextAlignment.center
        } else {
            labHeaderView.h = 0
        }
        return labHeaderView
    }
    
    open func getBackgroundLab() -> UIView {
        let labBackground : UILabel = UILabel(frame: CGRect(x: 0, y: 10, width: self.screenW, height: 30))
        labBackground.clipsToBounds = true
        if let urlTitle = moreUrlTitle {
            labBackground.font = UIFont.systemFont(ofSize: 10)
            labBackground.text = "网页由 \(urlTitle) 提供"
            labBackground.textColor = InnerConst.BackGroundTitleColor
            labBackground.textAlignment = NSTextAlignment.center
        } else {
            labBackground.h = 0
        }
        return labBackground
    }
    
    open func click_nav_back(_ sender: UIBarButtonItem) {
        if webView?.canGoBack ?? false {
            webView?.goBack()
        } else {
            self.routeBack()
        }
    }
    open func click_nav_close(_ sender: UIBarButtonItem) {
        self.routeBack()
    }
    open func click_nav_more(_ sender: UIBarButtonItem) {
        
        webViewToolsPannelView = SharePannelView(frame: CGRect(x: 0, y: 0, width: self.view.w, height: self.view.h+64))
        webViewToolsPannelView?.delegate = self
        webViewToolsPannelView!.headerView = getToolMoreHeaderView()
        webViewToolsPannelView!.toolsArray =
            [[
                ToolsModel(image: "pannel_icon_safari", highlightedImage: "pannel_icon_safari", title: "在Safari中\n打开", used: .openBySafari),
                ToolsModel(image: "pannel_icon_link", highlightedImage: "pannel_icon_link", title: "复制链接", used: .copyLink),
                ToolsModel(image: "pannel_icon_refresh", highlightedImage: "pannel_icon_refresh", title: "刷新", used: .webRefresh)]]
        
        self.navigationController?.view.addSubview(webViewToolsPannelView!)
    }
    
    //MARK : - WebViewToolsPannelViewDelegate
    func sharePannelViewButtonAction(_ webViewToolsPannelView: SharePannelView, model: ToolsModel) {
        switch model.used {
        case .openBySafari:
            if #available(iOS 10.0, *) {
                UIApplication.shared.open((webView?.request?.url)!, options: [:], completionHandler: nil)
            }else{
                UIApplication.shared.openURL((webView?.request?.url)!)
            }
            break
        case .copyLink:
            UIPasteboard.general.string = url
            self.showTip("已复制链接到剪切版")
            break
        case .webRefresh:
            webView?.reload()
            break
            
        default:
            break
        }
    }
    
    fileprivate func saveWebOffsetY (_ scrollView : UIScrollView){
        if let key_url = url {
            BaseKitWebViewController.webOffsets[key_url] = scrollView.contentOffset.y
        }
    }
    
    //MARK : - ScrollViewDelegate
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView) {
        self.saveWebOffsetY(scrollView)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.saveWebOffsetY(scrollView)
    }
    
    deinit {
    }
}

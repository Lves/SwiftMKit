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

public class BaseKitWebViewController: BaseKitViewController, UIWebViewDelegate , SharePannelViewDelegate ,UIScrollViewDelegate ,WebViewProgressDelegate{
    
    struct InnerConst {
    }
    
    public var webView: UIWebView?
    public var webViewBridge: WebViewBridge?
    public var webViewUserAgent: [String: AnyObject]? {
        didSet {
            webViewBridge?.userAgent = webViewUserAgent
        }
    }
    
    public var progressView : UIProgressView?
    public var webViewProgress: WebViewProgress = WebViewProgress()
    
    public var showNavigationBarTopLeftCloseButton: Bool = true
    public var shouldAllowRirectToUrlInView: Bool = true
    
    public static var webOffsets: [String: CGFloat] = [:]
    public var url: String?
    public var moreUrlTitle: String? {
        get {
            if let host = NSURL(string:url ?? "")?.host {
                return host
            }
            return url
        }
    }
    public var showNavRightToolPannelItem: Bool {
        return true
    }
    
    var webViewToolsPannelView :SharePannelView?
    
    public override func setupUI() {
        super.setupUI()
        self.view.addSubview(self.getBackgroundLab())
        webView = UIWebView(frame: CGRectZero)
        webView?.backgroundColor = UIColor.clearColor()
        self.view.addSubview(webView!)
        webView!.delegate = self
        webView?.scrollView.delegate = self
        webView!.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        webViewBridge = WebViewBridge(webView: webView!, viewController: self)
        webViewProgress.progressDelegate = self
        progressView = UIProgressView(frame: CGRectMake(0, 0, self.screenW, 0))
        self.view.addSubview(progressView!)
        
        if url != nil {
//            url = "https://www.baidu.com/"
            self.loadData()
        }
    }
    public override func setupNavigation() {
        super.setupNavigation()
        if let btnBack = navBtnBack() {
            self.navigationItem.leftBarButtonItems = [btnBack]
        }
        if showNavRightToolPannelItem {
            if let btnMore : UIBarButtonItem = navBtnMore() {
                self.navigationItem.rightBarButtonItem = btnMore
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    public override func loadData() {
        super.loadData()
        if url != nil {
            self.webViewBridge?.requestUrl(self.url)
        }
    }
    
    //WebViewProgressDelegate
    func webViewProgress(webViewProgress: WebViewProgress, updateProgress progress: Float) {
    
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
            UIView.animateWithDuration(2.5, animations: {
                self.progressView?.alpha = 0.0
            })
        }
    }
    
    //WebViewDelegate
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {

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
    
    public func webViewDidStartLoad(webView: UIWebView) {
        webViewProgress.progressWebViewDidStartLoad(webView)
        webViewBridge?.indicator.startAnimating()
        webView.bringSubviewToFront(webViewBridge!.indicator)
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        webViewProgress.progressWebViewDidFinishLoad(webView)
        webViewBridge?.indicator.stopAnimating()
        if self.title == nil {
            self.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        }

        refreshNavigationBarTopLeftCloseButton()
        
        if let offset = BaseKitWebViewController.webOffsets[url ?? ""] {
            webView.scrollView.setContentOffset(CGPointMake(0, offset), animated: false)
        }
    }
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        webViewProgress.progressWebView(webView, didFailLoadWithError: error)
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
    
    public func getToolMoreHeaderView() -> UIView {
        let labHeaderView : UILabel = UILabel(frame: CGRectMake(0, 0, self.view.w, 30))
        labHeaderView.clipsToBounds = true
        if let urlTitle = moreUrlTitle {
            labHeaderView.font = UIFont.systemFontOfSize(10)
            labHeaderView.text = "网页由 \(urlTitle) 提供"
            labHeaderView.textColor = UIColor.grayColor()
            labHeaderView.textAlignment = NSTextAlignment.Center
        } else {
            labHeaderView.h = 0
        }
        return labHeaderView
    }
    
    public func getBackgroundLab() -> UIView {
        let labBackground : UILabel = UILabel(frame: CGRectMake(0, 10, self.screenW, 30))
        labBackground.clipsToBounds = true
        if let urlTitle = moreUrlTitle {
            labBackground.font = UIFont.systemFontOfSize(10)
            labBackground.text = "网页由 \(urlTitle) 提供"
            labBackground.textColor = UIColor.grayColor()
            labBackground.textAlignment = NSTextAlignment.Center
        } else {
            labBackground.h = 0
        }
        return labBackground
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
        
        webViewToolsPannelView = SharePannelView(frame: CGRectMake(0, 0, self.view.w, self.view.h+64))
        webViewToolsPannelView?.delegate = self
        webViewToolsPannelView!.headerView = getToolMoreHeaderView()
        webViewToolsPannelView!.toolsArray =
            [[
                ToolsModel(image: "pannel_icon_safari", highlightedImage: "pannel_icon_safari", title: "在Safari中\n打开", used: .OpenBySafari),
                ToolsModel(image: "pannel_icon_link", highlightedImage: "pannel_icon_link", title: "复制链接", used: .CopyLink),
                ToolsModel(image: "pannel_icon_refresh", highlightedImage: "pannel_icon_refresh", title: "刷新", used: .WebRefresh)]]
        
        self.navigationController?.view.addSubview(webViewToolsPannelView!)
    }
    
    //MARK : - WebViewToolsPannelViewDelegate
    func sharePannelViewButtonAction(webViewToolsPannelView: SharePannelView, model: ToolsModel) {
        switch model.used {
        case .OpenBySafari:
            UIApplication.sharedApplication().openURL((webView?.request?.URL)!)
            break
        case .CopyLink:
            UIPasteboard.generalPasteboard().string = url
            self.showTip("已复制链接到剪切版")
            break
        case .WebRefresh:
            webView?.reload()
            break
            
        default:
            break
        }
    }
    
    private func saveWebOffsetY (scrollView : UIScrollView){
        if let key_url = url {
            BaseKitWebViewController.webOffsets[key_url] = scrollView.contentOffset.y
        }
    }
    
    //MARK : - ScrollViewDelegate
    public func scrollViewDidEndDragging(scrollView: UIScrollView) {
        self.saveWebOffsetY(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.saveWebOffsetY(scrollView)
    }
    
    deinit {
    }
}

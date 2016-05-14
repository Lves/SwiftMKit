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

public class BaseKitWebViewController: BaseKitViewController, UIWebViewDelegate {
    public var webView: UIWebView?
    public var webViewBridge: WebViewBridge?
    
    public var showNavigationBarTopLeftCloseButton: Bool = true
    public var shouldAllowRirectToUrlInView: Bool = true
    
    public var url: String?
    
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
    
    deinit {
    }
}

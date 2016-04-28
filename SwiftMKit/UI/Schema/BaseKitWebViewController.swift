//
//  BaseKitWebViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/28/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import SnapKit

public class BaseKitWebViewController: BaseKitViewController, UIWebViewDelegate {
    public var webView: UIWebView?
    public var webViewBridge: WebViewBridge?
    
    public var showNavigationBarTopLeftCloseButton: Bool = true
    
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
    public func webViewDidFinishLoad(webView: UIWebView) {
        webViewBridge?.indicator.stopAnimating()
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
                    self.navigationItem.leftBarButtonItems = [navBtnBack(), navBtnClose()]
                }
            } else {
                self.navigationItem.leftBarButtonItems = nil
            }
        }
    }
    
    public func navBtnBack() -> UIBarButtonItem {
        return UIBarButtonItem(title: "返回", style: .Plain, target: self, action: #selector(BaseKitWebViewController.click_nav_back(_:)))
    }
    public func navBtnClose() -> UIBarButtonItem {
        return UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: #selector(BaseKitWebViewController.click_nav_close(_:)))
    }
    
    public func click_nav_back(sender: UIBarButtonItem) {
        if webView?.canGoBack ?? false {
            webView?.goBack()
        }
    }
    public func click_nav_close(sender: UIBarButtonItem) {
        self.routeBack()
    }
    
    deinit {
        webView?.delegate = nil
    }
}

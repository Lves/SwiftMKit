//
//  WebViewBridge.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/28/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import WebViewJavascriptBridge
import SnapKit
import CocoaLumberjack

public class WebViewBridge : NSObject {
    private weak var _webView: UIWebView?
    public weak var webView: UIWebView? {
        get {
            return _webView
        }
    }
    public weak var viewController: UIViewController?
    lazy public var indicator: UIActivityIndicatorView = UIActivityIndicatorView()
    private var bridge: WebViewJavascriptBridge
    
    init(webView: UIWebView, viewController: UIViewController) {
        _webView = webView
        self.viewController = viewController
        bridge = WebViewJavascriptBridge(forWebView: webView)
        if viewController is UIWebViewDelegate {
            bridge.setWebViewDelegate(viewController as! UIWebViewDelegate)
        }
        super.init()
        self.indicator.activityIndicatorViewStyle = .Gray
        _webView?.addSubview(self.indicator)
        _webView?.bringSubviewToFront(self.indicator)
        indicator.snp_makeConstraints { (make) in
            make.center.equalTo(_webView!)
        }
    }
    
    public func requestUrl(url: String?) {
        if url == nil || url!.length <= 0 || !UIApplication.sharedApplication().canOpenURL(NSURL(string: url!)!) {
            DDLogError("Request Invalid Url: \(url)")
            return
        }
        DDLogInfo("Request url: \(url)")
        //清除旧数据
        webView?.stringByEvaluatingJavaScriptFromString("document.body.innerHTML='';")
        willRequestUrl(url!)
        let request = NSURLRequest(URL: NSURL(string:url!)!)
        willLoadRequest(request)
        Async.background {
            self.webView?.loadRequest(request)
        }
    }
    public func willRequestUrl(url: String) {
    }
    public func willLoadRequest(request: NSURLRequest) {
    }
}
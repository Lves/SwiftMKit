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
import EZSwiftExtensions
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
    public var userAgent: [String: AnyObject]? {
        didSet {
            if var userAgent = userAgent {
                let view = UIWebView()
                let ua = view.stringByEvaluatingJavaScriptFromString("navigator.userAgent") ?? ""
                if !ua.contains("WebViewBridgeInjected") {
                    userAgent["WebViewBridgeInjected"] = true
                    NSUserDefaults.standardUserDefaults().registerDefaults(userAgent)
                }
            }
        }
    }
    public var requestHeader: [String: String]?
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
    public func addEvent(eventName: String, handler: WVJBHandler) {
        bridge.registerHandler(eventName, handler: handler)
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
        var request = NSURLRequest(URL: NSURL(string:url!)!)
        request = willLoadRequest(request)
        Async.background {
            self.webView?.loadRequest(request)
        }
    }
    public func willRequestUrl(url: String) {
    }
    public func willLoadRequest(request: NSURLRequest) -> NSURLRequest {
        if let header = requestHeader {
            if let newRequest = request.copy() as? NSMutableURLRequest {
                for (key, value) in header {
                    newRequest.setValue(value, forHTTPHeaderField: key)
                }
                return newRequest
            }
        }
        return request
    }
}
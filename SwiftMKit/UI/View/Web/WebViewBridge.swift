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

public protocol WebViewBridgeProtocol: class {
    func requestHeader(request: URLRequest) -> [String: String]?
}

open class WebViewBridge : NSObject {
    private weak var _webView: UIWebView?
    open weak var webView: UIWebView? {
        get {
            return _webView
        }
    }
    open weak var viewController: UIViewController?
    public weak var delegate: WebViewBridgeProtocol?
    lazy open var indicator: UIActivityIndicatorView = UIActivityIndicatorView()
    open var userAgent: [String: Any]? {
        didSet {
            if var userAgent = userAgent {
                let view = UIWebView()
                let ua = view.stringByEvaluatingJavaScript(from: "navigator.userAgent") ?? ""
                if !ua.contains("WebViewBridgeInjected") {
                    userAgent["WebViewBridgeInjected"] = true as AnyObject?
                    UserDefaults.standard.register(defaults: userAgent)
                }
            }
        }
    }
    private var bridge: WebViewJavascriptBridge
    
    init(webView: UIWebView, viewController: UIViewController) {
        _webView = webView
        self.viewController = viewController
        bridge = WebViewJavascriptBridge(for: webView)
        if viewController is UIWebViewDelegate {
            bridge.setWebViewDelegate(viewController as! UIWebViewDelegate)
        }
        super.init()
        self.indicator.activityIndicatorViewStyle = .gray
        _webView?.addSubview(self.indicator)
        _webView?.bringSubview(toFront: self.indicator)
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(_webView!)
        }
    }
    open func addEvent(_ eventName: String, handler: @escaping WVJBHandler) {
        bridge.registerHandler(eventName, handler: handler)
    }
    

    public func callEvent(eventName: String, data: AnyObject, responseCallback: @escaping WVJBResponseCallback) {
        bridge.callHandler(eventName, data: data, responseCallback: responseCallback)
    }
    
    public func requestUrl(url: String?) {
        if url == nil || url!.length <= 0 || !UIApplication.shared.canOpenURL(URL(string: url!)!) {
            DDLogError("Request Invalid Url: \(url ?? ""))")
            return
        }
        DDLogInfo("Request url: \(url ?? "")")
        //清除旧数据
        _ = webView?.stringByEvaluatingJavaScript(from: "document.body.innerHTML='';")
        willRequestUrl(url!)
        var request = URLRequest(url: URL(string:url!)!)
        request = willLoadRequest(request)
        _ = Async.background {
            self.webView?.loadRequest(request)
        }
    }
    open func willRequestUrl(_ url: String) {
    }
    open func willLoadRequest(_ request: URLRequest) -> URLRequest {
        var request = request
        if let header = delegate?.requestHeader(request: request) {
            for (key, value) in header {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        return request
    }
}

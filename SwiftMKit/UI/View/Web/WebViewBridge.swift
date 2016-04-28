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

public class WebViewBridge : NSObject {
    public weak var webView: UIWebView?
    public weak var viewController: UIViewController?
    private var bridge: WebViewJavascriptBridge
    
    init(webView: UIWebView, viewController: UIViewController) {
        self.webView = webView
        self.viewController = viewController
        bridge = WebViewJavascriptBridge(forWebView: webView)
        
        super.init()
    }
}
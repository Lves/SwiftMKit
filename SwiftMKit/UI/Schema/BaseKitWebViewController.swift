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
    
    public override func setupUI() {
        super.setupUI()
        webView = UIWebView(frame: CGRectZero)
        self.view.addSubview(webView!)
        webView!.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        webViewBridge = WebViewBridge(webView: webView!, viewController: self)
    }
    
    deinit {
        webView?.delegate = nil
    }
}

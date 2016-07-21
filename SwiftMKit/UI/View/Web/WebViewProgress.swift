//
//  WebViewProgress.swift
//  Merak
//
//  Created by HeLi on 16/7/21.
//  Copyright © 2016年 jimubox. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

protocol WebViewProgressDelegate: class {
    func webViewProgress(webViewProgress: WebViewProgress, updateProgress progress: Float)
}

public class WebViewProgress : NSObject {
    
    struct InnerConst {
        static let InitialProgressValue : Float = 0.1
        static let InteractiveProgressValue : Float = 0.5
        static let FinalProgressValue : Float = 0.9
        static let CompleteRPCURLPath : String = "/webviewprogressproxy/complete"
    }
    
    private weak var _webView: UIWebView?
    public weak var webView: UIWebView? {
        get {
            return _webView
        }
    }
    
    weak var progressDelegate : WebViewProgressDelegate?
    
    var progress : Float = 0 {
        didSet{
            if progressDelegate != nil {
                progressDelegate?.webViewProgress(self, updateProgress: progress)
            }
            
            DDLogInfo("progress is \(progress)")
        }
    }
    var loadingCount : Int = 0
    var maxLoadCount : Int = 0
    var currentURL : NSURL?
    var interactive : Bool = false
    
    func startProgress() {
        if progress < InnerConst.InitialProgressValue{
            progress = InnerConst.InitialProgressValue
        }
    }
    
    func incrementProgress() {
        var tempProgress = progress
        let maxProgress = interactive ? InnerConst.FinalProgressValue : InnerConst.InteractiveProgressValue //结束0.9 没结束0.5
        let remainPercent = Float(loadingCount) / Float(maxLoadCount)
        let increment = (maxProgress - tempProgress) * remainPercent
        tempProgress += increment
        tempProgress = min(tempProgress, maxProgress)
        tempProgress = max(tempProgress, 0)
        progress = tempProgress
        
        DDLogInfo("increment \(increment)")
    }
    
    func completeProgress() {
        progress = 1.0
    }
    
    func reset() {
        progress = 0.0
        maxLoadCount = 0
        loadingCount = 0
        interactive = false
    }
 
    public func progressWebView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType , delegatRet : Bool) -> Bool {
        
        if request.URL!.path == InnerConst.CompleteRPCURLPath {
            self.completeProgress()
            return false
        }
        
        var isFragmentJump : Bool = false
        
        if ((request.URL?.fragment) != nil) {
            let nonFragmentURL = request.URL?.absoluteString.stringByReplacingOccurrencesOfString("#\(request.URL!.fragment)", withString: "")
            
            isFragmentJump = nonFragmentURL == webView.request!.URL!.absoluteString
        }
        
        let isTopLevelNavigation : Bool = request.mainDocumentURL == request.URL
        
        let isHTTPOrLocalFile : Bool = (request.URL!.scheme == "http")
                                    || (request.URL!.scheme == "https")
                                    || (request.URL!.scheme == "file")
        
        if (delegatRet && !isFragmentJump && isHTTPOrLocalFile && isTopLevelNavigation){
            currentURL = request.URL
            self.reset()
        }
        
        return true
    }
    
    public func progressWebViewDidStartLoad(webView: UIWebView) {
        loadingCount += 1
        maxLoadCount = max(maxLoadCount, loadingCount)
        self.startProgress()
    }
    
    public func progressWebViewDidFinishLoad(webView: UIWebView) {
        loadingCount -= 1
        self.incrementProgress()
        self.runFinishJS(webView,error: nil)
    }
    
    public func progressWebView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        loadingCount -= 1
        self.incrementProgress()
        self.runFinishJS(webView,error: error)
    }

    private func runFinishJS(webView: UIWebView, error: NSError?) {
        let readyState = webView.stringByEvaluatingJavaScriptFromString("document.readyState")
        let tempInteractive : Bool = readyState == "interactive"
        
        //运行自定义的结束JS
        if tempInteractive {
            interactive = true
            let waitForCompleteJS = "window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '\(webView.request!.mainDocumentURL!.scheme)://\(webView.request!.mainDocumentURL!.host)\(InnerConst.CompleteRPCURLPath)'; document.body.appendChild(iframe);  }, false);"
            webView.stringByEvaluatingJavaScriptFromString(waitForCompleteJS)
        }
        
        let isNotRedirect : Bool = (currentURL?.isEqual(webView.request!.mainDocumentURL))!
        let complete = readyState == "complete"
        
        if (complete && isNotRedirect) || error != nil {
            self.completeProgress()
        }
    }
}
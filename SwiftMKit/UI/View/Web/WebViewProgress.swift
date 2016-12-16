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
    func webViewProgress(_ webViewProgress: WebViewProgress, updateProgress progress: Float)
}

open class WebViewProgress : NSObject {
    
    struct InnerConst {
        static let InitialProgressValue : Float = 0.1
        static let InteractiveProgressValue : Float = 0.5
        static let FinalProgressValue : Float = 0.9
        static let CompleteRPCURLPath : String = "/webviewprogressproxy/complete"
    }
    
    fileprivate weak var _webView: UIWebView?
    open weak var webView: UIWebView? {
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
        }
    }
    var loadingCount : Int = 0
    var maxLoadCount : Int = 0
    var currentURL : URL?
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
 
    open func progressWebView(_ webView: UIWebView, shouldStartLoadWithRequest request: URLRequest, navigationType: UIWebViewNavigationType , delegatRet : Bool) -> Bool {
        
        if request.url!.path == InnerConst.CompleteRPCURLPath {
            self.completeProgress()
            return false
        }
        
        var isFragmentJump : Bool = false
        
        if ((request.url?.fragment) != nil) {
            let nonFragmentURL = request.url?.absoluteString.replacingOccurrences(of: "#\(request.url!.fragment)", with: "")
            
            if let url = webView.request?.url{
                if let absoluteString : String = url.absoluteString{
                    isFragmentJump = nonFragmentURL == absoluteString
                }
            }
        }
        
        let isTopLevelNavigation : Bool = request.mainDocumentURL == request.url
        
        let isHTTPOrLocalFile : Bool = (request.url!.scheme == "http")
                                    || (request.url!.scheme == "https")
                                    || (request.url!.scheme == "file")
        
        if (delegatRet && !isFragmentJump && isHTTPOrLocalFile && isTopLevelNavigation){
            currentURL = request.url
            self.reset()
        }
        
        currentURL = request.url
        
        return true
    }
    
    open func progressWebViewDidStartLoad(_ webView: UIWebView) {
        loadingCount += 1
        maxLoadCount = max(maxLoadCount, loadingCount)
        self.startProgress()
    }
    
    open func progressWebViewDidFinishLoad(_ webView: UIWebView) {
        loadingCount -= 1
        self.incrementProgress()
        self.runFinishJS(webView,error: nil)
    }
    
    open func progressWebView(_ webView: UIWebView, didFailLoadWithError error: NSError?) {
        loadingCount -= 1
        self.incrementProgress()
        self.runFinishJS(webView,error: error)
    }

    fileprivate func runFinishJS(_ webView: UIWebView, error: NSError?) {
        let readyState = webView.stringByEvaluatingJavaScript(from: "document.readyState")
        let tempInteractive : Bool = readyState == "interactive"
        
        //运行自定义的结束JS
        if tempInteractive {
            interactive = true
            let waitForCompleteJS = "window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '\(webView.request!.mainDocumentURL!.scheme)://\(webView.request!.mainDocumentURL!.host)\(InnerConst.CompleteRPCURLPath)'; document.body.appendChild(iframe);  }, false);"
            webView.stringByEvaluatingJavaScript(from: waitForCompleteJS)
        }
        
        let isNotRedirect : Bool = (currentURL? == webView.request!.mainDocumentURL)
        
        let complete = readyState == "complete"
        
//        if (complete && isNotRedirect) || error != nil {
//            self.completeProgress()
//        }
        
        if (complete) || error != nil {
            self.completeProgress()
        }
        
        DDLogInfo("[runFinishJS] \(complete) \(isNotRedirect)")
        
        DDLogInfo("[runFinishJS] \n\(currentURL) \n\(webView.request!.mainDocumentURL) \n\(webView.request!.URLString)")
    }
}

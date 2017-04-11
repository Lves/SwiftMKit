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
import MJRefresh
import WebKit
import WebViewJavascriptBridge

open class BaseKitWebViewController: BaseKitViewController, UIWebViewDelegate, SharePannelViewDelegate, UIScrollViewDelegate, WebViewProgressDelegate, WebViewBridgeProtocol{
    
    struct InnerConst {
        static let RootViewBackgroundColor : UIColor = UIColor(hex6: 0xefeff4)
        static let WebViewBackgroundColor : UIColor = UIColor.clear
        static let PannelTitleColor : UIColor = UIColor.gray
        static let BackGroundTitleColor : UIColor = UIColor.darkGray
    }
    
    private var _webView: UIWebView?
    open var webView: UIWebView {
        get {
            if _webView == nil {
                _webView = UIWebView(frame: CGRect.zero)
                _webView?.backgroundColor = InnerConst.WebViewBackgroundColor
                self.view.addSubview(_webView!)
                if let progressView = progressView {
                    self.view.bringSubview(toFront: progressView)
                }
                _webView!.delegate = self
                _webView?.scrollView.delegate = self
                _webView!.snp.makeConstraints { (make) in
                    make.edges.equalTo(self.view)
                }
            }
            return _webView!
        }
    }
    private var _webViewBridge: WebViewBridge?
    open var webViewBridge: WebViewBridge {
        get {
            if _webViewBridge == nil {
                _webViewBridge = WebViewBridge(webView: webView, viewController: self)
            }
            return _webViewBridge!
        }
    }
    open var webViewUserAgent: [String: Any]? {
        didSet {
            webViewBridge.userAgent = webViewUserAgent
        }
    }
    open var webViewRequestHeader: [String: String]?
    
    open var progressView : UIProgressView?
    open var webViewProgress: WebViewProgress = WebViewProgress()
    
    open var disableUserSelect = false
    open var disableLongTouch = false
    open var showRefreshHeader: Bool = true
    open var showNavigationBarTopLeftCloseButton: Bool = true
    open var shouldAllowRirectToUrlInView: Bool = true
    open var showNavRightToolPannelItem: Bool = true {
        didSet {
            self.refreshNavigationBarTopRightMoreButton()
        }
    }
    
    open var recordOffset: Bool = true
    open static var webOffsets: [String: CGFloat] = [:]
    open var url: String?
    open var moreUrlTitle: String? {
        get {
            if let host = URL(string: url ?? "")?.host {
                return host
            }
            return url
        }
    }
    
    var webViewToolsPannelView :SharePannelView?
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webViewToolsPannelView?.tappedCancel()
    }
    
    open override func setupUI() {
        super.setupUI()
        self.view.backgroundColor = InnerConst.RootViewBackgroundColor
        self.view.addSubview(self.getBackgroundLab())
        webViewProgress.progressDelegate = self
        progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.screenW, height: 0))
        progressView?.trackTintColor = UIColor.clear
        self.view.addSubview(progressView!)
        bindEvents()
        
        if showRefreshHeader {
            self.webView.scrollView.mj_header = self.webViewWithRefreshingBlock { [weak self] in
                self?.loadData()
            }
        }
        
        loadData()
    }
    
    open override func setupNavigation() {
        super.setupNavigation()
        if let btnBack = navBtnBack() {
            self.navigationItem.leftBarButtonItems = [btnBack]
        }
        self.refreshNavigationBarTopRightMoreButton()
    }
    
    open func webViewWithRefreshingBlock(_ refreshingBlock:@escaping MJRefreshComponentRefreshingBlock)->MJRefreshHeader{
        let header = MJRefreshNormalHeader(refreshingBlock:refreshingBlock);
        header?.activityIndicatorViewStyle = .gray
        header?.labelLeftInset = 0
        header?.setTitle("", for: .idle)
        header?.setTitle("", for: .pulling)
        header?.setTitle("", for: .refreshing)
        header?.lastUpdatedTimeLabel.text = ""
        header?.lastUpdatedTimeText = { _ in return "" }
        return header!
    }
    
    open override func loadData() {
        super.loadData()
        if url != nil {
            self.webViewBridge.requestUrl(self.url)
        }
    }
    open func bindEvents() {
        DDLogWarn("Need to implement the function of 'bindEvents'")
    }
    open func bindEvent(_ eventName: String, handler: @escaping WVJBHandler) {
        webViewBridge.addEvent(eventName, handler: handler)
    }
    
    public func requestHeader(request: URLRequest) -> [String : String]? {
        return webViewRequestHeader
    }
    
    //WebViewProgressDelegate
    func webViewProgress(_ webViewProgress: WebViewProgress, updateProgress progress: Float) {
        DDLogInfo("WebView Progress: \(progress)")
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
            UIView.animate(withDuration: 2.5, animations: {
                self.progressView?.alpha = 0.0
            })
        }
    }
    
    //WebViewDelegate
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        var ret = true
        
        if shouldAllowRirectToUrlInView {
            DDLogInfo("Web view direct to url: \(request.urlRequest?.url?.absoluteString ?? "")")
            ret = true
        } else {
            DDLogWarn("Web view direct to url forbidden: \(request.urlRequest?.url?.absoluteString ?? "")")
            ret = false
        }
        
        ret = webViewProgress.progressWebView(webView, shouldStartLoadWithRequest: request, navigationType: navigationType ,delegatRet: ret)
        
        return ret
    }
    
    open func webViewDidStartLoad(_ webView: UIWebView) {
        webViewProgress.progressWebViewDidStartLoad(webView)
        webViewBridge.indicator.startAnimating()
        webView.bringSubview(toFront: webViewBridge.indicator)
    }
    
    open func webViewDidFinishLoad(_ webView: UIWebView) {
        if let header = self.webView.scrollView.mj_header {
            header.endRefreshing()//结束下拉刷新
        }
        
        webViewProgress.progressWebViewDidFinishLoad(webView)
        webViewBridge.indicator.stopAnimating()
        if self.title == nil {
            self.title = webView.stringByEvaluatingJavaScript(from: "document.title")
        }
        if disableUserSelect {
            webView.stringByEvaluatingJavaScript(from: "document.documentElement.style.webkitUserSelect='none';")
        }
        if disableLongTouch {
            webView.stringByEvaluatingJavaScript(from: "document.documentElement.style.webkitTouchCallout='none';")
        }

        refreshNavigationBarTopLeftCloseButton()
        
        url = webView.request?.url?.absoluteString
        
        if recordOffset {
            if let offset = BaseKitWebViewController.webOffsets[url ?? ""] {
                webView.scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
            }
        }
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        webViewProgress.progressWebView(webView, didFailLoadWithError: error)
        webViewBridge.indicator.stopAnimating()
        
        let tip = error.localizedDescription
        if ((error as NSError).code == URLError.cancelled.rawValue){
            return
        }
        
        self.showTip(tip)
        
        webViewProgress.progressWebView(webView, didFailLoadWithError: error)
        webViewBridge.indicator.stopAnimating()
    }
    
    open func refreshNavigationBarTopLeftCloseButton() {
        if showNavigationBarTopLeftCloseButton {
            if webView.canGoBack {
                if self.navigationItem.leftBarButtonItems != nil {
                    if let btnBack = navBtnBack() {
                        if let btnClose = navBtnClose() {
                            self.navigationItem.leftBarButtonItems = [btnBack, btnClose]
                        }
                    }
                }
            } else {
                if let btnBack = navBtnBack() {
                    self.navigationItem.leftBarButtonItems = [btnBack]
                }
            }
        }
    }
    
    open func refreshNavigationBarTopRightMoreButton() {
        if showNavRightToolPannelItem {
            if let btnMore : UIBarButtonItem = navBtnMore() {
                self.navigationItem.rightBarButtonItem = btnMore
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    open func navBtnBack() -> UIBarButtonItem? {
        if let btnBack = self.navigationItem.leftBarButtonItems?.first {
            return btnBack
        }
        return UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(BaseKitWebViewController.click_nav_back(_:)))
    }
    open func navBtnClose() -> UIBarButtonItem? {
        return UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(BaseKitWebViewController.click_nav_close(_:)))
    }
    open func navBtnMore() -> UIBarButtonItem? {
        return UIBarButtonItem(title: "•••", style: .plain, target: self, action: #selector(BaseKitWebViewController.click_nav_more(_:)))
    }
    
    open func getToolMoreHeaderView() -> UIView {
        let labHeaderView : UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.w, height: 30))
        labHeaderView.clipsToBounds = true
        if let urlTitle = moreUrlTitle {
            labHeaderView.font = UIFont.systemFont(ofSize: 10)
            labHeaderView.text = "网页由 \(urlTitle) 提供"
            labHeaderView.textColor = InnerConst.PannelTitleColor
            labHeaderView.textAlignment = NSTextAlignment.center
        } else {
            labHeaderView.h = 0
        }
        return labHeaderView
    }
    
    open func getBackgroundLab() -> UIView {
        let labBackground : UILabel = UILabel(frame: CGRect(x: 0, y: 10, width: self.screenW, height: 30))
        labBackground.clipsToBounds = true
        if let urlTitle = moreUrlTitle {
            labBackground.font = UIFont.systemFont(ofSize: 10)
            labBackground.text = "网页由 \(urlTitle) 提供"
            labBackground.textColor = InnerConst.BackGroundTitleColor
            labBackground.textAlignment = NSTextAlignment.center
        } else {
            labBackground.h = 0
        }
        return labBackground
    }
    
    open func click_nav_back(_ sender: UIBarButtonItem) {
        if webView.canGoBack {
            webView.goBack()
        } else {
            self.routeBack()
        }
    }
    open func click_nav_close(_ sender: UIBarButtonItem) {
        self.routeBack()
    }
    open func click_nav_more(_ sender: UIBarButtonItem) {
        
        webViewToolsPannelView = SharePannelView(frame: CGRect(x: 0, y: 0, width: self.view.w, height: self.view.h+64))
        webViewToolsPannelView?.delegate = self
        webViewToolsPannelView!.headerView = getToolMoreHeaderView()
        webViewToolsPannelView!.toolsArray =
            [[
                ToolsModel(image: "pannel_icon_safari", highlightedImage: "pannel_icon_safari", title: "在Safari中\n打开", used: .openBySafari),
                ToolsModel(image: "pannel_icon_link", highlightedImage: "pannel_icon_link", title: "复制链接", used: .copyLink),
                ToolsModel(image: "pannel_icon_refresh", highlightedImage: "pannel_icon_refresh", title: "刷新", used: .webRefresh)]]
        
        self.navigationController?.view.addSubview(webViewToolsPannelView!)
    }
    
    //MARK : - WebViewToolsPannelViewDelegate
    func sharePannelViewButtonAction(_ webViewToolsPannelView: SharePannelView, model: ToolsModel) {
        switch model.used {
        case .openBySafari:
            if #available(iOS 10.0, *) {
                UIApplication.shared.open((webView.request?.url)!, options: [:], completionHandler: nil)
            }else{
                UIApplication.shared.openURL((webView.request?.url)!)
            }
            break
        case .copyLink:
            UIPasteboard.general.string = url
            self.showTip("已复制链接到剪切版")
            break
        case .webRefresh:
            if showRefreshHeader {
                self.webView.scrollView.mj_header.beginRefreshing()
            }else{
                webView.reload()
            }
            break
            
        default:
            break
        }
    }
    
    fileprivate func saveWebOffsetY (_ scrollView : UIScrollView){
        if let key_url = url {
            BaseKitWebViewController.webOffsets[key_url] = scrollView.contentOffset.y
        }
    }
    
    //MARK : - ScrollViewDelegate
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.saveWebOffsetY(scrollView)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.saveWebOffsetY(scrollView)
    }
    
    deinit {
    }
}

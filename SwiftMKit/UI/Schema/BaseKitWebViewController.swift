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

@objcMembers
open class BaseKitWebViewController: BaseKitViewController, WKNavigationDelegate, SharePannelViewDelegate, UIScrollViewDelegate {
    
    struct InnerConst {
        static let RootViewBackgroundColor : UIColor = UIColor(hex6: 0xefeff4)
        static let WebViewBackgroundColor : UIColor = UIColor.clear
        static let PannelTitleColor : UIColor = UIColor.gray
        static let BackGroundTitleColor : UIColor = UIColor.darkGray
    }
    weak var _webView: WKWebView?
    var webView: WKWebView {
        if let webV = _webView {
            return webV
        }
        let webV = self.createWebView()
        _webView = webV
        return webV
    }
    private func createWebView() -> WKWebView {
        
        let wkContentVc = WKUserContentController()
        let cookieScript = WKUserScript(source: "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta);", injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
//        let wkUScript = WKUserScript.init(source: "", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        wkContentVc.addUserScript(cookieScript)
        let config = WKWebViewConfiguration()
        config.userContentController = wkContentVc
        
        let _webView = WKWebView(frame: CGRect.zero, configuration: config)
        //声明scrollView的位置 添加下面代码
        if #available(iOS 11.0, *) {
            _webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        _webView.backgroundColor = InnerConst.WebViewBackgroundColor
        self.view.addSubview(_webView)
        if let progressView = self.progressView {
            self.view.bringSubview(toFront: progressView)
        }
        _webView.scrollView.delegate = self
        _webView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        return _webView
    }
    open lazy var webViewBridge: WKWebViewJavascriptBridge = {
        var bridge: WKWebViewJavascriptBridge = WKWebViewJavascriptBridge(for: self.webView)
        bridge.setWebViewDelegate(self)
        return bridge
    }()
    open var userAgent: String? {
        get {
            if #available(iOS 9.0, *) {
                return webView.customUserAgent
            } else {
                var ua: String?
                let semaphore =  DispatchSemaphore(value: 0)
                webView.evaluateJavaScript("navigator.userAgent", completionHandler: { (result, error) in
                    ua = result as? String
                    semaphore.signal()
                })
                semaphore.wait()
                return ua
            }
        }
        set(value) {
            if #available(iOS 9.0, *) {
                webView.customUserAgent = value
            } else {
                webView.evaluateJavaScript("navigator.userAgent") { [weak self] (result, error) in
                    UserDefaults.standard.register(defaults: ["UserAgent": value ?? ""])
                    if let wv = self?.createWebView() {
                        self?._webView = wv
                        _ = self?.webViewBridge
                        self?.webView.evaluateJavaScript("navigator.userAgent", completionHandler: {_,_ in})
                    }
                }
            }
        }
    }
    open var requestHeader: [String: String]? {
        get {
            return nil
        }
    }

    open var progressView : UIProgressView?
    let keyPathForProgress : String = "estimatedProgress"
    let keyPathForTitle : String = "title"
    open var needBackRefresh:Bool = false
    
    open var disableUserSelect = false
    open var disableLongTouch = false
    open var showRefreshHeader: Bool = true
    open var showBackgroundLab:Bool = true
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
    private var isTitleFixed: Bool = false
    
    var webViewToolsPannelView :SharePannelView?
    var needRefreshCallBack: WVJBResponseCallback?
    /// 标识：webView加载失败后，是否需要显示网络错误页面（如果有）
    var showBadNetworkViewWhenFail = false
    ///跳转前用
    var beforRouteBlock:(() -> UIViewController?)?
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webViewToolsPannelView?.tappedCancel()
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if needBackRefresh { //跳转到原生页面，返回时是否需要刷新
            needBackRefresh = false
            self.loadData()
        }
        if let needRefreshCallBack = needRefreshCallBack { //如果有刷新回调，调用之
            needRefreshCallBack(nil)
            self.needRefreshCallBack = nil
        }
    }

    open func setupBadNetworkView() -> UIView? {
        return nil
    }
    private var isFinishedOnce = false
    private var isBadNetwork = false
    private func showBadNetworkView() {
        guard let badNetwork_view = setupBadNetworkView() else { return }
        guard badNetwork_view.superview == nil else { return }
        badNetwork_view.frame = view.bounds
        view.addSubview(badNetwork_view)
    }
    private func removeBadNetworkView() {
        if let badNetwork_view = setupBadNetworkView() {
            badNetwork_view.removeFromSuperview()
        }
    }
    
    open override func setupUI() {
        super.setupUI()
        NetworkListener.listen()
        isTitleFixed = (self.title?.length ?? 0) > 0
        self.view.backgroundColor = InnerConst.RootViewBackgroundColor
        if showBackgroundLab {
            self.view.addSubview(self.getBackgroundLab())
        }
        progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.screenW, height: 0))
        progressView?.trackTintColor = UIColor.clear
        self.view.addSubview(progressView!)
        webView.addObserver(self, forKeyPath: keyPathForProgress, options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old], context: nil)
        webView.addObserver(self, forKeyPath: keyPathForTitle, options: [NSKeyValueObservingOptions.new], context: nil)
        _ = self.webViewBridge
        bindEvents()
        
        if showRefreshHeader {
            self.webView.scrollView.mj_header = self.webViewWithRefreshingBlock { [weak self] in
                self?.loadData()
            }
        }
        
        loadData()

        NetworkListener.networkStatus.producer.startWithValues {[weak self](sender) in
            if sender == .reachableViaWWAN || sender == .reachableViaWiFi {
                DDLogInfo("[Network Status] WIFI或者蜂窝网络, status: \(sender)")
                if self?.isBadNetwork == true && self?.isFinishedOnce == false {
                    self?.removeBadNetworkView()
                    self?.loadData()
                }
            } else {
                DDLogInfo("[Network Status] 无网络, status: \(sender)")
                self?.isBadNetwork = true
                if self?.isFinishedOnce == false || self?.showBadNetworkViewWhenFail == true {
                    self?.showBadNetworkView()
                }
            }
        }
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
            requestUrl(url: self.url)
        }
    }
    
    open func requestUrl(url: String?) {
        let url = url?.trimmingCharacters(in: .whitespaces) //去除前后空格
        guard let urlStr = url, urlStr.length > 0 ,let urlResult = URL(string: urlStr), UIApplication.shared.canOpenURL(urlResult) else {
            DDLogError("Request Invalid Url: \(url ?? "")")
            return
        }
        DDLogInfo("Request url: \(urlStr)")
        //清除旧数据
        webView.evaluateJavaScript("document.body.innerHTML='';") { [weak self] _,_ in
            let request = URLRequest(url: urlResult)
            if let request = self?.willLoadRequest(request) {
                self?.webView.load(request)
            }
        }
    }
    open func willLoadRequest(_ request: URLRequest) -> URLRequest {
        var request = request
        if let header = requestHeader {
            for (key, value) in header {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        return request
    }
    ///是否需要跳到热修复,只给 goToSomewhere用
    ///可以在自己项目中重写该方法
    func needRouteHotfix(controllerName:String, params:[String:Any]? = [:], pop:Bool? = false, needBlock:()->(), notNeedBlock:()->()) {
        //默认不需要热修复
        notNeedBlock()
        ///重写示例
//        let needRouteHotfix:Bool
//        if needRouteHotfix {
//            needBlock()
//        }else {
//            notNeedBlock()
//        }
    }
    open func bindEvents() {
        /**
         *  H5跳转到任意原生页面
         *  事件名：goToSomewhere
         *  参数:
         *      name:String 用.分割sbName和vcName,例如: sbName.vcName
         *      refresh:Bool 跳转到原生页面，返回时是否需要刷新
         *      pop:Bool     是否present方式弹出
         *      params:[String:Any] 作为控制器的params
         */
        self.bindEvent("goToSomewhere", handler: { [weak self] data , responseCallback in
            if let dic = data as? [String:Any] {
                if let name = dic["name"] as? String , name.length > 0{
                    //获得Controller名和Sb名
                    var (sbName,vcName) = (self?.getVcAndSbName(name: name) ?? (nil,nil))
                    if let vcName = vcName , vcName.length > 0  {
                        let refresh = (dic["refresh"] as? Bool) ?? false
                        let pop = (dic["pop"] as? Bool) ?? false
                        sbName = (sbName?.length ?? 0) > 0 ? sbName : nil
                        //是否是热切换页面
                        self?.needRouteHotfix(controllerName:vcName,
                                              params:dic["params"] as? [String:Any],
                                              pop:pop,
                                              needBlock: {
                            self?.needBackRefresh = refresh
                            self?.needRefreshCallBack = responseCallback
                        }, notNeedBlock: {
                            if let vc = self?.initialedViewController(vcName, storyboardName: sbName){
                                //获得需要的参数
                                let paramsDic = dic["params"] as? [String:Any]
                                self?.setObjectParams(vc: vc, paramsDic: paramsDic)
                                self?.needBackRefresh = refresh
                                self?.needRefreshCallBack = responseCallback
                                if let topViewController = self?.beforRouteBlock?() {
                                      topViewController.toNextViewController(viewController: vc, pop: pop)
                                }else {
                                     self?.toNextViewController(viewController: vc, pop: pop)
                                }
                            }
                        })
                    }
                }
            }
        })
        /**
         *  H5给Native的单例或者静态变量赋值，
         *  不支持同时改变静态属性和成员变量。需要调用多次依次修改
         *  事件名: changeVariables
         *  参数：
         *       name:String    用.分割类名和单例变量名,例如: BaseService.sharedBaseService（.sharedBaseService为空时,表示修改静态属性）
         *       params:[String:Any] 要修改的参数列表 (注意：修改静态属性时params中的key一定是存在的静态属性，否则会奔溃，因为无法映射静态属性列表判断有无该属性)
         */
        self.bindEvent("changeVariables", handler: {[weak self] data , responseCallback in
            if let dic = data as? [String:Any] {
                if let name = dic["name"] as? String, let paramsDic = dic["params"] as? [String:Any], name.length > 0{
                    let (className , instanceName):(String?,String?) = (self?.getClassAndInstance(name: name) ?? (nil,nil))
                    guard let objcName = className ,objcName.length > 0 else{
                        return
                    }
                    guard let instanceClass:NSObject.Type = NSObject.fullClassName(objcName) else { return }
                    if let instanceKey = instanceName ,instanceKey.length > 0{    //单例赋值
                        if let instance:NSObject = instanceClass.value(forKey: instanceKey) as? NSObject {
                            SwiftReflectionTool.setParams(paramsDic, for: instance)
                        }
                    }else {                                                       //静态属性赋值
                        for (key,value) in paramsDic {
                            instanceClass.setValue(value, forKey: key)
                        }
                    }
                }
            }
        })

    }
    open func bindEvent(_ eventName: String, handler: @escaping WVJBHandler) {
        webViewBridge.registerHandler(eventName, handler: handler)
    }
    
    /** 计算进度条 */
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if ((object as AnyObject).isEqual(webView) && ((keyPath ?? "") == keyPathForProgress)) {
            let newProgress = (change?[NSKeyValueChangeKey.newKey] as AnyObject).floatValue ?? 0
            let oldProgress = (change?[NSKeyValueChangeKey.oldKey] as AnyObject).floatValue ?? 0
            
            if newProgress < oldProgress {
                return
            }
            
            if newProgress >= 1 {
                Async.main({ [weak self] in
                    self?.progressView?.isHidden = true
                    self?.progressView?.setProgress(0, animated: false)
                })

            } else {
                Async.main({ [weak self] in
                    self?.progressView?.isHidden = false
                    self?.progressView?.setProgress(newProgress, animated: true)
                })
               
            }
        } else if ((object as AnyObject).isEqual(webView) && ((keyPath ?? "") == keyPathForTitle)) {
            if (!isTitleFixed && (object as AnyObject).isEqual(webView)) {
                self.title = self.webView.title;
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void){
        //存储返回的cookie
        if let response = navigationResponse.response as? HTTPURLResponse, let url = response.url{
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: (response.allHeaderFields as? [String : String]) ?? [:] , for: url)
            for cookie in cookies {
//                DDLogInfo("保存的ResponseCookie Name:\(cookie.name)   value:\(cookie.value)")
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
        decisionHandler(.allow)
    }
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var ret = true
        let urlStr = navigationAction.request.url?.absoluteString.removingPercentEncoding
        
        if shouldAllowRirectToUrlInView {
            DDLogInfo("Web view direct to url: \(urlStr ?? "")")
            ret = true
        } else {
            DDLogWarn("Web view direct to url forbidden: \(urlStr ?? "")")
            ret = false
        }
        //1.0 判断是不是打开App Store
        if urlStr?.hasPrefix("itms-appss://") == true || urlStr?.hasPrefix("itms-apps://") == true{
            if let url = navigationAction.request.url {
                UIApplication.shared.openURL(url)
                ret = false
            }
        }else if urlStr?.hasPrefix("http") == false && urlStr?.hasPrefix("https") == false{ // 2.0 判断是不是打开其他app，例如支付宝
            if let url = navigationAction.request.url {
                UIApplication.shared.openURL(url)
                ret = false
            }
        }
        //2.0 Cookie
        //获得cookie
        var cookStr = ""
        if let cookies =  HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                cookStr += "document.cookie = '\(cookie.name)=\(cookie.value);domain=\(cookie.domain);sessionOnly=\(cookie.isSessionOnly);path=\(cookie.path);isSecure=\(cookie.isSecure)';"
            }
        }
        //设置cookie
        if cookStr.length > 0 {
            let sc = WKUserScript(source:cookStr, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
            webView.configuration.userContentController.addUserScript(sc)
        }
        if (navigationAction.targetFrame == nil) { //新窗口打不开的bug
            webView.load(navigationAction.request)
        }
        refreshNavigationBarTopLeftCloseButton()
        decisionHandler(ret ? .allow : .cancel)
    }
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isFinishedOnce = true
        if let header = self.webView.scrollView.mj_header {
            header.endRefreshing()//结束下拉刷新
        }
        if disableUserSelect {
            webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none';") {_,_ in}
        }
        if disableLongTouch {
            webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';") {_,_ in}
        }
        
        refreshNavigationBarTopLeftCloseButton()
        
        url = webView.url?.absoluteString
        
        if recordOffset {
            if let offset = BaseKitWebViewController.webOffsets[url ?? ""] {
                webView.scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
            }
        }
    }
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let tip = error.localizedDescription
        if ((error as NSError).code == URLError.cancelled.rawValue){
            return
        }
        self.showTip(tip)
        if showBadNetworkViewWhenFail == true {
            showBadNetworkView()
        }
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
    
    @objc open func click_nav_back(_ sender: UIBarButtonItem) {
        if webView.canGoBack {
            webView.goBack()
        } else {
            self.routeBack()
        }
    }
    @objc open func click_nav_close(_ sender: UIBarButtonItem) {
        self.routeBack()
    }
    @objc open func click_nav_more(_ sender: UIBarButtonItem) {
        
        webViewToolsPannelView = SharePannelView(frame: CGRect(x: 0, y: 0, width: self.view.w, height: self.view.h+64))
        webViewToolsPannelView?.delegate = self
        webViewToolsPannelView!.headerView = getToolMoreHeaderView()
        webViewToolsPannelView!.toolsArray =
            [[
                ToolsModel(image: "pannel_icon_safari", highlightedImage: "pannel_icon_safari", title: "在Safari中\n打开", shareObjectType: .webPage, used: .openBySafari),
                ToolsModel(image: "pannel_icon_link", highlightedImage: "pannel_icon_link", title: "复制链接",shareObjectType: .webPage, used: .copyLink),
                ToolsModel(image: "pannel_icon_refresh", highlightedImage: "pannel_icon_refresh", title: "刷新",shareObjectType: .webPage, used: .webRefresh)]]
        
        self.navigationController?.view.addSubview(webViewToolsPannelView!)
    }
    
    //MARK : - WebViewToolsPannelViewDelegate
    func sharePannelViewButtonAction(_ webViewToolsPannelView: SharePannelView, model: ToolsModel) {
        switch model.used {
        case .openBySafari:
            if #available(iOS 10.0, *) {
                UIApplication.shared.open((webView.url)!, options: [:], completionHandler: nil)
            }else{
                UIApplication.shared.openURL((webView.url)!)
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
    
    //MARK: - Priavte
    //MARK:用.分割vcName和sbName
    func getVcAndSbName(name:String) -> (String?,String?) {
        let nameList = name.split(".")
        var vcName:String?
        var sbName:String?
        if nameList.count >= 2 {
            sbName = nameList.first
            vcName = nameList[1]
        }else if nameList.count == 1 {
            vcName = nameList.first
            sbName = nil
        }
        return (sbName,vcName)
    }
    //MARK:用.分割 类名和单例名
    func getClassAndInstance(name:String) -> (String?,String?) {
        let nameList = name.split(".")
        var className:String?
        var instanceName:String?
        if nameList.count >= 2 {
           className = nameList.first
           instanceName = nameList[1]
        }else if nameList.count == 1 {
            className = nameList.first
        }
        return (className,instanceName)
    }
    //MARK: 给对象赋值 ，传过来的paramsDic是[String:kindOfStirng]
    func setObjectParams(vc: NSObject, paramsDic:[String:Any]?) {
        if let paramsDic = paramsDic {
            for (key,value) in paramsDic {
                let type = vc.getTypeOfProperty(key)
                if type == NSNull.Type.self{ //未找到
                    print("VC没有该参数")
                }else if type == Bool.self || type == Bool?.self{
                    let toValue = (value as? String)?.toBool() ?? false
                    vc.setValue(toValue, forKey: key)
                }else if type == Int.self || type == Int?.self{
                    let toValue = (value as? String)?.toInt() ?? 0
                    vc.setValue(toValue, forKey: key)
                }else if type == Double.self  || type == Double?.self{
                    let toValue = (value as? String)?.toDouble() ?? 0.0
                    vc.setValue(toValue, forKey: key)
                }else if type == Float.self  || type == Float?.self{
                    let toValue = (value as? String)?.toFloat() ?? 0.0
                    vc.setValue(toValue, forKey: key)
                }else {
                    vc.setValue(value, forKey: key)
                }
            }
        }
    }

    
    deinit {
        _webView?.removeObserver(self, forKeyPath: keyPathForProgress)
        _webView?.removeObserver(self, forKeyPath: keyPathForTitle)
        _webView?.scrollView.delegate = nil
    }
}

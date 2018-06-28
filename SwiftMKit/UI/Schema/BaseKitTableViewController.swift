//
//  BaseKitTableViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/13/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack
import Alamofire
import ObjectiveC
import MJRefresh


open class BaseKitTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    open var params = [String: Any]() {
        didSet {
            for (key,value) in params {
                self.setValue(value, forKey: key)
            }
        }
    }
    open var completion: () -> Void = {}
    open var hud: HudProtocol = MBHud()
    lazy open var indicator: IndicatorProtocol = {
        return SingleApiIndicator(hud: self.hud)
    }()
    
    open var viewModel: BaseKitTableViewModel? {
        get { return nil }
    }
    open var listViewModel: BaseKitTableViewModel! {
        get {
            return viewModel! as BaseKitTableViewModel
        }
    }
    
    open var screenW: CGFloat { get { return UIScreen.main.bounds.w } }
    open var screenH: CGFloat { get { return UIScreen.main.bounds.h } }
    open var autoHidesBottomBarWhenPushed: Bool { get { return true } }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination
        if let bvc = vc as? BaseKitViewController {
            if let dict = sender as? [String: Any] {
                if var params = dict["params"] as? [String: Any] {
                    if params["hidesBottomBarWhenPushed"] == nil {
                        params["hidesBottomBarWhenPushed"] = true
                    }
                    bvc.params = params
                }
            }
        }
    }
    
    open func setupUI() {
        viewModel?.viewController = self
        
        if self.listViewType == .none || self.listViewType == .loadMoreOnly {
            self.listView.mj_header = nil
        }
        if self.listViewType == .none || self.listViewType == .refreshOnly {
            self.listView.mj_footer = nil
        }
        if self.listViewType == .both || self.listViewType == .refreshOnly {
            self.listView.mj_header = self.listViewHeaderWithRefreshingBlock {
                [weak self] in
                self?.listViewModel?.dataIndex = 0
                self?.listViewModel?.fetchData()
            }
        }
        if self.listViewType == .both || self.listViewType == .loadMoreOnly {
            self.listView.mj_footer = self.listViewFooterWithRefreshingBlock {
                [weak self] in
                self?.listViewModel?.dataIndex += 1
                self?.listViewModel?.fetchData()
            }
            self.listView.mj_footer.endRefreshingWithNoMoreData()
            if let footer = self.listView.mj_footer as? MJRefreshAutoStateFooter {
                footer.setTitle("", for: .noMoreData)
            }
        }
        
        setupNavigation()
        setupNotification()
        bindingData()
    }
    open func setupNotification() {
    }
    open func setupNavigation() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    open func bindingData() {
    }
    open func loadData() {
    }
    open func showEmptyView() {}
    open func hideEmptyView() {}
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer) {
            //只有二级以及以下的页面允许手势返回
            return (self.navigationController?.viewControllers.count ?? 0) > 1
        }
        return true
    }
    
    open var listView: UIScrollView! {
        get {
            return tableView
        }
    }
    open var listViewType: ListViewType {
        get {
            return .none
        }
    }
    
    open func listViewHeaderWithRefreshingBlock(_ refreshingBlock: @escaping MJRefreshComponentRefreshingBlock) -> MJRefreshHeader {
        let header = MJRefreshNormalHeader(refreshingBlock:refreshingBlock);
        header!.activityIndicatorViewStyle = .gray
        return header!
    }
    open func listViewFooterWithRefreshingBlock(_ refreshingBlock: @escaping MJRefreshComponentRefreshingBlock) -> MJRefreshFooter {
        let footer = MJRefreshAutoStateFooter(refreshingBlock:refreshingBlock);
        return footer!
    }
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(type(of: self)))")
        NotificationCenter.default.removeObserver(self)
        DDLogInfo("Running apis: \(indicator.runningApis.count)")
        for api in indicator.runningApis {
            DDLogInfo("Cancel api: \(api)")
            api.task?.cancel()
        }
    }

    // MARK: - Table view data source

//    public override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

}

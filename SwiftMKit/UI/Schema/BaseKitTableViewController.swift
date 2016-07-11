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
import MBProgressHUD
import ObjectiveC
import MJRefresh

public class BaseKitTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    public var params = Dictionary<String, AnyObject>() {
        didSet {
            for (key,value) in params {
                self.setValue(value, forKey: key)
            }
        }
    }
    public var completion: () -> Void = {}
    public var hud: HUDProtocol = MBHUDView()
    lazy public var indicator: IndicatorProtocol = {
        return TaskIndicator(hud: self.hud)
    }()
    
    public var viewModel: BaseKitTableViewModel? {
        get { return nil }
    }
    public var listViewModel: BaseKitTableViewModel! {
        get {
            return viewModel! as BaseKitTableViewModel
        }
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController
        if let bvc = vc as? BaseKitViewController {
            if let dict = sender as? NSDictionary {
                if var params = dict["params"] as? Dictionary<String, AnyObject> {
                    if params["hidesBottomBarWhenPushed"] == nil {
                        params["hidesBottomBarWhenPushed"] = true
                    }
                    bvc.params = params
                }
            }
        }
    }
    
    public func setupUI() {
        viewModel?.viewController = self
        
        if self.listViewType == .None || self.listViewType == .LoadMoreOnly {
            self.listView.mj_header = nil
        }
        if self.listViewType == .None || self.listViewType == .RefreshOnly {
            self.listView.mj_footer = nil
        }
        if self.listViewType == .Both || self.listViewType == .RefreshOnly {
            self.listView.mj_header = self.listViewHeaderWithRefreshingBlock {
                [weak self] in
                self?.listViewModel?.dataIndex = 0
                self?.listViewModel?.fetchData()
            }
        }
        if self.listViewType == .Both || self.listViewType == .LoadMoreOnly {
            self.listView.mj_footer = self.listViewFooterWithRefreshingBlock {
                [weak self] in
                self?.listViewModel?.dataIndex += 1
                self?.listViewModel?.fetchData()
            }
            self.listView.mj_footer.endRefreshingWithNoMoreData()
            if let footer = self.listView.mj_footer as? MJRefreshAutoStateFooter {
                footer.setTitle("", forState: .NoMoreData)
            }
        }
        
        setupNavigation()
        setupNotification()
        bindingData()
    }
    public func setupNotification() {
    }
    public func setupNavigation() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    public func bindingData() {
    }
    public func loadData() {
    }
    public func showEmptyView() {}
    public func hideEmptyView() {}
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer) {
            //只有二级以及以下的页面允许手势返回
            return self.navigationController?.viewControllers.count > 1
        }
        return true
    }
    
    public var listView: UIScrollView! {
        get {
            return nil
        }
    }
    public var listViewType: ListViewType {
        get {
            return .None
        }
    }
    
    public func listViewHeaderWithRefreshingBlock(refreshingBlock:MJRefreshComponentRefreshingBlock)->MJRefreshHeader{
        let header = MJRefreshNormalHeader(refreshingBlock:refreshingBlock);
        header.activityIndicatorViewStyle = .Gray
        return header
    }
    public func listViewFooterWithRefreshingBlock(refreshingBlock:MJRefreshComponentRefreshingBlock)->MJRefreshFooter{
        let footer = MJRefreshAutoStateFooter(refreshingBlock:refreshingBlock);
        return footer
    }
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
        NSNotificationCenter.defaultCenter().removeObserver(self)
        DDLogInfo("Running tasks: \(indicator.runningTasks.count)")
        for task in indicator.runningTasks {
            DDLogInfo("Cancel task: \(task)")
            task.cancel()
        }
    }

    // MARK: - Table view data source

    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

}

//HUD

extension BaseKitTableViewController {
    
    public func showTip(tip: String, completion : () -> Void = {}) {
        showTip(tip, view: self.view, hideAfterDelay: HUDConstant.HideTipAfterDelay, completion: completion)
    }
    public func showTip(tip: String, view: UIView, hideAfterDelay: NSTimeInterval = HUDConstant.HideTipAfterDelay, completion : () -> Void = {}) {
        self.hud.showHUDTextAddedTo(view, animated: true, text: tip, hideAfterDelay: hideAfterDelay, completion: completion)
    }
    public func showLoading(text: String = "") {
        showLoading(text, view: self.view)
    }
    public func showLoading(text: String, view: UIView) {
        self.hud.showHUDAddedTo(view, animated: true, text: text)
    }
    public func hideLoading() {
        hideLoading(self.view)
    }
    public func hideLoading(view: UIView) {
        self.hud.hideHUDForView(view, animated: true)
    }
}
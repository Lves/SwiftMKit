//
//  BaseListKitViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh
import Alamofire
import CocoaLumberjack

public enum ListViewType {
    case None
    case RefreshOnly
    case LoadMoreOnly
    case Both
}


public protocol ListViewProtocol {
    var listViewType: ListViewType { get }
    var listView: UIScrollView? { get }
    func listViewHeaderWithRefreshingBlock(refreshingBlock:MJRefreshComponentRefreshingBlock)->MJRefreshHeader
    func listViewFooterWithRefreshingBlock(refreshingBlock:MJRefreshComponentRefreshingBlock)->MJRefreshFooter
}

public class BaseListKitViewController: BaseKitViewController, ListViewProtocol {
    public var listViewModel: BaseListKitViewModel! {
        get {
            return viewModel as! BaseListKitViewModel
        }
    }
    public var listView: UIScrollView? {
        get {
            return nil
        }
    }
    public var listViewType: ListViewType {
        get {
            return .None
        }
    }
    
    lazy public var listIndicator: IndicatorProtocol = {
        return TaskIndicatorList(listView: self.listView, viewController: self)
    }()
    
    public func listViewHeaderWithRefreshingBlock(refreshingBlock:MJRefreshComponentRefreshingBlock)->MJRefreshHeader{
        let header = MJRefreshNormalHeader(refreshingBlock:refreshingBlock);
        header.activityIndicatorViewStyle = .Gray
        return header
    }
    public func listViewFooterWithRefreshingBlock(refreshingBlock:MJRefreshComponentRefreshingBlock)->MJRefreshFooter{
        let footer = MJRefreshAutoStateFooter(refreshingBlock:refreshingBlock);
        return footer
    }
    public override func setupUI() {
        super.setupUI()
        emptyView?.inView = self.listView!
        let _ = listIndicator
        if self.listViewType == .None || self.listViewType == .LoadMoreOnly {
            self.listView?.mj_header = nil
        }
        if self.listViewType == .None || self.listViewType == .RefreshOnly {
            self.listView?.mj_footer = nil
        }
        if self.listViewType == .Both || self.listViewType == .RefreshOnly {
            self.listView?.mj_header = self.listViewHeaderWithRefreshingBlock {
                [weak self] in
                self?.listViewModel?.dataIndex = 0
                self?.listViewModel?.fetchData()
                }
        }
        if self.listViewType == .Both || self.listViewType == .LoadMoreOnly {
            self.listView?.mj_footer = self.listViewFooterWithRefreshingBlock {
                [weak self] in
                self?.listViewModel?.dataIndex += 1
                self?.listViewModel?.fetchData()
                }
            self.listView?.mj_footer.endRefreshingWithNoMoreData()
            if let footer = self.listView?.mj_footer as? MJRefreshAutoStateFooter {
                footer.setTitle("", forState: .NoMoreData)
            }
        }
    }
    public func getCellWithTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell? {
        DDLogError("Need to implement the function of 'getCellWithTableView'")
        return nil
    }
    public func configureCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        DDLogError("Need to implement the function of 'configureCell'")
    }
    public func didSelectCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
    }
    public func objectByIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        let object = listViewModel.dataSource[indexPath.section][safe: indexPath.row]
        return object
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let sections = listViewModel.dataSource.count
        return sections
    }
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if listViewModel.dataSource.count > 0 {
            rows = listViewModel.dataSource[section].count
        }
        return rows
    }
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCellWithTableView(tableView, indexPath: indexPath)!
        if let object = objectByIndexPath(indexPath) {
            configureCell(cell, object: object, indexPath: indexPath)
        }
        return cell
    }
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = getCellWithTableView(tableView, indexPath: indexPath)!
        if let object = objectByIndexPath(indexPath) {
            didSelectCell(cell, object: object, indexPath: indexPath)
        }
    }
    
    public func endListRefresh() {
        if self.listViewModel.dataIndex == 0 {
            if self.listView?.mj_header != nil {
                self.listView?.mj_header.endRefreshing()
            }
        }else{
            if self.listView?.mj_footer != nil {
                if self.listView?.mj_footer.state == .Refreshing {
                    self.listView?.mj_footer.endRefreshing()
                }
            }
        }
    }

    public override func showTip(tip: String, view: UIView, offset: CGPoint, completion: () -> Void) {
        endListRefresh()
        super.showTip(tip, view: view, offset: offset, completion: completion)
    }
   
    deinit {
    }
}

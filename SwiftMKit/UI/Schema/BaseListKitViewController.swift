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
    case none
    case refreshOnly
    case loadMoreOnly
    case both
}


public protocol ListViewProtocol {
    var listViewType: ListViewType { get }
    var listView: UIScrollView? { get }
    func listViewHeaderWithRefreshingBlock(_ refreshingBlock:@escaping MJRefreshComponentRefreshingBlock)->MJRefreshHeader
    func listViewFooterWithRefreshingBlock(_ refreshingBlock:@escaping MJRefreshComponentRefreshingBlock)->MJRefreshFooter
}

open class BaseListKitViewController: BaseKitViewController, UITableViewDelegate, UITableViewDataSource, ListViewProtocol {
    open var listViewModel: BaseListKitViewModel! {
        get {
            return viewModel as! BaseListKitViewModel
        }
    }
    open var listView: UIScrollView? {
        get {
            return nil
        }
    }
    open var listViewType: ListViewType {
        get {
            return .none
        }
    }
    
    lazy open var listIndicator: IndicatorProtocol = {
        return TaskIndicatorList(listView: self.listView, viewController: self)
    }()
    
    open func listViewHeaderWithRefreshingBlock(_ refreshingBlock:@escaping MJRefreshComponentRefreshingBlock)->MJRefreshHeader{
        let header = MJRefreshNormalHeader(refreshingBlock:refreshingBlock);
        header?.activityIndicatorViewStyle = .gray
        return header!
    }
    open func listViewFooterWithRefreshingBlock(_ refreshingBlock:@escaping MJRefreshComponentRefreshingBlock)->MJRefreshFooter{
        let footer = MJRefreshAutoStateFooter(refreshingBlock:refreshingBlock);
        return footer!
    }
    open override func setupUI() {
        super.setupUI()
        emptyView?.inView = self.listView!
        let _ = listIndicator
        if self.listViewType == .none || self.listViewType == .loadMoreOnly {
            self.listView?.mj_header = nil
        }
        if self.listViewType == .none || self.listViewType == .refreshOnly {
            self.listView?.mj_footer = nil
        }
        if self.listViewType == .both || self.listViewType == .refreshOnly {
            self.listView?.mj_header = self.listViewHeaderWithRefreshingBlock {
                [weak self] in
                self?.listViewModel?.dataIndex = 0
                self?.listViewModel?.fetchData()
                }
        }
        if self.listViewType == .both || self.listViewType == .loadMoreOnly {
            self.listView?.mj_footer = self.listViewFooterWithRefreshingBlock {
                [weak self] in
                self?.listViewModel?.dataIndex += 1
                self?.listViewModel?.fetchData()
                }
            self.listView?.mj_footer.endRefreshingWithNoMoreData()
            if let footer = self.listView?.mj_footer as? MJRefreshAutoStateFooter {
                footer.setTitle("", for: .noMoreData)
            }
        }
    }
    open func getCellWithTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell? {
        DDLogError("Need to implement the function of 'getCellWithTableView'")
        return nil
    }
    open func configureCell(_ tableViewCell: UITableViewCell, object: AnyObject, indexPath: IndexPath) {
        DDLogError("Need to implement the function of 'configureCell'")
    }
    open func didSelectCell(_ tableViewCell: UITableViewCell, object: AnyObject, indexPath: IndexPath) {
    }
    open func objectByIndexPath(_ indexPath: IndexPath) -> AnyObject? {
        let object = listViewModel.dataSource[indexPath.section][safe: indexPath.row]
        return object
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        let sections = listViewModel.dataSource.count
        return sections
    }
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if listViewModel.dataSource.count > 0 {
            rows = listViewModel.dataSource[section].count
        }
        return rows
    }
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCellWithTableView(tableView, indexPath: indexPath)!
        if let object = objectByIndexPath(indexPath) {
            configureCell(cell, object: object, indexPath: indexPath)
        }
        return cell
    }
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = getCellWithTableView(tableView, indexPath: indexPath)!
        if let object = objectByIndexPath(indexPath) {
            didSelectCell(cell, object: object, indexPath: indexPath)
        }
    }
    
    open func endListRefresh() {
        if self.listViewModel.dataIndex == 0 {
            if self.listView?.mj_header != nil {
                self.listView?.mj_header.endRefreshing()
            }
        }else{
            if self.listView?.mj_footer != nil {
                if self.listView?.mj_footer.state == .refreshing {
                    self.listView?.mj_footer.endRefreshing()
                }
            }
        }
    }

    open override func showTip(_ tip: String, view: UIView, offset: CGPoint, completion: () -> Void) {
        endListRefresh()
        super.showTip(tip, view: view, offset: offset, completion: completion)
    }
   
    deinit {
    }
}

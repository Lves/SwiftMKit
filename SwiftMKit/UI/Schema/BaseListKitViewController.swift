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
    var listView: UIScrollView! { get }
    func listViewHeaderWithRefreshingBlock(refreshingBlock:MJRefreshComponentRefreshingBlock)->MJRefreshHeader
    func listViewFooterWithRefreshingBlock(refreshingBlock:MJRefreshComponentRefreshingBlock)->MJRefreshFooter
}

public class BaseListKitViewController: BaseKitViewController, ListViewProtocol {
    public var listViewModel: BaseListKitViewModel! {
        get {
            return viewModel as! BaseListKitViewModel
        }
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
    lazy public var listIndicator: IndicatorListProtocol = {
        return TaskIndicatorList(listView: self.listView, viewModel: self.listViewModel)
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
    }
    
   
    deinit {
    }
}

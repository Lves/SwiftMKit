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
import ReactiveCocoa

public enum ListViewType {
    case ListViewTypeNone
    case ListViewTypeRefreshOnly
    case ListViewTypeLoadMoreOnly
    case ListViewTypeBoth
}

public class BaseListKitViewController: BaseKitViewController {
    public var listView: UIScrollView! {
        get {
            return nil
        }
    }
    public var listViewModel: BaseListKitViewModel? {
        get {
            return viewModel as? BaseListKitViewModel
        }
    }
    public func listViewHeaderWithRefreshingBlock(refreshingBlock:MJRefreshComponentRefreshingBlock)->MJRefreshHeader{
        let header = MJRefreshNormalHeader(refreshingBlock:refreshingBlock);
        header.activityIndicatorViewStyle = .Gray
        return header
    }
    public func listViewFooterWithRefreshingBlock(refreshingBlock:MJRefreshComponentRefreshingBlock)->MJRefreshFooter{
        let footer = MJRefreshAutoFooter(refreshingBlock:refreshingBlock);
        return footer
    }
    public override func setupUI() {
        super.setupUI()
        if self.listViewType == .ListViewTypeNone || self.listViewType == .ListViewTypeLoadMoreOnly {
            self.listView.mj_header = nil
        }
        if self.listViewType == .ListViewTypeNone || self.listViewType == .ListViewTypeRefreshOnly {
            self.listView.mj_footer = nil
        }
        if self.listViewType == .ListViewTypeBoth || self.listViewType == .ListViewTypeRefreshOnly {
            self.listView.mj_header = self.listViewHeaderWithRefreshingBlock {
                [unowned self] in
                self.refreshData()
                }
        }
        if self.listViewType == .ListViewTypeBoth || self.listViewType == .ListViewTypeLoadMoreOnly {
            self.listView.mj_footer = self.listViewFooterWithRefreshingBlock {
                [unowned self] in
                self.loadMoreData()
                }
        }
    }
    public func refreshData() {}
    public func loadMoreData() {}
    public var listViewType:ListViewType {
        get {
            return .ListViewTypeNone
        }
    }
}
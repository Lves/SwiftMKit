//
//  BaseListKitViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import MJRefresh

public class BaseListKitViewModel: BaseKitViewModel {
    private struct InnerConstant {
        static let StringNoMoreDataTip = "数据已全部加载完毕"
    }
    
    public var listViewController: BaseListKitViewController! {
        get {
            return viewController as! BaseListKitViewController
        }
    }
    var dataSource:Array<AnyObject> = Array<AnyObject>() {
        didSet {
            if self.viewController == nil {
                return
            }
            if self.listViewController.listViewType == .RefreshOnly ||
               self.listViewController.listViewType == .None {
                return
            }
            var noMoreDataTip = InnerConstant.StringNoMoreDataTip
            let count: UInt = UInt(dataSource.count)
            if count == 0 {
                self.viewController.showEmptyView()
                self.listViewController.listView.mj_footer.endRefreshingWithNoMoreData()
                noMoreDataTip = ""
                return
            }
            if oldValue.count == 0 {
                self.viewController.hideEmptyView()
                self.listViewController.listView.mj_footer.resetNoMoreData()
            }
            if count < listLoadNumber {
                self.listViewController.listView.mj_footer.endRefreshingWithNoMoreData()
                noMoreDataTip = ""
            }else if count % listLoadNumber > 0 || count >= listMaxNumber {
                self.listViewController.listView.mj_footer.endRefreshingWithNoMoreData()
            }
            if let footer = self.listViewController.listView.mj_footer as? MJRefreshAutoStateFooter {
                footer.setTitle(noMoreDataTip, forState: .NoMoreData)
            }
        }
    }
    var dataIndex: UInt = 0
    let listLoadNumber: UInt = 20
    let listMaxNumber: UInt = UInt.max
    
    public func updateDataSource(newData: Array<AnyObject>) {
        if dataIndex == 0 {
            dataSource = newData
        } else {
            dataSource += newData
        }
        let tableView = self.listViewController?.listView as? UITableView
        tableView?.reloadData()
    }
}

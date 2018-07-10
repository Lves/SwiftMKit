//
//  BaseListKitViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import MJRefresh
import CocoaLumberjack

open class BaseListKitViewModel: BaseKitViewModel {
    fileprivate struct InnerConstant {
        static let StringNoMoreDataTip = "数据已全部加载完毕"
    }
    override init() {
        super.init()
    }
    open var listViewController: BaseListKitViewController! {
        get {
            if let viewController = viewController {
                return viewController as! BaseListKitViewController
            }
            return BaseListKitViewController()
        }
    }
    open var taskListIndicator: Indicator {
        get { return self.listViewController.taskListIndicator }
    }
    var dataArray:[Any] {
        get {
            if dataSource.first == nil {
                dataSource.append([Any]())
            }
            return dataSource.first!
        }
        set {
            dataSource = [newValue]
        }
    }
    fileprivate var isDataSourceChanged: Bool = false
    var dataSource:[[Any]] = [[Any]]() {
        didSet {
            if self.viewController == nil {
                return
            }
            var count: UInt = UInt(dataSource.count)
            if count == 1 {
                count = UInt(dataSource.first?.count ?? 0)
            }
            var oldCount: UInt = UInt(oldValue.count)
            if oldCount == 1 {
                oldCount = UInt(oldValue.first?.count ?? 0)
            }
            //是否是第一次赋默认值
            if !isDataSourceChanged && count == 0 {
                return
            }
            if count == 0 {
                self.viewController.emptyView?.show()
            } else if oldCount == 0 {
                self.viewController.emptyView?.hide()
            }
            if self.listViewController.listViewType == .refreshOnly ||
               self.listViewController.listViewType == .none {
                return
            }
            var noMoreDataTip = InnerConstant.StringNoMoreDataTip
            if count == 0 {
                self.listViewController.listView?.mj_footer.endRefreshingWithNoMoreData()
                noMoreDataTip = ""
                if let footer = self.listViewController.listView?.mj_footer as? MJRefreshAutoStateFooter {
                    footer.setTitle(noMoreDataTip, for: .noMoreData)
                }
                return
            }
            if count < listLoadNumber {
                self.listViewController.listView?.mj_footer.endRefreshingWithNoMoreData()
                noMoreDataTip = ""
            }else if count % listLoadNumber > 0 || count >= listMaxNumber || (count == oldCount && dataIndex > 0) {
                self.listViewController.listView?.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self.listViewController.listView?.mj_footer.resetNoMoreData()
            }
            if let footer = self.listViewController.listView?.mj_footer as? MJRefreshAutoStateFooter {
                footer.setTitle(noMoreDataTip, for: .noMoreData)
            }
        }
    }
    var dataIndex: UInt = 0
    var listLoadNumber: UInt { get { return 20 } }
    var listMaxNumber: UInt { get { return UInt.max } }
    
    open func updateDataArray(_ newData: [Any]?) {
        isDataSourceChanged = true
        if let data = newData {
            if dataIndex == 0 {
                dataArray = data
            } else {
                dataArray += data
            }
        } else {
            if dataIndex == 0 {
                dataArray = []
            }
        }
        if let table = self.listViewController.listView as? UITableView {
            table.reloadData()
        } else if let collect = self.listViewController.listView as? UICollectionView {
            collect.reloadData()
        }
    }
    open func updateDataSource(_ newData: [[Any]]?) {
        isDataSourceChanged = true
        dataSource = newData ?? [[Any]]()
        if let table = self.listViewController.listView as? UITableView {
            table.reloadData()
        } else if let collect = self.listViewController.listView as? UICollectionView {
            collect.reloadData()
        }
    }
}

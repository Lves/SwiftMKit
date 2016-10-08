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

public class BaseListKitViewModel: BaseKitViewModel {
    private struct InnerConstant {
        static let StringNoMoreDataTip = "数据已全部加载完毕"
    }
    override init() {
        super.init()
    }
    public var listViewController: BaseListKitViewController! {
        get {
            return viewController as! BaseListKitViewController
        }
    }
    public var listIndicator: IndicatorListProtocol {
        get { return self.listViewController.listIndicator }
    }
    var dataArray:[AnyObject] {
        get {
            if dataSource.first == nil {
                dataSource.append([AnyObject]())
            }
            return dataSource.first!
        }
        set {
            dataSource = [newValue]
        }
    }
    private var isDataSourceChanged: Bool = false
    var dataSource:[[AnyObject]] = [[AnyObject]]() {
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
                self.viewController.showEmptyView()
            } else if oldCount == 0 {
                self.viewController.hideEmptyView()
            }
            if self.listViewController.listViewType == .RefreshOnly ||
               self.listViewController.listViewType == .None {
                return
            }
            var noMoreDataTip = InnerConstant.StringNoMoreDataTip
            if count == 0 {
                self.listViewController.listView?.mj_footer.endRefreshingWithNoMoreData()
                noMoreDataTip = ""
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
                footer.setTitle(noMoreDataTip, forState: .NoMoreData)
            }
        }
    }
    var dataIndex: UInt = 0
    var listLoadNumber: UInt { get { return 20 } }
    var listMaxNumber: UInt { get { return UInt.max } }
    
    public func updateDataArray(newData: [AnyObject]?) {
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
    public func updateDataSource(newData: [[AnyObject]]?) {
        isDataSourceChanged = true
        dataSource = newData ?? [[AnyObject]]()
        if let table = self.listViewController.listView as? UITableView {
            table.reloadData()
        } else if let collect = self.listViewController.listView as? UICollectionView {
            collect.reloadData()
        }
    }
}

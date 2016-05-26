//
//  BaseKitTableViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/13/16.
//  Copyright © 2016 cdts. All rights reserved.
//


import UIKit
import CocoaLumberjack
import Alamofire
import MJRefresh

public class BaseKitTableViewModel: NSObject {
    public weak var viewController: BaseKitTableViewController!
    public var hud: HUDProtocol {
        get { return self.viewController.hud }
    }
    public var indicator: IndicatorProtocol {
        get { return self.viewController.indicator }
    }
    public var view: UIView {
        get { return self.viewController.view }
    }
    public func fetchData() {
    }
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
    }
    
    
    private struct InnerConstant {
        static let StringNoMoreDataTip = "数据已全部加载完毕"
    }
    
    public var listViewController: BaseKitTableViewController! {
        get {
            return viewController as BaseKitTableViewController
        }
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
    var dataSource:[[AnyObject]] = [[AnyObject]]() {
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
    
    public func updateDataArray(newData: [AnyObject]?) {
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
        dataSource = newData ?? [[AnyObject]]()
        if let table = self.listViewController.listView as? UITableView {
            table.reloadData()
        } else if let collect = self.listViewController.listView as? UICollectionView {
            collect.reloadData()
        }
    }
}

//HUD

extension BaseKitTableViewModel {
    
    public func showTip(tip: String, completion : () -> Void = {}) {
        viewController.showTip(tip, view: viewController.view, hideAfterDelay: HUDConstant.HideTipAfterDelay, completion: completion)
    }
    public func showTip(tip: String, view: UIView, hideAfterDelay: NSTimeInterval = HUDConstant.HideTipAfterDelay, completion : () -> Void = {}) {
        viewController.showTip(tip, view: view, hideAfterDelay: hideAfterDelay, completion: completion)
    }
    public func showLoading(text: String = "") {
        viewController.showLoading(text)
    }
    public func showLoading(text: String, view: UIView) {
        viewController.showLoading(text, view: view)
    }
    public func hideLoading() {
        viewController.hideLoading()
    }
    public func hideLoading(view: UIView) {
        viewController.hideLoading(view)
    }
    
}
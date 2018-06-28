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

open class BaseKitTableViewModel: NSObject {
    open weak var viewController: BaseKitTableViewController!
    open var hud: HudProtocol {
        get { return self.viewController.hud }
    }
    open var indicator: IndicatorProtocol {
        get { return self.viewController.indicator }
    }
    open var view: UIView {
        get { return self.viewController.view }
    }
    open func fetchData() {
    }
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(type(of: self)))")
    }
    
    
    fileprivate struct InnerConstant {
        static let StringNoMoreDataTip = "数据已全部加载完毕"
    }
    
    open var listViewController: BaseKitTableViewController! {
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
            if self.listViewController.listViewType == .refreshOnly ||
                self.listViewController.listViewType == .none {
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
                footer.setTitle(noMoreDataTip, for: .noMoreData)
            }
        }
    }
    var dataIndex: UInt = 0
    let listLoadNumber: UInt = 20
    let listMaxNumber: UInt = UInt.max
    
    open func updateDataArray(_ newData: [AnyObject]?) {
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
    open func updateDataSource(_ newData: [[AnyObject]]?) {
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
    
    public func showTip(_ tip: String, completion : @escaping () -> Void = {}) {
        showTip(tip, view: self.view, completion: completion)
    }
    public func showTip(_ tip: String, image: UIImage?, completion : @escaping () -> Void = {}) {
        MBHud.shared.showTip(inView: view, text: tip, image: image, animated: true, completion: completion)
    }
    public func showTip(_ tip: String, view: UIView, offset: CGPoint = CGPoint.zero, completion : @escaping () -> Void = {}) {
        MBHud.shared.showTip(inView: view, text: tip, offset: offset, animated: true, completion: completion)
    }
    public func showLoading(_ text: String = "") {
        viewController.showIndicator(inView: viewController.view, text: text)
    }
    public func showLoading(_ text: String, view: UIView) {
        viewController.showIndicator(inView: view, text: text)
    }
    public func hideLoading() {
        viewController.hideLoading()
    }
    public func hideLoading(_ view: UIView) {
        viewController.hideLoading(view)
    }
    
}

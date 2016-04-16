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

public enum ListViewType {
    case ListViewTypeNone
    case ListViewTypeRefreshOnly
    case ListViewTypeLoadMoreOnly
    case ListViewTypeBoth
}

public protocol IndicatorListProtocol: IndicatorProtocol {
    func setIndicatorListState(task: NSURLSessionTask?)
}

public protocol ListViewProtocol {
    var listViewType: ListViewType { get }
    var listView: UIScrollView! { get }
    func listViewHeaderWithRefreshingBlock(refreshingBlock:MJRefreshComponentRefreshingBlock)->MJRefreshHeader
    func listViewFooterWithRefreshingBlock(refreshingBlock:MJRefreshComponentRefreshingBlock)->MJRefreshFooter
}

public class BaseListKitViewController: BaseKitViewController, ListViewProtocol, IndicatorListProtocol {
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
            return .ListViewTypeNone
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
                self.listViewModel?.dataIndex = 0
                self.listViewModel?.fetchData()
                }
        }
        if self.listViewType == .ListViewTypeBoth || self.listViewType == .ListViewTypeLoadMoreOnly {
            self.listView.mj_footer = self.listViewFooterWithRefreshingBlock {
                [unowned self] in
                self.listViewModel?.dataIndex += 1
                self.listViewModel?.fetchData()
                }
        }
    }
    
    public func setIndicatorListState(task: NSURLSessionTask?){
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: Notifications.Task.DidResume, object: nil)
        notificationCenter.removeObserver(self, name: Notifications.Task.DidSuspend, object: nil)
        notificationCenter.removeObserver(self, name: Notifications.Task.DidComplete, object: nil)
        if let networkTask = task {
            if networkTask.state == .Running {
                notificationCenter.addObserver(self, selector: #selector(BaseListKitViewController.task_list_resume(_:)), name: Notifications.Task.DidResume, object: task)
                notificationCenter.addObserver(self, selector: #selector(BaseListKitViewController.task_list_suspend(_:)), name: Notifications.Task.DidSuspend, object: task)
                notificationCenter.addObserver(self, selector: #selector(BaseListKitViewController.task_list_end(_:)), name: Notifications.Task.DidComplete, object: task)
            } else {
                let notify = NSNotification(name: "", object: task)
                task_list_end(notify)
            }
        }
    }
    
    func task_list_resume(notify:NSNotification) {
        UIApplication.sharedApplication().showNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            self.viewModel.runningApis.append(task)
        }
    }
    func task_list_suspend(notify:NSNotification) {
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        dispatch_async(dispatch_get_main_queue()) {
            if self.listViewModel.dataIndex == 0 {
                self.listView.mj_header.endRefreshing()
            }else{
                self.listView.mj_footer.endRefreshing()
            }
        }
    }
    func task_list_end(notify:NSNotification) {
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            if let index = self.viewModel.runningApis.indexOf(task) {
                self.viewModel.runningApis.removeAtIndex(index)
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
            if self.listViewModel.dataIndex == 0 {
                self.listView.mj_header.endRefreshing()
            }else{
                self.listView.mj_footer.endRefreshing()
            }
        }
    }
}
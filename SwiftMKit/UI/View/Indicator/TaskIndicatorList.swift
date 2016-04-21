//
//  ListTaskIndicator.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import ObjectiveC
import CocoaLumberjack
import MJRefresh

public class TaskIndicatorList: NSObject, IndicatorListProtocol {
    private weak var listView: UIScrollView?
    private weak var viewModel: BaseListKitViewModel?
    lazy private var runningTasks = [NSURLSessionTask]()
    
    init(listView: UIScrollView, viewModel: BaseListKitViewModel){
        self.listView = listView
        self.viewModel = viewModel
        super.init()
    }
    public func bindTaskForList(task: NSURLSessionTask){
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: Notifications.Task.DidResume, object: nil)
        notificationCenter.removeObserver(self, name: Notifications.Task.DidSuspend, object: nil)
        notificationCenter.removeObserver(self, name: Notifications.Task.DidCancel, object: nil)
        notificationCenter.removeObserver(self, name: Notifications.Task.DidComplete, object: nil)
        if task.state == .Running {
            notificationCenter.addObserver(self, selector: #selector(TaskIndicatorList.task_list_resume(_:)), name: Notifications.Task.DidResume, object: task)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicatorList.task_list_suspend(_:)), name: Notifications.Task.DidSuspend, object: task)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicatorList.task_list_cancel(_:)), name: Notifications.Task.DidCancel, object: task)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicatorList.task_list_end(_:)), name: Notifications.Task.DidComplete, object: task)
            let notify = NSNotification(name: "", object: task)
            self.task_list_resume(notify)
        } else {
            let notify = NSNotification(name: "", object: task)
            self.task_list_end(notify)
        }
    }
    
    
    @objc func task_list_resume(notify:NSNotification) {
        DDLogInfo("List Task resume")
        UIApplication.sharedApplication().showNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            self.runningTasks.append(task)
        }
    }
    @objc func task_list_suspend(notify:NSNotification) {
        DDLogInfo("List Task suspend")
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        Async.main {
            if self.viewModel?.dataIndex == 0 {
                self.listView?.mj_header.endRefreshing()
            }else{
                self.listView?.mj_footer.endRefreshing()
            }
        }
    }
    @objc func task_list_cancel(notify:NSNotification) {
        DDLogInfo("List Task cancel")
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        Async.main {
            if self.viewModel?.dataIndex == 0 {
                self.listView?.mj_header.endRefreshing()
            }else{
                self.listView?.mj_footer.endRefreshing()
            }
        }
    }
    @objc func task_list_end(notify:NSNotification) {
        DDLogInfo("List Task complete")
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            if let index = self.runningTasks.indexOf(task) {
                self.runningTasks.removeAtIndex(index)
            }
        }
        Async.main {
            if self.viewModel?.dataIndex == 0 {
                self.listView?.mj_header.endRefreshing()
            }else{
                self.listView?.mj_footer.endRefreshing()
            }
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
        DDLogInfo("Running list tasks: \(runningTasks.count)")
        for task in runningTasks {
            DDLogInfo("Cancel list task: \(task)")
            task.cancel()
            let info = ["task": task] as NSDictionary
            let notify = NSNotification(name: "", object: info)
            self.task_list_cancel(notify)
        }
    }
    
}
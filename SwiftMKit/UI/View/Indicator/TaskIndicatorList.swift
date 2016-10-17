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

public class TaskIndicatorList: NSObject, IndicatorProtocol {
    private weak var listView: UIScrollView?
    private weak var viewController: BaseListKitViewController?
    lazy public var runningTasks = [NSURLSessionTask]()
    
    public init(listView: UIScrollView?, viewController: BaseListKitViewController){
        self.listView = listView
        self.viewController = viewController
        super.init()
    }
    public func bindTask(task: NSURLSessionTask, view: UIView?, text: String?) {
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
        DDLogVerbose("List Task resume")
        
        if let task = notify.object as? NSURLSessionTask {
            if !self.runningTasks.contains(task) {
                UIApplication.sharedApplication().showNetworkActivityIndicator()
                self.runningTasks.append(task)
            }
        }
    }
    @objc func task_list_suspend(notify:NSNotification) {
        DDLogVerbose("List Task suspend")
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        Async.main { [weak self] in
            self?.viewController?.endListRefresh()
        }
    }
    @objc func task_list_cancel(notify:NSNotification) {
        DDLogVerbose("List Task cancel")
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        Async.main { [weak self] in
            self?.viewController?.endListRefresh()
        }
    }
    @objc func task_list_end(notify:NSNotification) {
        DDLogVerbose("List Task complete")
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            if let index = self.runningTasks.indexOf(task) {
                self.runningTasks.removeAtIndex(index)
            }
        }
        Async.main { [weak self] in
            self?.viewController?.endListRefresh()
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if runningTasks.count > 0 {
            DDLogVerbose("Running list tasks: \(runningTasks.count)")
        }
        for task in runningTasks {
            DDLogVerbose("Cancel list task: \(task)")
            let info = ["task": task] as NSDictionary
            let notify = NSNotification(name: "", object: info)
            self.task_list_cancel(notify)
            task.cancel()
        }
    }
    
}
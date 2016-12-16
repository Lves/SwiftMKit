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

open class TaskIndicatorList: NSObject, IndicatorProtocol {
    fileprivate weak var listView: UIScrollView?
    fileprivate weak var viewController: BaseListKitViewController?
    lazy open var runningTasks = [URLSessionTask]()
    
    public init(listView: UIScrollView?, viewController: BaseListKitViewController){
        self.listView = listView
        self.viewController = viewController
        super.init()
    }
    open func bindTask(_ task: URLSessionTask, view: UIView?, text: String?) {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: Notification.Name.Task.DidResume, object: nil)
        notificationCenter.removeObserver(self, name: Notification.Name.Task.DidSuspend, object: nil)
        notificationCenter.removeObserver(self, name: Notification.Name.Task.DidCancel, object: nil)
        notificationCenter.removeObserver(self, name: Notification.Name.Task.DidComplete, object: nil)
        if task.state == .running {
            notificationCenter.addObserver(self, selector: #selector(TaskIndicatorList.task_list_resume(_:)), name: Notification.Name.Task.DidResume, object: task)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicatorList.task_list_suspend(_:)), name: Notification.Name.Task.DidSuspend, object: task)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicatorList.task_list_cancel(_:)), name: Notification.Name.Task.DidCancel, object: task)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicatorList.task_list_end(_:)), name: Notification.Name.Task.DidComplete, object: task)
            let notify = Notification(name: Notification.Name(rawValue: ""), object: task)
            self.task_list_resume(notify)
        } else {
            let notify = Notification(name: Notification.Name(rawValue: ""), object: task)
            self.task_list_end(notify)
        }
    }
    
    
    @objc func task_list_resume(_ notify:Notification) {
        DDLogVerbose("List Task resume")
        
        if let task = notify.object as? URLSessionTask {
            if !self.runningTasks.contains(task) {
                UIApplication.shared.showNetworkActivityIndicator()
                self.runningTasks.append(task)
            }
        }
    }
    @objc func task_list_suspend(_ notify:Notification) {
        DDLogVerbose("List Task suspend")
        UIApplication.shared.hideNetworkActivityIndicator()
        let _ = Async.main { [weak self] in
            self?.viewController?.endListRefresh()
        }
    }
    @objc func task_list_cancel(_ notify:Notification) {
        DDLogVerbose("List Task cancel")
        UIApplication.shared.hideNetworkActivityIndicator()
        let _ = Async.main { [weak self] in
            self?.viewController?.endListRefresh()
        }
    }
    @objc func task_list_end(_ notify:Notification) {
        DDLogVerbose("List Task complete")
        UIApplication.shared.hideNetworkActivityIndicator()
        if let task = notify.object as? URLSessionTask {
            if let index = self.runningTasks.index(of: task) {
                self.runningTasks.remove(at: index)
            }
        }
        let _ = Async.main { [weak self] in
            self?.viewController?.endListRefresh()
        }
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
        if runningTasks.count > 0 {
            DDLogVerbose("Running list tasks: \(runningTasks.count)")
        }
        for task in runningTasks {
            DDLogVerbose("Cancel list task: \(task)")
            UIApplication.shared.hideNetworkActivityIndicator()
            task.cancel()
        }
    }
    
}

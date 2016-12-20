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
    private weak var listView: UIScrollView?
    private weak var viewController: BaseListKitViewController?
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
            notificationCenter.addObserver(self, selector: #selector(TaskIndicatorList.task_list_resume), name: Notification.Name.Task.DidResume, object: nil)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicatorList.task_list_suspend), name: Notification.Name.Task.DidSuspend, object: nil)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicatorList.task_list_cancel), name: Notification.Name.Task.DidCancel, object: nil)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicatorList.task_list_end), name: Notification.Name.Task.DidComplete, object: nil)
            var notify = Notification(name: Notification.Name(rawValue: ""), object: nil)
            notify.userInfo = [Notification.Key.Task: task]
            self.task_list_resume(notify: notify)
        } else {
            var notify = Notification(name: Notification.Name(rawValue: ""), object: nil)
            notify.userInfo = [Notification.Key.Task: task]
            self.task_list_end(notify: notify)
        }
    }
    
    
    func task_list_resume(notify:Notification) {
        DDLogVerbose("List Task resume")
        
        if let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask {
            if !self.runningTasks.contains(task) {
                UIApplication.shared.showNetworkActivityIndicator()
                self.runningTasks.append(task)
            }
        }
    }
    func task_list_suspend(notify:Notification) {
        DDLogVerbose("List Task suspend")
        UIApplication.shared.hideNetworkActivityIndicator()
        let _ = Async.main { [weak self] in
            self?.viewController?.endListRefresh()
        }
    }
    func task_list_cancel(notify:Notification) {
        DDLogVerbose("List Task cancel")
        UIApplication.shared.hideNetworkActivityIndicator()
        let _ = Async.main { [weak self] in
            self?.viewController?.endListRefresh()
        }
    }
    func task_list_end(notify:Notification) {
        DDLogVerbose("List Task complete")
        UIApplication.shared.hideNetworkActivityIndicator()
        if let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask {
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

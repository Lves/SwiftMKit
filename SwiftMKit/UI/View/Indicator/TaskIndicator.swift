//
//  TaskIndicator.swift
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

public class TaskIndicator: NSObject, IndicatorProtocol {
    private weak var hud: HUDProtocol?
    lazy private var runningTasks = [NSURLSessionTask]()
    
    init(hud: HUDProtocol){
        self.hud = hud
        super.init()
    }
    public func bindTask(task: NSURLSessionTask, view: UIView, text: String?){
        task.indicatorView = view
        task.indicatorText = text ?? ""
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: Notifications.Task.DidResume, object: nil)
        notificationCenter.removeObserver(self, name: Notifications.Task.DidSuspend, object: nil)
        notificationCenter.removeObserver(self, name: Notifications.Task.DidCancel, object: nil)
        notificationCenter.removeObserver(self, name: Notifications.Task.DidComplete, object: nil)
        if task.state == .Running {
            notificationCenter.addObserver(self, selector: #selector(TaskIndicator.task_resume(_:)), name: Notifications.Task.DidResume, object: task)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicator.task_suspend(_:)), name: Notifications.Task.DidSuspend, object: task)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicator.task_cancel(_:)), name: Notifications.Task.DidCancel, object: task)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicator.task_end(_:)), name: Notifications.Task.DidComplete, object: task)
            let notify = NSNotification(name: "", object: task)
            self.task_resume(notify)
        } else {
            let notify = NSNotification(name: "", object: task)
            self.task_end(notify)
        }
    }
    
    @objc func task_resume(notify:NSNotification) {
        DDLogVerbose("Task resume")
        UIApplication.sharedApplication().showNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            self.runningTasks.append(task)
            Async.main {
                self.hud?.showHUDAddedTo(task.indicatorView, animated: true, text: task.indicatorText)
            }
        }
    }
    @objc func task_suspend(notify:NSNotification) {
        DDLogVerbose("Task suspend")
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            Async.main {
                self.hud?.hideHUDForView(task.indicatorView, animated: true)
            }
        }
    }
    @objc func task_cancel(notify:NSNotification) {
        DDLogVerbose("Task cancel")
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            Async.main {
                self.hud?.hideHUDForView(task.indicatorView, animated: true)
            }
        }
    }
    @objc func task_end(notify:NSNotification) {
        DDLogVerbose("Task complete")
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            if let index = self.runningTasks.indexOf(task) {
                self.runningTasks.removeAtIndex(index)
            }
            Async.main {
                self.hud?.hideHUDForView(task.indicatorView, animated: true)
            }
        }
    }

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
        DDLogVerbose("Running tasks: \(runningTasks.count)")
        for task in runningTasks {
            DDLogVerbose("Cancel task: \(task)")
            task.cancel()
            let notify = NSNotification(name: "", object: task)
            self.task_cancel(notify)
        }
    }

}
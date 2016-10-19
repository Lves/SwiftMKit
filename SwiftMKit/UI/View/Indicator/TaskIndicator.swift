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
    lazy public var runningTasks = [NSURLSessionTask]()
    
    private var waitForHide : Bool = false
    
    init(hud: HUDProtocol){
        self.hud = hud
        super.init()
    }
    public func bindTask(task: NSURLSessionTask, view: UIView?, text: String?){
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
        
        if let task = notify.object as? NSURLSessionTask {
            if !self.runningTasks.contains(task) {
                UIApplication.sharedApplication().showNetworkActivityIndicator()
                self.runningTasks.append(task)
            }
            if let view = task.indicatorView {
                if !waitForHide {
                    Async.main {
                        self.hud?.showHUDAddedTo(view, animated: false, text: task.indicatorText)
                    }
                } else {
                    self.hud?.changeHUDText(task.indicatorText)
                }
                waitForHide = false
            }
        }
    }
    @objc func task_suspend(notify:NSNotification) {
        DDLogVerbose("Task suspend")
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            if let index = self.runningTasks.indexOf(task) {
                self.runningTasks.removeAtIndex(index)
            }
            if let view = task.indicatorView {
                waitForHide = true
                
                Async.main (after: 0.5){
                    if self.waitForHide {
                        self.hud?.hideIndicatorHUDForView(view, animated: false)
                    }
                    self.waitForHide = false
                }
            }
        }
    }
    @objc func task_cancel(notify:NSNotification) {
        DDLogVerbose("Task cancel")
        UIApplication.sharedApplication().hideNetworkActivityIndicator()
        if let task = notify.object as? NSURLSessionTask {
            if let index = self.runningTasks.indexOf(task) {
                self.runningTasks.removeAtIndex(index)
            }
            if let view = task.indicatorView {
                waitForHide = true
                
                Async.main (after: 0.5){
                    if self.waitForHide {
                        self.hud?.hideIndicatorHUDForView(view, animated: false)
                    }
                    self.waitForHide = false
                }
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
            if let view = task.indicatorView {
                waitForHide = true
                
                Async.main (after: 0.5){
                    if self.waitForHide {
                        self.hud?.hideIndicatorHUDForView(view, animated: false)
                    }
                    self.waitForHide = false
                }
            }
        }
    }

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if runningTasks.count > 0 {
            DDLogVerbose("Running list tasks: \(runningTasks.count)")
        }
        for task in runningTasks {
            DDLogVerbose("Cancel task: \(task)")
            UIApplication.sharedApplication().hideNetworkActivityIndicator()
            task.cancel()
        }
    }

}
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

open class TaskIndicator: NSObject, IndicatorProtocol {
    fileprivate weak var hud: HUDProtocol?
    lazy open var runningTasks = [URLSessionTask]()
    
    fileprivate var waitForHide : Bool = false
    
    init(hud: HUDProtocol){
        self.hud = hud
        super.init()
    }
    open func bindTask(_ task: URLSessionTask, view: UIView?, text: String?){
        task.indicatorView = view
        task.indicatorText = text ?? ""
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: Notification.Name.Task.DidResume, object: nil)
        notificationCenter.removeObserver(self, name: Notification.Name.Task.DidSuspend, object: nil)
        notificationCenter.removeObserver(self, name: Notification.Name.Task.DidCancel, object: nil)
        notificationCenter.removeObserver(self, name: Notification.Name.Task.DidComplete, object: nil)
        if task.state == .running {
            notificationCenter.addObserver(self, selector: #selector(TaskIndicator.task_resume(_:)), name: Notification.Name.Task.DidResume, object: task)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicator.task_suspend(_:)), name: Notification.Name.Task.DidSuspend, object: task)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicator.task_cancel(_:)), name: Notification.Name.Task.DidCancel, object: task)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicator.task_end(_:)), name: Notification.Name.Task.DidComplete, object: task)
            let notify = Notification(name: Notification.Name(rawValue: ""), object: task)
            self.task_resume(notify)
        } else {
            let notify = Notification(name: Notification.Name(rawValue: ""), object: task)
            self.task_end(notify)
        }
    }
    
    @objc func task_resume(_ notify:Notification) {
        DDLogVerbose("Task resume")
        
        if let task = notify.object as? URLSessionTask {
            if !self.runningTasks.contains(task) {
                UIApplication.shared.showNetworkActivityIndicator()
                self.runningTasks.append(task)
            }
            if let view = task.indicatorView {
                if !waitForHide {
                    let _ = Async.main {
                        self.hud?.showHUDAddedTo(view, animated: false, text: task.indicatorText)
                    }
                } else {
                    self.hud?.changeHUDText(task.indicatorText)
                }
                waitForHide = false
            }
        }
    }
    @objc func task_suspend(_ notify:Notification) {
        DDLogVerbose("Task suspend")
        UIApplication.shared.hideNetworkActivityIndicator()
        if let task = notify.object as? URLSessionTask {
            if let index = self.runningTasks.index(of: task) {
                self.runningTasks.remove(at: index)
            }
            if let view = task.indicatorView {
                waitForHide = true
                
                let _ = Async.main (after: 0.5){
                    if self.waitForHide {
                        let _ = self.hud?.hideIndicatorHUDForView(view, animated: false)
                    }
                    self.waitForHide = false
                }
            }
        }
    }
    @objc func task_cancel(_ notify:Notification) {
        DDLogVerbose("Task cancel")
        UIApplication.shared.hideNetworkActivityIndicator()
        if let task = notify.object as? URLSessionTask {
            if let index = self.runningTasks.index(of: task) {
                self.runningTasks.remove(at: index)
            }
            if let view = task.indicatorView {
                waitForHide = true
                
                let _ = Async.main (after: 0.5){
                    if self.waitForHide {
                        let _ = self.hud?.hideIndicatorHUDForView(view, animated: false)
                    }
                    self.waitForHide = false
                }
            }
        }
    }
    @objc func task_end(_ notify:Notification) {
        DDLogVerbose("Task complete")
        UIApplication.shared.hideNetworkActivityIndicator()
        if let task = notify.object as? URLSessionTask {
            if let index = self.runningTasks.index(of: task) {
                self.runningTasks.remove(at: index)
            }
            if let view = task.indicatorView {
                waitForHide = true
                
                let _ = Async.main (after: 0.5){
                    if self.waitForHide {
                        let _ = self.hud?.hideIndicatorHUDForView(view, animated: false)
                    }
                    self.waitForHide = false
                }
            }
        }
    }

    deinit{
        NotificationCenter.default.removeObserver(self)
        if runningTasks.count > 0 {
            DDLogVerbose("Running list tasks: \(runningTasks.count)")
        }
        for task in runningTasks {
            DDLogVerbose("Cancel task: \(task)")
            UIApplication.shared.hideNetworkActivityIndicator()
            task.cancel()
        }
    }

}

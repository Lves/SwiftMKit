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
    private weak var hud: HUDProtocol?
    lazy open var runningTasks = [URLSessionTask]()
    
    private var waitForHide : Bool = false
    
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
            notificationCenter.addObserver(self, selector: #selector(TaskIndicator.task_resume), name: Notification.Name.Task.DidResume, object: nil)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicator.task_suspend), name: Notification.Name.Task.DidSuspend, object: nil)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicator.task_cancel), name: Notification.Name.Task.DidCancel, object: nil)
            notificationCenter.addObserver(self, selector: #selector(TaskIndicator.task_end), name: Notification.Name.Task.DidComplete, object: nil)
            var notify = Notification(name: Notification.Name(rawValue: ""), object: nil)
            notify.userInfo = [Notification.Key.Task: task]
            self.task_resume(notify: notify)
        } else {
            var notify = Notification(name: Notification.Name(rawValue: ""), object: nil)
            notify.userInfo = [Notification.Key.Task: task]
            self.task_end(notify: notify)
        }
    }
    
    func task_resume(notify:Notification) {
        DDLogVerbose("Task resume")
        guard notify.name.rawValue.length == 0 else { //只接受本地的调用
            return
        }
        if let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask {
            if !self.runningTasks.contains(task) {
                
                weak var weakTask = task
                self.runningTasks.append(weakTask!)
            }
            UIApplication.shared.showNetworkActivityIndicator()
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
    func task_suspend(notify:Notification) {
        DDLogVerbose("Task suspend")
        UIApplication.shared.hideNetworkActivityIndicator()
        if let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask {
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
    func task_cancel(notify:Notification) {
        DDLogVerbose("Task cancel")
        UIApplication.shared.hideNetworkActivityIndicator()
        if let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask {
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
    func task_end(notify:Notification) {
        DDLogVerbose("Task complete")
        UIApplication.shared.hideNetworkActivityIndicator()
        if let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask {
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
        var tasks = [URLSessionTask]()
        for task in runningTasks {
            DDLogVerbose("Cancel task: \(task)")
            UIApplication.shared.hideNetworkActivityIndicator()
            tasks.append(task)
        }
        runningTasks.removeAll()
        _ = tasks.map { task in
            Async.main(after: 1) {
                task.cancel()
            }
        }
    }

}

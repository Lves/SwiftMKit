//
//  TaskListIndicator.swift
//  SwiftMKitDemo
//
//  Created by wei.mao on 2018/7/10.
//  Copyright © 2018年 cdts. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CocoaLumberjack

public class TaskListIndicator: Indicator {
    
    public var runningTasks: [URLSessionTask] = []
    private var showing = false
    private var holdHiding = false
    
    private weak var listView: UIScrollView?
    private weak var viewController: BaseListKitViewController?
    
    public required init(listView: UIScrollView?, viewController: BaseListKitViewController){
        self.listView = listView
        self.viewController = viewController
    }
    
    public func add(api: RequestApi, view: UIView?, text: String?) {
    }
    public func register(api: RequestApi, task: URLSessionTask) {
        runningTasks.append(task)
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
        notificationCenter.addObserver(forName: Notification.Name.Task.DidResume, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("Task List Indicator resume")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .running)
        }
        notificationCenter.addObserver(forName: Notification.Name.Task.DidSuspend, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("Task List Indicator suspend")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .stop)
        }
        notificationCenter.addObserver(forName: Notification.Name.Task.DidCancel, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("Task List Indicator cancel")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .stop)
            self?.remove(task: task)
        }
        notificationCenter.addObserver(forName: Notification.Name.Task.DidComplete, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("Task Indicator complete")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .stop)
            self?.remove(task: task)
        }
    }
    
    private func remove(task: URLSessionTask) {
        guard let index = runningTasks.index(where: { $0 == task }) else { return }
        runningTasks.remove(at: index)
    }
    
    public func turning(for task: URLRequest, status: ApiTaskStatus) {
        switch status {
        case .running:
            UIApplication.shared.showNetworkActivityIndicator()
        case .stop:
            UIApplication.shared.hideNetworkActivityIndicator()
            Async.main { [weak self] in
                self?.viewController?.endListRefresh()
            }
        default:
            break
        }
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
        if runningTasks.count > 0 {
            DDLogVerbose("Running list tasks: \(runningTasks.count)")
        }
        UIApplication.shared.hideNetworkActivityIndicator()
        runningTasks.forEach { task in task.cancel() }
    }
    
}

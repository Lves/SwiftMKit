//
//  TaskIndicator.swift
//  SwiftMKitDemo
//
//  Created by wei.mao on 2018/7/6.
//  Copyright © 2018年 cdts. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CocoaLumberjack

public protocol Indicator: class {
    func add(api: RequestApi, view: UIView?, text: String?)
    func register(api: RequestApi, task: URLSessionTask)
}

public class TaskIndicator: Indicator {
    private struct IndicatorModel: Equatable {
        
        var api: RequestApi
        var view: UIView?
        var text: String?
        
        static func == (lhs: TaskIndicator.IndicatorModel, rhs: TaskIndicator.IndicatorModel) -> Bool {
            return lhs.api === rhs.api
        }
    }

    public var runningTasks: [URLSessionTask] = []
    private var models: [IndicatorModel] = []
    private var hud: HudProtocol?
    private var showing = false
    private var holdHiding = false

    public required init(hud: HudProtocol){
        self.hud = hud
    }
    
    public func add(api: RequestApi, view: UIView?, text: String?) {
        models.append(IndicatorModel(api: api, view: view, text: text))
    }
    public func register(api: RequestApi, task: URLSessionTask) {
        guard let model = models.first(where: { $0.api === api }) else { return }
        runningTasks.append(task)
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
        notificationCenter.addObserver(forName: Notification.Name.Task.DidResume, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("Task Indicator resume")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .running, view: model.view, text: model.text)
        }
        notificationCenter.addObserver(forName: Notification.Name.Task.DidSuspend, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("Task Indicator suspend")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .stop, view: model.view, text: model.text)
        }
        notificationCenter.addObserver(forName: Notification.Name.Task.DidCancel, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("Task Indicator cancel")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .stop, view: model.view, text: model.text)
            self?.remove(task: task)
            self?.remove(api: api)
        }
        notificationCenter.addObserver(forName: Notification.Name.Task.DidComplete, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("Task Indicator complete")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .stop, view: model.view, text: model.text)
            self?.remove(task: task)
            self?.remove(api: api)
        }
    }

    private func remove(task: URLSessionTask) {
        guard let index = runningTasks.index(where: { $0 == task }) else { return }
        runningTasks.remove(at: index)
    }
    private func remove(api: RequestApi) {
        guard let index = models.index(where: { $0.api === api }) else { return }
        models.remove(at: index)
    }
    
    public func turning(for task: URLRequest, status: ApiTaskStatus, view: UIView?, text: String?) {
        switch status {
        case .running:
            UIApplication.shared.showNetworkActivityIndicator()
            guard let view = view else { return }
            if !showing {
                Async.main {
                    self.hud?.showIndicator(inView: view, text: text, detailText: nil, animated: false)
                }
            } else {
                self.hud?.change(text: text)
            }
            showing = true
            holdHiding = false
        case .stop:
            UIApplication.shared.hideNetworkActivityIndicator()
            guard let view = view else { return }
            if showing {
                holdHiding = true
                Async.main (after: 0.5){
                    if self.holdHiding {
                        self.hud?.hide(forView: view, type: .text, animated: false)
                    }
                    self.showing = false
                    self.holdHiding = false
                }
            }
        default:
            break
        }
    }

    deinit{
        NotificationCenter.default.removeObserver(self)
        if runningTasks.count > 0 {
            DDLogVerbose("Running tasks: \(runningTasks.count)")
        }
        UIApplication.shared.hideNetworkActivityIndicator()
        runningTasks.forEach { task in task.cancel() }
    }

}

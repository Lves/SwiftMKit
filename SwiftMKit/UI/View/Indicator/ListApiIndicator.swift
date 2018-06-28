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

public class ListApiIndicator: IndicatorProtocol {
    
    public var runningApis: [NetApiProtocol] = []
    private weak var listView: UIScrollView?
    private weak var viewController: BaseListKitViewController?
    
    public required init(listView: UIScrollView?, viewController: BaseListKitViewController){
        self.listView = listView
        self.viewController = viewController
    }
    
    public func bind(api: NetApiProtocol, view: UIView?, text: String?) {
        runningApis.append(api)
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
        notificationCenter.addObserver(forName: Notification.Name.Task.DidResume, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("List Api resume")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .running)
        }
        notificationCenter.addObserver(forName: Notification.Name.Task.DidSuspend, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("List Api suspend")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .stop)
        }
        notificationCenter.addObserver(forName: Notification.Name.Task.DidCancel, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("List Api cancel")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .stop)
            self?.removeApi(forTask: task)
        }
        notificationCenter.addObserver(forName: Notification.Name.Task.DidComplete, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("List Api complete")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .stop)
            self?.removeApi(forTask: task)
        }
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
        if runningApis.count > 0 {
            DDLogVerbose("Running list tasks: \(runningApis.count)")
        }
        UIApplication.shared.hideNetworkActivityIndicator()
        runningApis.forEach { api in api.task?.cancel() }
    }
}

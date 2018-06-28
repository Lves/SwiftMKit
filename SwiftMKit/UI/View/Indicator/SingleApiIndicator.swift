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
import CocoaLumberjack

public class SingleApiIndicator: IndicatorProtocol {
    
    public var runningApis: [NetApiProtocol] = []
    private var hud: HudProtocol?
    private var showing = false
    private var holdHiding = false
    
    public required init(hud: HudProtocol){
        self.hud = hud
    }
    
    public func bind(api: NetApiProtocol, view: UIView?, text: String?) {
        runningApis.append(api)
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
        notificationCenter.addObserver(forName: Notification.Name.Task.DidResume, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("Signle Api resume")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .running, view: view, text: text)
        }
        notificationCenter.addObserver(forName: Notification.Name.Task.DidSuspend, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("Signle Api suspend")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .stop, view: view, text: text)
        }
        notificationCenter.addObserver(forName: Notification.Name.Task.DidCancel, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("Signle Api cancel")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .stop, view: view, text: text)
            self?.removeApi(forTask: task)
        }
        notificationCenter.addObserver(forName: Notification.Name.Task.DidComplete, object: nil, queue: nil) { [weak self] (notify) in
            DDLogVerbose("Signle Api complete")
            guard let task = notify.userInfo?[Notification.Key.Task] as? URLSessionTask, let request = task.originalRequest else { return }
            self?.turning(for: request, status: .stop, view: view, text: text)
            self?.removeApi(forTask: task)
        }
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
        if runningApis.count > 0 {
            DDLogVerbose("Running single tasks: \(runningApis.count)")
        }
        UIApplication.shared.hideNetworkActivityIndicator()
        runningApis.forEach { api in api.task?.cancel() }
    }

}

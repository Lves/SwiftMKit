//
//  ApiClient.swift
//  SwiftMKitDemo
//
//  Created by wei.mao on 2018/7/4.
//  Copyright © 2018年 cdts. All rights reserved.
//

import Foundation
import Alamofire
import CocoaLumberjack

struct ApiClient {
    
    static var sessions: [String: SessionManager] = [:]
    
    static func getSessionManager(api: RequestApi) -> SessionManager {
        if sessions.keys.contains(api.sessionIdentifier) {
            return sessions[api.sessionIdentifier]!
        }
        let sessionManager: SessionManager = {
            let configuration = URLSessionConfiguration.default
            var headers: [String : Any] = SessionManager.defaultHTTPHeaders
            if let baseHeader = api.baseHeader {
                headers.merge(baseHeader, uniquingKeysWith: { a, b in b })
            }
            configuration.httpAdditionalHeaders = headers
            configuration.timeoutIntervalForResource = api.timeoutIntervalForResource
            configuration.timeoutIntervalForRequest = api.timeoutIntervalForRequest
            let sm = SessionManager(configuration: configuration)
            let handler = api.requestHandler
            sm.adapter = handler
            sm.retrier = handler
            sm.startRequestsImmediately = false
            return sm
        }()
        sessions[api.sessionIdentifier] = sessionManager
        return sessionManager
    }
    
    static func clearCookie() {
        DDLogInfo("清除Cookie")
        let cookieJar = HTTPCookieStorage.shared
        
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
    }
    
    private static var runningApis = [RequestApi]()

    // MARK: RunningApi

    public static func runnings() -> [RequestApi] {
        return runningApis
    }
    public static func add(api: RequestApi) {
        runningApis.append(api)
        DDLogDebug("[Api][+][\(runningApis.count)] \(api)")
    }
    public static func remove(api: RequestApi) {
        if let index = runningApis.index(where: { api === $0 }) {
            runningApis.remove(at: index)
            DDLogDebug("[Api][-][\(runningApis.count)] \(api)")
        }
    }
}

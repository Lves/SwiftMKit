//
//  NetApiData.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/8/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Alamofire
import CocoaLumberjack

public class NetApiData: NSObject {
    
    static let sharedInstance = NetApiData()
    private override init() {
        self.apiClient = NetApiClient()
        super.init()
    }
    
    struct NetApiDataConst {
        static let DefaultTimeoutInterval: NSTimeInterval = 45
    }
    
    public var apiClient:NetApiClient
    public var baseQuery = [String:AnyObject]()
    public var apiQuery = [String:AnyObject]()
    public var apiMethod: Alamofire.Method = .GET
    public var apiUrl = ""
    public var apiTimeout = NetApiDataConst.DefaultTimeoutInterval
    public var request:Request?
    
    lazy private var runningApis = [NetApiData]()
    
    public init(client: NetApiClient, url: String, query: [String:AnyObject] = [String:AnyObject](), method: Alamofire.Method = .GET) {
        self.apiClient = client
        self.apiUrl = url
        self.apiQuery = query
        self.apiMethod = method;
        super.init()
    }
    
    // MARK: RunningApi
    
    class public func requestingApis() -> Array<NetApiData> {
        return sharedInstance.runningApis
    }
    class public func addApi(api: NetApiData) {
        sharedInstance.runningApis.append(api)
        DDLogInfo("[Api++ \(api)]:Running api count is \(sharedInstance.runningApis.count)")
    }
    class public func removeApi(api: NetApiData) {
        sharedInstance.runningApis.append(api)
        DDLogInfo("[Api++ \(api)]:Running api count is \(sharedInstance.runningApis.count)")
    }
    
    // MARK: JSON
    
    class public func getArrayFromJson<T: NSObject>(json: [String: AnyObject]) -> Array<T>{
        let arr = T.mj_objectArrayWithKeyValuesArray(json)
        return arr as NSArray as! [T]
    }
    class public func getObjectFromJson<T: NSObject>(json: [String: AnyObject]) -> T{
        let obj = T.mj_objectWithKeyValues(json)
        return obj as NSObject as! T
    }
    
    // MARK: Request
    
//    public func requestJSON() -> RACSignal {
//        return RACSignal.createSignal() { [unowned self] (subscriber) -> RACDisposable! in
//            let success = {}
//        }
//    }
}

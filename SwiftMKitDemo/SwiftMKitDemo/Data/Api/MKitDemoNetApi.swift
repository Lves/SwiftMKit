//
//  MKitDemoNetApi.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import CocoaLumberjack

class WangYiApi: NSObject, RequestApi {
    
    var sessionIdentifier: String { return "WangYiApi" }
    var baseURLString: String { return "https://3g.163.com/" }
    var baseHeader: [String : Any]? { return nil }
    var timeoutIntervalForRequest: TimeInterval { return 15 }
    var timeoutIntervalForResource: TimeInterval { return 45 }
    var url: String { return "" }
    var method: HTTPMethod { return .get }
    var params: [String: Any]? { return nil }
    var headers: HTTPHeaders? { return nil }
    var responseData: Data?
    var error: NetError?
    var requestHandler: RequestHandler?
    weak var indicator: Indicator?
    
    func setIndicator(_ indicator: Indicator?, view: UIView? = UIViewController.topController?.view, text: String? = nil) -> Self {
        self.indicator = indicator
        self.indicator?.add(api: self, view: view, text: text)
        return self
    }
    var validate: DataRequest.Validation {
        return { request, response, data in
            return DataRequest.ValidationResult.success
        }
    }
    func adapt(_ result: Result<String>) -> Result<String> {
        if case let Result.success(value) = result {
            let content = value[value.index(value.startIndex, offsetBy: 9)..<value.index(before: value.endIndex)]
            return Result.success(String(content))
        }
        return result
    }
    func fill(data: Any) {
        if let map = data as? [String: Any] {
            fill(map: map)
        } else if let array = data as? [Any] {
            fill(array: array)
        }
    }
    func fill(map: [String: Any]) {}
    func fill(array: [Any]) {}
    
    public override init() {
        super.init()
    }
    public convenience init(error: NetError) {
        self.init()
        self.error = error
    }
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(type(of: self)))")
    }
}


struct NewsModel: Codable {
    var title: String
    var digest: String
    var ptime: String
    var docid: String
    var url: String
    var imgsrc: String?
    var commentCount: Int
    var skipType: String?
    var skipURL: String?
    func getDetailUrl() -> String {
        if skipType != nil {
            return skipURL ?? ""
        }
        return "https://3g.163.com/news/article/\(docid).html"
    }
    var displayCommentCount: String {
        switch commentCount {
        case let x where x > 10000:
            let value = String(format: "%.1f", Double(x) / 10000.0)
            return "\(value)万"
        default:
            return commentCount.toString
        }
    }
    var  displayTime: String {
        return ptime.friendlyTime
    }
}


class NewsListApi: WangYiApi {
    var news: [NewsModel]?
    var offset: UInt
    var size: UInt
    override var url: String {
        return "touch/reconstruct/article/list/BBM54PGAwangning/\(offset)-\(size).html"
    }
    init(offset: UInt, size: UInt) {
        self.offset = offset
        self.size = size
        super.init()
    }
    override func fill(data: Any) {
        let str = data as! String
        let map = str.toDictionary()!
        self.news = toModel([NewsModel].self, value: map["BBM54PGAwangning"])
    }
}

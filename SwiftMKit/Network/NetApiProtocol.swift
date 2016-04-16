//
//  ApiProtocol.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Alamofire

public protocol NetApiProtocol {
    var query: [String: AnyObject]? { get }
    var method: Alamofire.Method? { get }
    var url: String? { get }
    var timeout: NSTimeInterval? { get }
    var request:Request? { get set }
    var responseJSONData:AnyObject? { get set }
    
    func fillJSON(json: AnyObject)
    func transferURLRequest(request:NSMutableURLRequest) -> NSMutableURLRequest
    func transferResponseJSON(response: Response<AnyObject, NSError>) -> Response<AnyObject, NSError>
    func transferResponseData(response: Response<NSData, NSError>) -> Response<NSData, NSError>
    func transferResponseString(response: Response<String, NSError>) -> Response<String, NSError>
}

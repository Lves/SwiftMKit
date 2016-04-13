//
//  MKitDemoApiData.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/11/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MKitDemoApiData: NetApiData {

}

class PX500DemoApiData: MKitDemoApiData {
    override func baseUrl() -> String {
        return PX500ApiInfo.apiBaseUrl + "/v1"
    }
}
class BaiduDemoApiData: MKitDemoApiData {
    override func baseUrl() -> String {
        return BaiduApiInfo.apiBaseUrl + "/baidunuomi/openapi"
    }
    override func transferURLRequest(request: NSMutableURLRequest) -> NSMutableURLRequest {
        request.setValue(BaiduConfig.ApiKey, forHTTPHeaderField: "apikey")
        return request
    }
}
class PX500PopularPhotosApiData: PX500DemoApiData {
    init(page: Int) {
        let params = ["consumer_key": PX500Config.ConsumerKey,
                      "page": "\(page)",
                      "feature": "popular",
                      "rpp": "50",
                      "include_store": "store_download",
                      "include_states": "votes"]
        super.init(client: MKitDemoApiClient.sharedInstance, url: "/photos", query: params, method: .GET)
    }
    override func fill(json: JSON) {
        
    }
}

class BaiduCitiesApiData: BaiduDemoApiData {
    var cities: Array<MKDataNetworkRequestCityModel>?
    
    init() {
        super.init(client: MKitDemoApiClient.sharedInstance, url: "/cities", query: [:], method: .GET)
    }
    override func fill(json: JSON) {
//        self.cities = NetApiData.getArrayFromJson(json["cities"].arrayObject!)
    }
}

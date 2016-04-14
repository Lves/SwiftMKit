//
//  ViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/14/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Alamofire
import ReactiveCocoa

class ViewController: UIViewController {
    var api = BaiduCitiesApiData()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        api.requestJSON().startWithNext { api in
                
        }
//            { response in
//            self.tableView.mj_header.endRefreshing()
//            switch response.result {
//            case .Success:
//                if let value = response.result.value {
//                    let json = JSON(value)
//                    DDLogVerbose("JSON: \(json)")
//                    let shops = json["data"]["shops"].arrayValue
//                    var models = [MKDataNetworkRequestShopModel]()
//                    for shop in shops {
//                        let model = MKDataNetworkRequestShopModel(shopId: shop["shop_id"].stringValue, name: shop["shop_name"].stringValue, url: shop["shop_murl"].stringValue)
//                        models.append(model)
//                    }
//                    self.thisViewModel.dataSource = models
//                    self.tableView.reloadData()
//                }
//            case .Failure(let error):
//                DDLogError("\(error)")
//            }
//        }
//
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


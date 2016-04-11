//
//  MKDataNetworkRequestViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Alamofire
import CocoaLumberjack
import SwiftyJSON
import ReactiveCocoa

class MKDataNetworkRequestViewController: BaseListViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    struct InnerConst {
        static let CellIdentifier = "MKDataNetworkRequestTableViewCell"
        static let segueToNext = "routeToDataNetworkImages"
    }
    var thisViewModel: MKDataNetworkRequestViewModel! {
        get {
            if viewModel == nil {
                viewModel = MKDataNetworkRequestViewModel()
            }
            return viewModel as! MKDataNetworkRequestViewModel
        }
    }
    override var listView: UIScrollView! {
        get {
            return tableView
        }
    }
    override var listViewType: ListViewType {
        get { return .ListViewTypeRefreshOnly }
    }
    
    override func setupUI() {
        super.setupUI()
        self.title = "Network Request"
        loadData()
    }
    override func loadData() {
        super.loadData()
        self.tableView.mj_header.beginRefreshing()
    }
    override func refreshData() {
        super.refreshData()
        BaiduCitiesApiData().requestJSON().startWithNext { [unowned self] apiData in
            self.tableView.mj_header.endRefreshing()
            let data = apiData as! BaiduCitiesApiData
            let cities = apiData.responseJSONData!["cities"].arrayValue
            var models = [MKDataNetworkRequestCityModel]()
            for city in cities {
                let model = MKDataNetworkRequestCityModel(cityId: city["city_id"].stringValue, name: city["city_name"].stringValue, pinyin: city["city_pinyin"].stringValue)
                models.append(model)
            }
            self.thisViewModel.dataSource = models
            self.tableView.reloadData()
        }
//        let request = NSMutableURLRequest(URL: NSURL(string: BaiduConfig.UrlCities)!)
//        request.HTTPMethod = "GET"
//        request.setValue(BaiduConfig.ApiKey, forHTTPHeaderField: "apikey")
//        Alamofire.request(request).responseJSON { response in
//            self.tableView.mj_header.endRefreshing()
//            switch response.result {
//            case .Success:
//                if let value = response.result.value {
//                    let json = JSON(value)
//                    DDLogVerbose("JSON: \(json)")
//                    let cities = json["cities"].arrayValue
//                    var models = [MKDataNetworkRequestCityModel]()
//                    for city in cities {
//                        let model = MKDataNetworkRequestCityModel(cityId: city["city_id"].stringValue, name: city["city_name"].stringValue, pinyin: city["city_pinyin"].stringValue)
//                        models.append(model)
//                    }
//                    self.thisViewModel.dataSource = models
//                    self.tableView.reloadData()
//                }
//            case .Failure(let error):
//                DDLogError("\(error)")
//            }
//        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.thisViewModel.dataSource.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: InnerConst.CellIdentifier)
        }
        let model = self.thisViewModel.dataSource[indexPath.row] as? MKDataNetworkRequestCityModel
        cell?.textLabel?.text = model?.name
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let model = self.thisViewModel.dataSource[indexPath.row] as? MKDataNetworkRequestCityModel
        self.routeToName(InnerConst.segueToNext, params: ["cityId":model!.cityId])
    }
}

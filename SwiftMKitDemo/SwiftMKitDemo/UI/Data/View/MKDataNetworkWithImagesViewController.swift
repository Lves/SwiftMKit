//
//  MKDataNetworkWithImagesViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/4/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Alamofire
import CocoaLumberjack

class MKDataNetworkWithImagesViewController: BaseListViewController {
    var cityId: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    struct InnerConst {
        static let CellIdentifier = "MKDataNetworkImagesTableViewCell"
    }
    var thisViewModel: MKDataNetworkImagesViewModel! {
        get {
            if viewModel == nil {
                viewModel = MKDataNetworkImagesViewModel()
            }
            return viewModel as! MKDataNetworkImagesViewModel
        }
    }
    override var listView: UIScrollView! {
        get {
            return tableView
        }
    }
    override var listViewType: ListViewType {
        get { return .ListViewTypeBoth }
    }
    
    override func setupUI() {
        super.setupUI()
        self.title = "Network Images"
        loadData()
    }
    override func loadData() {
        super.loadData()
        self.tableView.mj_header.beginRefreshing()
    }
    override func refreshData() {
        super.refreshData()
//        Alamofire.request(.GET, BaiduConfig.UrlShops, parameters: ["city_id":self.cityId!], headers: ["apikey":BaiduConfig.ApiKey]).responseJSON { response in
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
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.thisViewModel.dataSource.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: InnerConst.CellIdentifier)
        }
        let model = self.thisViewModel.dataSource[indexPath.row] as? MKDataNetworkRequestShopModel
        cell?.textLabel?.text = model?.name
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

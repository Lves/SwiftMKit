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
    private var _viewModel = MKDataNetworkImagesViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    override var listView: UIScrollView! {
        get { return tableView }
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
//    override func refreshData() {
//        super.refreshData()
//        NetApiData(api: BaiduShopsApiData(cityId: self.cityId!)).requestJSON().startWithNext({ [unowned self] apiData in
//            self.tableView.mj_header.endRefreshing()
//            let data = apiData as! BaiduShopsApiData
//            if let shops = data.shops {
//                self.thisViewModel.dataSource = shops
//                self.tableView.reloadData()
//            }
//        })
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _viewModel.dataSource.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: InnerConst.CellIdentifier)
        }
//        let model = _viewModel.dataSource[indexPath.row] as? MKDataNetworkRequestShopModel
//        cell?.textLabel?.text = model?.name
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

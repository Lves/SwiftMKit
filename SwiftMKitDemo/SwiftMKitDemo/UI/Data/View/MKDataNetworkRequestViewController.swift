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
        NetApiData(api: BaiduCitiesApiData()).requestJSON().startWithNext({ [unowned self] apiData in
            self.tableView.mj_header.endRefreshing()
            let data = apiData as! BaiduCitiesApiData
            if let cities = data.cities {
                self.thisViewModel.dataSource = cities
                self.tableView.reloadData()
            }
        })
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
        self.routeToName(InnerConst.segueToNext, params: ["cityId":model!.cityId!])
    }
}

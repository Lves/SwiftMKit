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
import ReactiveCocoa
import Haneke

class MKDataNetworkRequestViewController: BaseListViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    struct InnerConst {
        static let CellIdentifier = "MKDataNetworkRequestTableViewCell"
        static let segueToNext = "routeToDataNetworkImages"
    }
    lazy private var _viewModel = MKDataNetworkRequestViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    override var listView: UIScrollView! {
        get { return tableView }
    }
    override var listViewType: ListViewType {
        get { return .Both }
    }
    
    override func setupUI() {
        super.setupUI()
        self.title = "Network Request"
        self.tableView.estimatedRowHeight = self.tableView.rowHeight;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        loadData()
    }
    override func loadData() {
        super.loadData()
        self.tableView.mj_header.beginRefreshing()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _viewModel.dataSource.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier) as? MKDataNetworkRequestTableViewCell
        let model = _viewModel.dataSource[indexPath.row] as? MKDataNetworkRequestPhotoModel
        cell?.lblTitle?.text = model?.name
        cell?.lblContent?.text = model?.descriptionString
        cell?.imgHead.hnk_setImageFromURL(NSURL(string: (model?.userpic)!)!)
        if let imageUrl = model?.imageurl {
            cell?.imgPic.hnk_setImageFromURL(NSURL(string: imageUrl)!, format: Format<UIImage>(name: "original"))
        }else {
            cell?.imgPic.image = nil
        }
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let model = _viewModel.dataSource[indexPath.row] as? MKDataNetworkRequestPhotoModel
//        self.routeToName(InnerConst.segueToNext, params: ["cityId":model!.cityId!])
    }
}

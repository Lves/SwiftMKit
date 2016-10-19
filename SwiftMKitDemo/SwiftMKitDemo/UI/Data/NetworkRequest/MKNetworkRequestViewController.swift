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
import FDFullscreenPopGesture

class MKNetworkRequestViewController: BaseListViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    struct InnerConst {
        static let CellIdentifier = "MKNetworkRequestTableViewCell"
        static let SegueToNext = "routeToNetworkRequestDetail"
    }
    lazy private var _viewModel = MKNetworkRequestViewModel()
    override var viewModel: MKNetworkRequestViewModel!{
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
        self.tableView.registerNib(UINib(nibName: InnerConst.CellIdentifier, bundle: nil), forCellReuseIdentifier: InnerConst.CellIdentifier)
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = self.tableView.rowHeight;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        loadData()
    }
    override func loadData() {
        super.loadData()
        self.listView.mj_header.beginRefreshing()
    }
    @IBAction func click_encrypt(sender: UIBarButtonItem) {
        viewModel.encrypt = (sender.title == "Encrypt")
        sender.title = ((sender.title == "Encrypt") ? "Encrypted" : "Encrypt")
    }
    
    override func getCellWithTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell? {
        return tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier) as? MKNetworkRequestTableViewCell
    }
    override func configureCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        if let cell = tableViewCell as? MKNetworkRequestTableViewCell {
            if let model = object as? PX500PopularPhotoModel {
                cell.photoModel = model
            }
        }
    }
    override func didSelectCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        if let model = object as? PX500PopularPhotoModel {
            self.routeToName(InnerConst.SegueToNext, params: ["photoId":model.photoId!])
        }
    }
}

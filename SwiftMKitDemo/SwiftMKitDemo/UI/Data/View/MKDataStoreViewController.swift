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

enum DataStoreType: Int {
    case Memory, CoreData
}

class MKDataStoreViewController: BaseListFetchViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    struct InnerConst {
        static let CellIdentifier = "MKDataNetworkRequestTableViewCell"
        static let SegueToNext = "routeToNetworkRequestDetail"
    }
    lazy private var _viewModel = MKDataStoreViewModel()
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
        self.title = "Photos"
        self.tableView.registerNib(UINib(nibName: InnerConst.CellIdentifier, bundle: nil), forCellReuseIdentifier: InnerConst.CellIdentifier)
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = self.tableView.rowHeight;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        loadData()
    }
    override func loadData() {
        super.loadData()
        self.tableView.mj_header.beginRefreshing()
    }
    override func getCellWithTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell? {
        return tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier)
    }
    override func configureCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        if let cell = tableViewCell as? MKDataNetworkRequestTableViewCell {
            if let model = object as? PX500PhotoEntity {
                cell.photoEntity = model
            }
        }
    }
    override func didSelectCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        if let model = object as? PX500PhotoEntity {
            self.routeToName(InnerConst.SegueToNext, params: ["photoId":model.photoId!])
        }
    }
}

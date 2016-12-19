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

class MKNetworkRequestViewController: BaseListViewController {
    @IBOutlet weak var tableView: UITableView!
    
    struct InnerConst {
        static let CellIdentifier = "MKNetworkRequestTableViewCell"
        static let SegueToNext = "routeToNetworkRequestDetail"
    }
    lazy fileprivate var _viewModel = MKNetworkRequestViewModel()
    override var viewModel: MKNetworkRequestViewModel!{
        get { return _viewModel }
    }
    override var listView: UIScrollView! {
        get { return tableView }
    }
    override var listViewType: ListViewType {
        get { return .both }
    }
    
    override func setupUI() {
        super.setupUI()
        self.tableView.register(UINib(nibName: InnerConst.CellIdentifier, bundle: nil), forCellReuseIdentifier: InnerConst.CellIdentifier)
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = self.tableView.rowHeight;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        loadData()
    }
    override func loadData() {
        super.loadData()
        self.listView.mj_header.beginRefreshing()
    }
    
    override func getCellWithTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: InnerConst.CellIdentifier) as? MKNetworkRequestTableViewCell
    }
    override func configureCell(_ tableViewCell: UITableViewCell, object: AnyObject, indexPath: IndexPath) {
        if let cell = tableViewCell as? MKNetworkRequestTableViewCell {
            if let model = object as? PX500PopularPhotoModel {
                cell.photoModel = model
            }
        }
    }
    override func didSelectCell(_ tableViewCell: UITableViewCell, object: AnyObject, indexPath: IndexPath) {
        if let model = object as? PX500PopularPhotoModel {
            _ = self.routeToName(InnerConst.SegueToNext, params: ["photoId":model.photoId! as AnyObject])
        }
    }
}

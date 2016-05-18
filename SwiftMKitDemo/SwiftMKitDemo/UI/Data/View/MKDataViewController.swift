//
//  ViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKDataViewController: BaseListViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    
    struct InnerConst {
        static let CellIdentifier = "MKDataTableViewCell"
        static let SegueToNextNetwork = "routeToDataNetworkRequest"
        static let SegueToNextStore = "routeToDataStore"
    }
    
    private var _viewModel = MKDataViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    override var listView: UIScrollView! {
        get { return tableView }
    }
    var networkStatus: String = NetApiClient.shared.networkStatus.value.description {
        didSet {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Fade)
        }
    }
    
    override func bindingData() {
        super.bindingData()
        NetApiClient.shared.networkStatus.producer.startWithNext { [weak self] status in
            self?.networkStatus = status.description
        }
    }
    
    override func getCellWithTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: InnerConst.CellIdentifier)
        }
        return cell
    }
    override func configureCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        if let model = object as? MKDataListModel {
            tableViewCell.textLabel?.text = model.title
            tableViewCell.detailTextLabel?.text = model.detail
            if indexPath.row == 0 {
                tableViewCell.detailTextLabel?.text = networkStatus
                tableViewCell.accessoryType = .None
            } else {
                tableViewCell.accessoryType = .DisclosureIndicator
            }
        }
    }
    override func didSelectCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            self.routeToName(InnerConst.SegueToNextNetwork)
        case 2:
            self.routeToName(InnerConst.SegueToNextStore)
        default:
            break
        }
    }
}


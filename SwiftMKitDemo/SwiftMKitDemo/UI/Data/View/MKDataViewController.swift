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
    var locationInfo: String = "Unknown" {
        didSet {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Fade)
        }
    }
    override func setupNotification() {
        super.setupNotification()
        NSNotificationCenter.defaultCenter().addObserverForName(LocationManager.NotificationLocationUpdatedName, object: nil, queue: nil) { [weak self] _ in
            self?.locationInfo = "(\(String(format: "%.2f",LocationManager.shared.longitude ?? 0)), \(String(format: "%.2f",LocationManager.shared.latitude ?? 0)))"
            LocationManager.stop()
        }
    }
    override func bindingData() {
        super.bindingData()
        NetApiClient.shared.networkStatus.producer.startWithNext { [weak self] status in
            self?.networkStatus = status.description
        }
        let result = LocationManager.start()
        if result {
            locationInfo = "Locating"
        } else {
            locationInfo = "Disabled"
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
            } else if indexPath.row == 1 {
                tableViewCell.detailTextLabel?.text = locationInfo
                tableViewCell.accessoryType = .None
            } else {
                tableViewCell.accessoryType = .DisclosureIndicator
            }
        }
    }
    override func didSelectCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            fallthrough
        case 1:
            break
        case 2:
            self.routeToName(InnerConst.SegueToNextNetwork)
        case 3:
            self.routeToName(InnerConst.SegueToNextStore)
        default:
            break
        }
    }
}


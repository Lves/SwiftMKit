//
//  ViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKDataViewController: BaseListViewController {
    @IBOutlet weak var tableView: UITableView!
    
    struct InnerConst {
        static let CellIdentifier = "MKDataTableViewCell"
        static let SegueToNextNetwork = "routeToDataNetworkRequest"
        static let SegueToNextStore = "routeToDataStore"
    }
    
    fileprivate var _viewModel = MKDataViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    override var listView: UIScrollView! {
        get { return tableView }
    }
    var networkStatus: String = NetworkListener.networkStatus.value.rawValue {
        didSet {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
    }
    var locationInfo: String = "Unknown" {
        didSet {
            tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        }
    }
    override func bindingData() {
        super.bindingData()
        NetworkListener.networkStatus.producer.startWithValues { [weak self] status in
            self?.networkStatus = status.rawValue
        }
        locationInfo = "Locating"
        LocationManager.shared.getlocation { [weak self] (location, error) in
            if let location = location {
                self?.locationInfo = "(\(String(format: "%.2f",location.coordinate.latitude)), \(String(format: "%.2f",location.coordinate.longitude)))"
            } else {
                self?.locationInfo = "Disabled"
            }
        }
    }
    
    
    override func getCell(withTableView tableView: UITableView, indexPath: IndexPath) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCell(withIdentifier: InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: InnerConst.CellIdentifier)
        }
        return cell
    }
    override func configureCell(_ tableViewCell: UITableViewCell, object: Any, indexPath: IndexPath) {
        if let model = object as? MKDataListModel {
            tableViewCell.textLabel?.text = model.title
            tableViewCell.detailTextLabel?.text = model.detail
            if indexPath.row == 0 {
                tableViewCell.detailTextLabel?.text = networkStatus
                tableViewCell.accessoryType = .none
            } else if indexPath.row == 1 {
                tableViewCell.detailTextLabel?.text = locationInfo
                tableViewCell.accessoryType = .none
            } else {
                tableViewCell.accessoryType = .disclosureIndicator
            }
        }
    }
    override func didSelectCell(_ tableViewCell: UITableViewCell, object: Any, indexPath: IndexPath) {
        if let model = object as? MKDataListModel {
            self.route(toName: model.route ?? "", storyboardName: model.routeSB)
        }
    }
}


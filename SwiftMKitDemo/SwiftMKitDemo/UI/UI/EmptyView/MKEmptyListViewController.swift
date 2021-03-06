//
//  MKEmptyListViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 17/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import SwiftMKit

class MKEmptyListViewController: BaseListViewController {
    
    struct InnerConst {
        static let CellIdentifier = "MKEmptyListTableViewCell"
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy fileprivate var _viewModel = MKEmptyListViewModel()
    override var viewModel: MKEmptyListViewModel!{
        get { return _viewModel }
    }
    
    override var listView: UIScrollView! {
        return tableView
    }
    
    override var listViewType: ListViewType {
        get { return .refreshOnly }
    }
    
    override func setupUI() {
        super.setupUI()
        self.tableView.tableFooterView = UIView()
        loadData()
    }
    override func loadData() {
        super.loadData()
        self.listView.mj_header.beginRefreshing()
    }
    override func getCell(withTableView tableView: UITableView, indexPath: IndexPath) -> UITableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: InnerConst.CellIdentifier)
    }
    override func configureCell(_ tableViewCell: UITableViewCell, object: Any, indexPath: IndexPath) {
        if let model = object as? String {
            tableViewCell.textLabel?.text = model
        }
    }
}

class MKEmptyListViewModel: BaseListViewModel {
    
    fileprivate var hasData = false
    
    override func fetchData() {
        let _ = Async.main(after: 1) { [weak self] in
            if self?.hasData == true {
                self?.updateDataArray(["Cell" as AnyObject,"Cell" as AnyObject,"Cell" as AnyObject])
            } else {
                self?.updateDataArray([])
            }
            self?.hasData = !(self?.hasData ?? false)
            self?.listViewController.endListRefresh()
        }
    }
}

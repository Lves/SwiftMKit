//
//  MKEmptyListViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 17/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKEmptyListViewController: BaseListViewController {
    
    struct InnerConst {
        static let CellIdentifier = "MKEmptyListTableViewCell"
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy private var _viewModel = MKEmptyListViewModel()
    override var viewModel: MKEmptyListViewModel!{
        get { return _viewModel }
    }
    
    override var listView: UIScrollView! {
        return tableView
    }
    
    override var listViewType: ListViewType {
        get { return .RefreshOnly }
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
    override func getCellWithTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell? {
        return tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier)
    }
    override func configureCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        if let model = object as? String {
            tableViewCell.textLabel?.text = model
        }
    }
}

class MKEmptyListViewModel: BaseListViewModel {
    
    private var hasData = false
    
    override func fetchData() {
        Async.main(after: 1) { [weak self] in
            if self?.hasData == true {
                self?.updateDataArray(["Cell","Cell","Cell"])
            } else {
                self?.updateDataArray([])
            }
            self?.hasData = !(self?.hasData ?? false)
            self?.listViewController.endListRefresh()
        }
    }
}
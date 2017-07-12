//
//  CrashLogViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 09/01/2017.
//  Copyright © 2017 cdts. All rights reserved.
//

import UIKit

class CrashLogViewController: BaseListKitViewController {
    
    struct InnerConst {
        static let CellIdentifier = "CrashLogTableViewCell"
        static let SegueToNextView = "CrashLogDetailViewController"
        
    }
    @IBOutlet weak var tableView: UITableView!
   
    private var _viewModel = CrashLogViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    override var listViewType: ListViewType {
        return .Both
    }
    override var listView: UIScrollView! {
        get { return tableView }
    }
    
    override func setupUI() {
        super.setupUI()
        title = "Crash Log"
        tableView.tableFooterView = UIView()
        loadData()
    }
    override func setupNavigation() {
        super.setupNavigation()
        let item = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(CrashLogViewController.clear))
        self.navigationItem.rightBarButtonItem = item
    }
    override func loadData() {
        super.loadData()
        _viewModel.fetchData()
    }
    
    func clear() {
        let alert = UIAlertController(title: "确认", message: "确定要清空所有崩溃日志？", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "清空", style: .Destructive, handler: { [weak self] _ in
            LocalCrashLogReporter.shared.clean()
            self?._viewModel.fetchData()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        showAlert(alert, completion: nil)
    }
    
    override func getCellWithTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: InnerConst.CellIdentifier)
        }
        return cell
    }
    override func configureCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        if let model = object as? CrashLogEntity {
            tableViewCell.textLabel?.text = model.createTime?.toString(format: "yyyy-MM-dd HH:mm:ss")
            tableViewCell.detailTextLabel?.text = model.message
        }
    }
    override func didSelectCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        if let model = object as? CrashLogEntity {
            self.routeToName(InnerConst.SegueToNextView, params: ["title": model.createTime?.toString(format: "yyyy-MM-dd HH:mm:ss") ?? "Crash Log", "text": model.message ?? ""])
        }
    }
}

class CrashLogViewModel: BaseListViewModel {
    override var listLoadNumber: UInt {
        return 20
    }
    override func fetchData() {
        let array = LocalCrashLogReporter.shared.queryCrashLog(page: Int(dataIndex), number: Int(listLoadNumber))
        updateDataArray(array)
        listViewController.endListRefresh()
    }
    
}

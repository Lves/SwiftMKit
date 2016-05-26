//
//  MKUITreeViewController.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/5/26.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

class MKUITreeViewController: BaseListViewController {
    @IBOutlet weak var tableView: UITableView!
    struct InnerConst {
        static let CellName = "MKUITreeViewCellTableViewCell"
        static let CellID = "MKUITreeViewCellTableViewCell"
    }
    
    private var _viewModel = MKUIViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    override var listView: UIScrollView! {
        get { return tableView }
    }

    // MARK: - <TableViewDelegate>
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataSource?.count ?? 0
        return 30
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellID) as! MKUITreeViewCellTableViewCell
//        let os = dataSource![indexPath.row]
        cell.textLabel?.text = "-- \(indexPath.row)"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 动态插入一行
//        let os = dataSource![indexPath.row]
//        dataSource?.append(OrderState(name: "\(os.stateName!)\(indexPath.row)", date: os.date!, children: nil))
//        let nextIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
//        tableView.insertRowsAtIndexPaths([nextIndexPath], withRowAnimation: .Fade)
//        tableView.reloadData()
    }
}

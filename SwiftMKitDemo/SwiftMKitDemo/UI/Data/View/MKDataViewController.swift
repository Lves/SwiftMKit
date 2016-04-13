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
        static let segueToNext = "routeToDataNetworkRequest"
    }

    var thisViewModel: MKDataViewModel! {
        get {
            if viewModel == nil {
                viewModel = MKDataViewModel()
            }
            return viewModel as! MKDataViewModel
        }
    }
    override var listView: UIScrollView! {
        get {
            return tableView
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.thisViewModel.dataSource.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: InnerConst.CellIdentifier)
        }
        let model = self.thisViewModel.dataSource[indexPath.row] as? MKDataListModel
        cell?.textLabel?.text = model?.title
        cell?.detailTextLabel?.text = model?.detail
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            self.routeToName(InnerConst.segueToNext, params: ["title":"Cities"])
        }
    }
}


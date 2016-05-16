//
//  MKUISideViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/10/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

class MKUISideViewController: BaseViewController, SideMenuDelegate, SideMenuProtocol {
    @IBOutlet weak var btnTopMenu: UIBarButtonItem!
    var sideMenu: SideMenu?
    var menuViewController: UIViewController?
    
    private var _viewModel = MKUISideViewModel()
    override var viewModel: BaseKitViewModel! {
        get { return _viewModel }
    }
    
    override func setupUI() {
        super.setupUI()
        menuViewController = self.initialedViewController("MKUISideMenuViewController")
        sideMenu = SideMenu(masterViewController: self, menuViewController: menuViewController!)
        sideMenu?.delegate = self
        self.forbiddenSwipBackGesture = true
    }
    
    @IBAction func click_menu(sender: UIBarButtonItem) {
        sideMenu?.routeToSideMenu()
    }
    func sideMenuDidHideMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController) {
        DDLogVerbose("Side Menu Did Hide")
    }
    func sideMenuDidShowMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController) {
        DDLogVerbose("Side Menu Did Show")
    }
}

class MKUISideMenuViewController: BaseListViewController, SideMenuProtocol {
    
    struct InnerConst {
        static let CellIdentifier = "MKUISideMenuTableViewCell"
        static let SegueToNextSideViewDetail = "MKUISideDetailViewController"
    }
    
    var sideMenu: SideMenu?
    @IBOutlet weak var tableView: UITableView!
    
    private var _viewModel = BaseListViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    override var listView: UIScrollView! {
        get { return tableView }
    }
    override func setupUI() {
        super.setupUI()
        tableView.snp_remakeConstraints { (make) in
            make.top.bottom.left.right.equalTo(0)
        }
        loadData()
    }
    override func loadData() {
        super.loadData()
        listViewModel.dataArray = [1,2,3,4,5,6,7,8,9,10]
        tableView.reloadData()
    }
    
    override func getCellWithTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: InnerConst.CellIdentifier)
        }
        return cell
    }
    override func configureCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        tableViewCell.textLabel?.text = "Menu - \(indexPath.row)"
    }
    override func didSelectCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        sideMenu?.routeToSideMaster(InnerConst.SegueToNextSideViewDetail)
    }
}

class MKUISideDetailViewController: BaseViewController {
    private var _viewModel = BaseViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    @IBAction func click_back(sender: UIBarButtonItem) {
        self.routeBack()
    }
}
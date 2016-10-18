//
//  MKUISideViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/10/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack
import FDFullscreenPopGesture

class MKSideViewController: BaseViewController, SideMenuDelegate, SideMenuProtocol {
    @IBOutlet weak var btnTopMenu: UIBarButtonItem!
    var sideMenu: SideMenu?
    var menuViewController: UIViewController?
    
    private var _viewModel = BaseKitViewModel()
    override var viewModel: BaseKitViewModel! {
        get { return _viewModel }
    }
    
    override func setupUI() {
        super.setupUI()
        self.fd_interactivePopDisabled = false
        menuViewController = self.initialedViewController("MKSideMenuViewController")
        sideMenu = SideMenu(masterViewController: self, menuViewController: menuViewController!)
        sideMenu?.delegate = self
    }
    
    @IBAction func click_left(sender: UIBarButtonItem) {
        sideMenu?.direction = .Left
        sideMenu?.routeToSideMenu()
    }
    @IBAction func click_right(sender: UIBarButtonItem) {
        sideMenu?.direction = .Right
        sideMenu?.routeToSideMenu()
    }
    func sideMenuDidHideMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController) {
        DDLogVerbose("Side Menu Did Hide")
    }
    func sideMenuDidShowMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController) {
        DDLogVerbose("Side Menu Did Show")
    }
}

class MKSideMenuViewController: BaseListViewController, SideMenuProtocol {
    
    struct InnerConst {
        static let CellIdentifier = "MKSideMenuTableViewCell"
        static let SegueToNextSideViewDetail = "MKSideDetailViewController"
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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

class MKSideDetailViewController: BaseViewController {
    private var _viewModel = BaseViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    @IBAction func click_back(sender: UIBarButtonItem) {
        self.routeBack()
    }
}
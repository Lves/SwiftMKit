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
    var sideMenu: SideMenu?
    
    private var _viewModel = MKUISideViewModel()
    override var viewModel: BaseKitViewModel! {
        get { return _viewModel }
    }
    
    override func setupUI() {
        super.setupUI()
        title = "侧滑🐷视图"
        sideMenu = SideMenu(mainVc: self, menuVc: MKUISideTableViewController())
        sideMenu?.delegate = self
        // 禁用滑动返回
        navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        DDLogInfo("显示菜单")
        sideMenu?.routeToSideMenu()
    }
    
    func sideMenuDidHideMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController) {
        DDLogInfo(#function)
    }
}

class MKUISideTableViewController: UITableViewController, SideMenuProtocol {
    var sideMenu: SideMenu?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell?.textLabel?.text = "hello -- \(indexPath.row)"
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        DDLogInfo("选中了第\(indexPath.row)行")
        sideMenu?.routeToSideContainer("SubViewController", params: ["title" : "第\(indexPath.row)行"])
    }
}


class SubViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.greenColor()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        SideMenu.routeToBack(navigationController)
    }
}
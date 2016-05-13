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
    var sideMenu: SideMenu? = SideMenu()
    let screenSize = UIScreen.mainScreen().bounds.size
    let kWindow: UIWindow = UIApplication.sharedApplication().keyWindow!
    
    private var _viewModel = MKUISideViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    let subVc = MKUISideTableViewController()
    var flag = false
    override func setupUI() {
        super.setupUI()
        title = "侧滑🐷视图"
        let v1 = self
        let v2 = MKUISideTableViewController()
        
        sideMenu = SideMenu(mainVc: v1, menuVc: v2)
        sideMenu?.delegate = self
        DDLogInfo("\(sideMenu?.view)")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        DDLogInfo("显示菜单")
        sideMenu?.routeToSideMenu()
        flag = true
    }
    
    func sideMenuDidHideMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController) {
        DDLogInfo("\(sideMenu)   \(menuViewController)")
        DDLogInfo(#function)
    }
}

class MKUISideTableViewController: UITableViewController, SideMenuProtocol {
    var sideMenu: SideMenu?
    let kWindow: UIWindow = UIApplication.sharedApplication().keyWindow!
    let screenSize = UIScreen.mainScreen().bounds.size
    lazy private var coverView: UIControl = UIControl()
    let duration = 0.25
    let menuWidth = UIScreen.mainScreen().bounds.size.width * 0.7
    var menuView: UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.frame = CGRectMake(-screenSize.width * 0.7, 0, screenSize.width * 0.7, screenSize.height)
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
        view.backgroundColor = UIColor.grayColor()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        SideMenu.routeToBack(navigationController)
    }
}
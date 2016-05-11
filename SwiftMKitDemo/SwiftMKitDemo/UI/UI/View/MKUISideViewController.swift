//
//  MKUISideViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/10/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

/// 自定义抽屉
/// 输入参数：MainVC、MenuVc
/// 关系：MainVc.addChildVc(MenuVc)
class MKUISideViewController: BaseViewController {
    private var sideVc: MKUISideTableViewController = MKUISideTableViewController()
    let screenSize = UIScreen.mainScreen().bounds.size
    let kWindow: UIWindow = UIApplication.sharedApplication().keyWindow!
    
    private var _viewModel = MKUISideViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    
    override func setupUI() {
        super.setupUI()
        title = "侧滑视图"
        view.backgroundColor = UIColor.greenColor()
        // 因为懒加载
        DDLogInfo("\(sideVc.view)")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        DDLogInfo("显示菜单")
        sideVc.showMenu()
    }
    
}

class MKUISideTableViewController: UITableViewController {
    let kWindow: UIWindow = UIApplication.sharedApplication().keyWindow!
    let screenSize = UIScreen.mainScreen().bounds.size
    lazy private var coverView: UIControl = UIControl()
    let duration = 0.25
    let menuWidth = UIScreen.mainScreen().bounds.size.width * 0.7
    var menuView: UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        coverView.addTarget(self, action: #selector(coverClick), forControlEvents: UIControlEvents.TouchUpInside)
        coverView.frame = UIScreen.mainScreen().bounds
        coverView.backgroundColor = UIColor.init(r: 0, g: 0, b: 0, a: 0.45)
        tableView.frame = CGRectMake(-screenSize.width * 0.7, 0, screenSize.width * 0.7, screenSize.height)
        coverView.addSubview(tableView)
        menuView = coverView
    }
    
    @objc private func coverClick() {
        DDLogInfo("隐藏菜单")
        hideMenu()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell?.textLabel?.text = "hello -- \(indexPath.row)"
        return cell!
    }
    
    func showMenu() {
        if (self.menuView!.superview == nil) {
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
            kWindow.addSubview(menuView!)
            UIView.animateWithDuration(duration) {
                self.tableView.frame = CGRectMake(0, 0, self.menuWidth, self.screenSize.height)
            }
        }
    }
    
    func hideMenu() {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        UIView.animateWithDuration(duration, animations: {
            self.tableView.frame = CGRectMake(-self.menuWidth, 0, self.menuWidth, self.screenSize.height)
            }) { (flag) in
                self.menuView?.removeFromSuperview()
        }
    }
    
}

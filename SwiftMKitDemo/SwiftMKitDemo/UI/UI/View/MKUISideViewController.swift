//
//  MKUISideViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/10/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

protocol SideMenuProtocol : class {
    var sideMenu: SideMenu { get set }
}

class MKUISideViewController: BaseViewController, SideMenuDelegate {
    var sideMenu: SideMenu?
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
        sideMenu = SideMenu(mainVc: self, menuVc: MKUISideTableViewController())
        sideMenu?.delegate = self
        DDLogInfo("\(sideMenu!.view)")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        DDLogInfo("显示菜单")
        sideMenu!.showMenu()
        flag = true
    }
    
    func sideMenuDidHideMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController) {
        DDLogInfo("\(sideMenu)   \(menuViewController)")
        DDLogInfo(#function)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if flag {
            sideMenu?.showMenu(false)
        }
    }
    
}

class MKUISideTableViewController: UITableViewController {
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
        let nav = UINavigationController(rootViewController: self.instanceViewControllerInXibWithName("BaseWebViewController")!)
        sideMenu?.mainVc?.pushVC(nav)
//         sideMenu?.mainVc?.routeToUrl("https://www.baidu.com")
        sideMenu?.hideMenu(false)
    }
    
}

// MARK: - 弹出菜单

@objc protocol SideMenuDelegate {
    optional func sideMenuDidRecognizePanGesture(sideMenu: SideMenu, recongnizer: UIPanGestureRecognizer)
    optional func sideMenuDidShowMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController)
    optional func sideMenuDidHideMenuViewController(sideMenu: SideMenu, menuViewController: UIViewController)
}

/// 自定义抽屉
/// 输入参数：MainVC、MenuVc
/// 关系：MainVc.addChildVc(MenuVc)
class SideMenu: UIViewController {
//    let kWindow: UIWindow = UIApplication.sharedApplication().keyWindow!
    let screenSize = UIScreen.mainScreen().bounds.size
    lazy private var coverView: UIControl = UIControl()
    let duration = 0.25
    let factor: CGFloat = 0.5
    let menuWidth = UIScreen.mainScreen().bounds.size.width * 0.5
    
    var mainVc:UIViewController?
    var menuVc:UIViewController?
    
    
    weak var delegate: SideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coverView.addTarget(self, action: #selector(coverClick), forControlEvents: UIControlEvents.TouchUpInside)
        coverView.frame = UIScreen.mainScreen().bounds
        coverView.backgroundColor = UIColor.init(r: 0, g: 0, b: 0, a: 0.45)
        menuVc!.view.frame = CGRectMake(-menuWidth, 0, menuWidth, screenSize.height)
//        coverView.addSubview(menuVc!.view)
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(mainVc: UIViewController, menuVc: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.mainVc = mainVc
        self.menuVc = menuVc
        self.menuVc?.setValue(self, forKeyPath: "sideMenu")
        self.menuVc?.setValue(self, forKeyPath: "sideMenu")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showMenu(animated: Bool = true) {
        if (coverView.superview == nil) {
            self.mainVc?.tabBarController?.tabBar.sendSubviewToBack(coverView)
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
            var view = mainVc!.view
            if let tabBar = mainVc?.tabBarController {
                view = tabBar.view
            } else if let nav = mainVc?.navigationController {
                view = nav.view
            }
            view.addSubview(menuVc!.view)
            view.insertSubview(coverView, belowSubview: menuVc!.view)
            if animated {
                UIView.animateWithDuration(duration) {
                    self.menuVc!.view.frame = CGRectMake(0, 0, self.menuWidth, self.screenSize.height)
                }
            } else {
                self.menuVc!.view.frame = CGRectMake(0, 0, self.menuWidth, self.screenSize.height)
            }
        }
    }
    
    func hideMenu(animated: Bool = true) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        if animated {
            UIView.animateWithDuration(duration, animations: {
                self.menuVc!.view.frame = CGRectMake(-self.menuWidth, 0, self.menuWidth, self.screenSize.height)
            }) { (flag) in
                self.coverView.removeFromSuperview()
            }
        } else {
            self.menuVc!.view.frame = CGRectMake(-self.menuWidth, 0, self.menuWidth, self.screenSize.height)
            self.coverView.removeFromSuperview()
        }
    }
    
    @objc private func coverClick() {
        DDLogInfo("隐藏菜单")
        delegate?.sideMenuDidHideMenuViewController?(self, menuViewController: menuVc!)
        hideMenu()
    }

    
    
}

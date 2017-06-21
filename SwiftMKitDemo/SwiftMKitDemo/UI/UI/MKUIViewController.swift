//
//  MKUIViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/29/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit


class MKUIViewController: BaseListViewController {

    @IBOutlet weak var tableView: UITableView!
    var smarterTool = SmarterTool()
    
    struct InnerConst {
        static let CellIdentifier = "MKUITableViewCell"
        static let SegueToNextIQKeyboardManager = "routeToIQKeyboardManager"
        static let SegueToNextSideView = "routeToSideView"
        static let SegueToNextChartView = "routeToChartView"
        static let SegueToPullRefresh = "PullToRefresh"
        static let SegueToNextKeyboardView = "routeToKeyboardView"
        static let SegueToNextSegmentViewController = "routeToSegmentViewController"
        static let SegueToNextGesturePasswordView = "routeToGesturePassword"
        static let SegueToNextIndicatorButtonView = "routeToIndicatorButton"
        static let SegueToNextGalaryCollectionView = "routeToGalaryCollectionView"
        static let SegueToNextTreeView = "routeToTreeView"
        
        static let SegueToNextCustomAlertView = "routeToCustomAlertViewController"
        static let SegueToNextCoverFlowView = "routeToCoverFlowView"
        static let SegueToNextOrderTableView = "MKUIOrderTableViewController"

    }
    
    fileprivate var _viewModel = MKUIViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    override var listView: UIScrollView! {
        get { return tableView }
    }
    
    override func setupUI() {
        super.setupUI()
        c -= 1
//<<<<<<< HEAD
        smarterTool.attach(toView: UIApplication.shared.keyWindow!)
//=======
//        smarterTool.delegate = self
//        smarterTool.attachToView(UIApplication.sharedApplication().keyWindow!)
//>>>>>>> 42a2df262acc59698acb7c00b2a72b884167feec
    }
    var c: Int = 1
    
    override func setupNavigation() {
        super.setupNavigation()
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func getCell(withTableView tableView: UITableView, indexPath: IndexPath) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCell(withIdentifier: InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: InnerConst.CellIdentifier)
        }
        return cell
    }
    override func configureCell(_ tableViewCell: UITableViewCell, object: Any, indexPath: IndexPath) {
        if let model = object as? MKDataListModel {
            tableViewCell.textLabel?.text = model.title
            tableViewCell.detailTextLabel?.text = model.detail
        }
    }
    override func didSelectCell(_ tableViewCell: UITableViewCell, object: Any, indexPath: IndexPath) {
        if let model = object as? MKDataListModel {
            if model.route?.hasPrefix("http") == true {
                self.route(toUrl: model.route ?? "")
                return
            } else {
                self.route(toName: model.route ?? "", storyboardName: model.routeSB)
                return
            }
        }
    }
    
    
    func routeToEvnSwitch() {
        // FIXME: 跳转
//        UIViewController.topController?.routeToName("CrashLogViewController")
    }
    
}

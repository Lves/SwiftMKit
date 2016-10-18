//
//  MKUIViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/29/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKUIViewController: BaseListViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    
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
    
    private var _viewModel = MKUIViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    override var listView: UIScrollView! {
        get { return tableView }
    }
    
    override func setupNavigation() {
        super.setupNavigation()
        self.navigationController?.navigationBar.translucent = false
    }
    
    override func getCellWithTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: InnerConst.CellIdentifier)
        }
        return cell
    }
    override func configureCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        if let model = object as? MKDataListModel {
            tableViewCell.textLabel?.text = model.title
            tableViewCell.detailTextLabel?.text = model.detail
        }
    }
    override func didSelectCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        if let model = object as? MKDataListModel {
            if model.route?.hasPrefix("http") == true {
                self.routeToUrl(model.route ?? "")
                return
            } else {
                self.routeToName(model.route ?? "", storyboardName: model.routeSB)
                return
            }
            switch indexPath.row {
            case 7:
                self.routeToName(InnerConst.SegueToNextIndicatorButtonView)
            case 12:
                self.routeToName(InnerConst.SegueToPullRefresh)
            default:
                break
            }
        }
    }
    
}

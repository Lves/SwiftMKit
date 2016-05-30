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
        static let SegueToNextKeyboardView = "routeToKeyboardView"
        static let SegueToNextSegmentViewController = "routeToSegmentViewController"
        static let SegueToNextGesturePasswordView = "routeToGesturePassword"
        static let SegueToNextIndicatorButtonView = "routeToIndicatorButton"
        static let SegueToNextGalaryCollectionView = "routeToGalaryCollectionView"
        static let SegueToNextTreeView = "routeToTreeView"
        
        static let SegueToNextCustomAlertView = "routeToCustomAlertViewController"
        static let SegueToNextUrl = "http://www.baidu.com"
    }
    
    private var _viewModel = MKUIViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    override var listView: UIScrollView! {
        get { return tableView }
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
        switch indexPath.row {
        case 0:
            self.routeToUrl(InnerConst.SegueToNextUrl)
        case 1:
            self.routeToName(InnerConst.SegueToNextIQKeyboardManager)
        case 2:
            self.routeToName(InnerConst.SegueToNextSideView)
        case 3:
            self.routeToName(InnerConst.SegueToNextChartView)
        case 4:
            self.routeToName(InnerConst.SegueToNextKeyboardView)
        case 5:
            self.routeToName(InnerConst.SegueToNextSegmentViewController)
        case 6:
            self.routeToName(InnerConst.SegueToNextGesturePasswordView)
        case 7:
            self.routeToName(InnerConst.SegueToNextIndicatorButtonView)
        case 8:
            self.hidesBottomBarWhenPushed = true
            self.routeToName(InnerConst.SegueToNextGalaryCollectionView)
        case 9:
            self.hidesBottomBarWhenPushed = true
            self.routeToName(InnerConst.SegueToNextTreeView)
        case 10:
        self.routeToName(InnerConst.SegueToNextCustomAlertView)
        default:
            break
        }
    }
    
}

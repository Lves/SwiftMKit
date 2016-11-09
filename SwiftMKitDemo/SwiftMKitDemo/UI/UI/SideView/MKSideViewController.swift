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

class MKSideViewController: BaseViewController, MKSideMenuViewControllerDelegate {
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    private var _viewModel = BaseKitViewModel()
    override var viewModel: BaseKitViewModel! {
        get { return _viewModel }
    }
    
    override func setupUI() {
        super.setupUI()
        slideInTransitioningDelegate.statusBarHidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? MKSideMenuViewController {
            if segue.identifier == "Left" {
                slideInTransitioningDelegate.direction = .left
            } else if segue.identifier == "Right" {
                slideInTransitioningDelegate.direction = .right
            }
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.delegate = self
            controller.modalPresentationStyle = .Custom
        }
    }
    
    func sideMenuViewController(controller: MKSideMenuViewController, didSelectRow selectedRow: Int) {
        self.dismissVC(completion: {_ in self.routeToName("routeToDetail") })
    }
}



protocol MKSideMenuViewControllerDelegate: class {
    func sideMenuViewController(controller: MKSideMenuViewController, didSelectRow selectedRow: Int)
}

class MKSideMenuViewController: BaseListViewController {
    
    struct InnerConst {
        static let CellIdentifier = "MKSideMenuTableViewCell"
        static let SegueToNextSideViewDetail = "MKSideDetailViewController"
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    weak var delegate: MKSideMenuViewControllerDelegate?
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
        delegate?.sideMenuViewController(self, didSelectRow: indexPath.row)
    }
}
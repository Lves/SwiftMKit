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
    
    fileprivate var _viewModel = BaseKitViewModel()
    override var viewModel: BaseKitViewModel! {
        get { return _viewModel }
    }
    
    override func setupUI() {
        super.setupUI()
        slideInTransitioningDelegate.statusBarHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? MKSideMenuViewController {
            if segue.identifier == "Left" {
                slideInTransitioningDelegate.direction = .left
            } else if segue.identifier == "Right" {
                slideInTransitioningDelegate.direction = .right
            }
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.delegate = self
            controller.modalPresentationStyle = .custom
        }
    }
    
    func sideMenuViewController(_ controller: MKSideMenuViewController, didSelectRow selectedRow: Int) {
        let _ = self.dismissVC(completion: {_ in self.routeToName("routeToDetail") })
    }
}



protocol MKSideMenuViewControllerDelegate: class {
    func sideMenuViewController(_ controller: MKSideMenuViewController, didSelectRow selectedRow: Int)
}

class MKSideMenuViewController: BaseListViewController {
    
    struct InnerConst {
        static let CellIdentifier = "MKSideMenuTableViewCell"
        static let SegueToNextSideViewDetail = "MKSideDetailViewController"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    weak var delegate: MKSideMenuViewControllerDelegate?
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var _viewModel = BaseListViewModel()
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
        listViewModel.dataArray = [1 as AnyObject,2 as AnyObject,3 as AnyObject,4 as AnyObject,5 as AnyObject,6 as AnyObject,7 as AnyObject,8 as AnyObject,9 as AnyObject,10 as AnyObject]
        tableView.reloadData()
    }
    
    override func getCellWithTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCell(withIdentifier: InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: InnerConst.CellIdentifier)
        }
        return cell
    }
    override func configureCell(_ tableViewCell: UITableViewCell, object: AnyObject, indexPath: IndexPath) {
        tableViewCell.textLabel?.text = "Menu - \(indexPath.row)"
    }
    override func didSelectCell(_ tableViewCell: UITableViewCell, object: AnyObject, indexPath: IndexPath) {
        delegate?.sideMenuViewController(self, didSelectRow: indexPath.row)
    }
}

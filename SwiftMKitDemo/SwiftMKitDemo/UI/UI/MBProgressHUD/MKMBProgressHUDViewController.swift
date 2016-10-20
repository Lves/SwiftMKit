//
//  MKMBProgressHUDViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 18/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import MBProgressHUD

class MKMBProgressHUDViewController: BaseListViewController {
    
    struct InnerConst {
        static let CellIdentifier = "MKMBProgressHUDTableViewCell"
    }
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
        self.title = "MBProgress HUD"
        loadData()
    }
    override func loadData() {
        super.loadData()
        listViewModel.dataArray = [
            "Indeterminate mode",
            "With label",
            "With details label",
            "Determinate mode",
            "Determinate custom mode",
            "Annular determinate mode",
            "Bar determinate mode",
            "Text only",
            "Text at bottom",
            "Custom view",]
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
        if let text = object as? String {
            tableViewCell.textLabel?.text = text
        }
    }
    override func didSelectCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            self.showLoading()
            Async.main(after: 1) { [weak self] in
                self?.hideLoading()
            }
        case 1:
            self.showLoading("Loading...")
            Async.main(after: 1) { [weak self] in
                self?.hideLoading()
            }
        case 2:
            self.showLoading("Loading...", detailText: "Parsing data\n(1/1)")
            Async.main(after: 1) { [weak self] in
                self?.hideLoading()
            }
        case 3:
            self.showProgress("Loading...")
            Async.background { [weak self] in
                var progress: Float = 0.0
                while progress < 1.0 {
                    progress += 0.01
                    Async.main {
                        self?.changeProgress(progress)
                    }
                    usleep(500)
                }
                Async.main {
                    self?.hideLoading()
                }
            }
        case 4:
            self.showProgress("Loading...", detailText: "", view: self.view, cancelEnable: true, cancelButtonTitle: "取消")
            Async.background { [weak self] in
                var progress: Float = 0.0
                while progress < 1.0 {
                    progress += 0.01
                    Async.main {
                        self?.changeProgress(progress)
                    }
                    usleep(500)
                }
                Async.main {
                    self?.hideLoading()
                }
            }
        case 5:
            self.showProgressAnnularDeterminate("Loading...", detailText: "", view: self.view, cancelEnable: true, cancelButtonTitle: "取消")
            Async.background { [weak self] in
                var progress: Float = 0.0
                while progress < 1.0 {
                    progress += 0.01
                    Async.main {
                        self?.changeProgress(progress)
                    }
                    usleep(500)
                }
                Async.main {
                    self?.hideLoading()
                }
            }
        case 6:
            self.showProgressHorizontalBar("Loading...", detailText: "", view: self.view, cancelEnable: true, cancelButtonTitle: "取消")
            Async.background { [weak self] in
                var progress: Float = 0.0
                while progress < 1.0 {
                    progress += 0.01
                    Async.main {
                        self?.changeProgress(progress)
                    }
                    usleep(500)
                }
                Async.main {
                    self?.hideLoading()
                }
            }
        case 7:
            self.showTip("Message here!")
        case 8:
            self.showTip("Message here!", view: self.view, offset: CGPoint(x: 0, y: MBProgressMaxOffset), completion: {})
        case 9:
            self.showTip("Done", image: UIImage(named: "icon_hud_checkmark"))
        default:
            break
        }
    }

    
}

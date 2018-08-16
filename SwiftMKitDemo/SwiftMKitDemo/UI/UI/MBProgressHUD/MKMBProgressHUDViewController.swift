//
//  MKMBProgressHUDViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 18/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftMKit

class MKMBProgressHUDViewController: BaseListViewController {
    
    struct InnerConst {
        static let CellIdentifier = "MKMBProgressHUDTableViewCell"
    }
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
        self.title = "MBProgress HUD"
        loadData()
    }
    override func loadData() {
        super.loadData()
        listViewModel.dataArray = [
            "Indeterminate mode" as AnyObject,
            "With label" as AnyObject,
            "With details label" as AnyObject,
            "Determinate mode" as AnyObject,
            "Determinate custom mode" as AnyObject,
            "Annular determinate mode" as AnyObject,
            "Bar determinate mode" as AnyObject,
            "Text only" as AnyObject,
            "Text at bottom" as AnyObject,
            "Custom view" as AnyObject,]
        tableView.reloadData()
    }
    
    override func getCell(withTableView tableView: UITableView, indexPath: IndexPath) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCell(withIdentifier: InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: InnerConst.CellIdentifier)
        }
        return cell
    }
    override func configureCell(_ tableViewCell: UITableViewCell, object: Any, indexPath: IndexPath) {
        if let text = object as? String {
            tableViewCell.textLabel?.text = text
        }
    }
    override func didSelectCell(_ tableViewCell: UITableViewCell, object: Any, indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.showLoading()
            Async.main(after: 1) { [weak self] in
                self?.hideLoading()
            }
        case 1:
            self.showLoading(text: "Loading...")
            Async.main(after: 1) { [weak self] in
                self?.hideLoading()
            }
        case 2:
            self.showLoading(text: "Loading...", detailText: "Parsing data\n(1/1)")
            Async.main(after: 1) { [weak self] in
                self?.hideLoading()
            }
        case 3:
            self.showProgress(inView: self.view, text: "Loading...")
            Async.background { [weak self] in
                var progress: Float = 0.0
                while progress < 1.0 {
                    progress += 0.01
                    Async.main {
                        self?.changeProgress(progress)
                    }
                    usleep(500)
                }
                let _ = Async.main {
                    self?.hideLoading()
                }
            }
        case 4:
            self.showProgress(inView: self.view, text: "Loading...", cancelEnable: true, cancelTitle: "取消")
            Async.background { [weak self] in
                var progress: Float = 0.0
                while progress < 1.0 {
                    progress += 0.01
                    Async.main {
                        self?.changeProgress(progress)
                    }
                    usleep(500)
                }
                let _ = Async.main {
                    self?.hideLoading()
                }
            }
        case 5:
            self.showProgress(inView: self.view, text: "Loading...", detailText: "", cancelEnable: true, cancelTitle: "取消", type: .annularDeterminate)
            let _ = Async.background { [weak self] in
                var progress: Float = 0.0
                while progress < 1.0 {
                    progress += 0.01
                    let _ = Async.main {
                        self?.changeProgress(progress)
                    }
                    usleep(500)
                }
                let _ = Async.main {
                    self?.hideLoading()
                }
            }
        case 6:
            self.showProgress(inView: self.view, text: "Loading...", detailText: "", cancelEnable: true, cancelTitle: "取消", type: .determinateHorizontalBar)
            let _ = Async.background { [weak self] in
                var progress: Float = 0.0
                while progress < 1.0 {
                    progress += 0.01
                    let _ = Async.main {
                        self?.changeProgress(progress)
                    }
                    usleep(500)
                }
                let _ = Async.main {
                    self?.hideLoading()
                }
            }
        case 7:
            self.showTip("Message here!")
        case 8:
            self.showTip(inView: self.view, text: "Message here!", offset: CGPoint(x: 0, y: MBProgressMaxOffset), completion: {})
        case 9:
            self.showTip(inView: self.view, text: "Done", image: UIImage(named: "icon_hud_checkmark"))
        default:
            break
        }
    }

    
}

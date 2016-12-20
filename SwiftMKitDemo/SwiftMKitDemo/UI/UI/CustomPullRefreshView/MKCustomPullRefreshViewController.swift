//
//  MKUIPullRefresh.swift
//  SwiftMKitDemo
//
//  Created by LiXingLe on 16/7/18.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import MJRefresh

class MKCustomPullRefreshViewController: BaseListViewController{
    
    
    struct InnerConst {
        static let CellIdentifier = "MKCustomPullRefreshTableViewCell"
    }

    @IBOutlet weak var tableView: UITableView!
    fileprivate var _viewModel = MKCustomPullRefreshViewModel()
    override var viewModel: MKCustomPullRefreshViewModel!{
        get { return _viewModel }
    }
    override var listView: UIScrollView! {
        get { return tableView }
    }
    override var listViewType: ListViewType {
        get { return .refreshOnly }
    }
    override func setupUI() {
        super.setupUI()
        self.title = "Pull Refresh View"
        tableView.tableFooterView = UIView()
        
        let header = LLGifHeader(refreshingBlock: { [weak self] in
            self?.listViewModel?.dataIndex = 0
            self?.listViewModel?.fetchData()
        })
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.stateLabel.isHidden = true
        self.listView.mj_header = header
    
        loadData()
    }
    override func loadData() {
        super.loadData()
        self.tableView.mj_header.beginRefreshing()
    }
    
    override func getCell(withTableView tableView: UITableView, indexPath: IndexPath) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCell(withIdentifier: InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: InnerConst.CellIdentifier)
        }
        return cell
    }
    override func configureCell(_ tableViewCell: UITableViewCell, object: Any, indexPath: IndexPath) {
        tableViewCell.textLabel?.text = "Cell - \(indexPath.row)"
    }
    override func didSelectCell(_ tableViewCell: UITableViewCell, object: Any, indexPath: IndexPath) {
        
    }

}


class MKCustomPullRefreshViewModel: BaseListViewModel {
    
    override func fetchData() {
        Async.main(after: 1) { [weak self] in
            self?.updateDataArray(["Cell" as AnyObject,"Cell" as AnyObject,"Cell" as AnyObject])
            self?.listViewController.endListRefresh()
        }
    }
}


class LLGifHeader: MJRefreshGifHeader
{
    override func prepare() {
        super.prepare()
        //普通状态动画
        var IdleImages = [AnyObject]()
        for index in 0..<8 {
            let str = index%2==0 ? "a" : "b"
            if let nextImage = UIImage(named: "password_loading_\(str)"){
                IdleImages.append(nextImage)
            }
        }
        self.setImages(IdleImages, for: .idle)
        
        //正在刷新状态动画
        self.setImages(IdleImages, for: .refreshing)
    }
}















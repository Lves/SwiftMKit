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
    private var _viewModel = MKCustomPullRefreshViewModel()
    override var viewModel: MKCustomPullRefreshViewModel!{
        get { return _viewModel }
    }
    override var listView: UIScrollView! {
        get { return tableView }
    }
    override var listViewType: ListViewType {
        get { return .RefreshOnly }
    }
    override func setupUI() {
        super.setupUI()
        self.title = "Pull Refresh View"
        tableView.tableFooterView = UIView()
        
        let header = LLGifHeader(refreshingBlock: { [weak self] in
            self?.listViewModel?.dataIndex = 0
            self?.listViewModel?.fetchData()
        })
        header.lastUpdatedTimeLabel.hidden = true
        header.stateLabel.hidden = true
        self.listView.mj_header = header
    
        loadData()
    }
    override func loadData() {
        super.loadData()
        self.tableView.mj_header.beginRefreshing()
    }
    
    override func getCellWithTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: InnerConst.CellIdentifier)
        }
        return cell
    }
    override func configureCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        tableViewCell.textLabel?.text = "Cell - \(indexPath.row)"
    }
    override func didSelectCell(tableViewCell: UITableViewCell, object: AnyObject, indexPath: NSIndexPath) {
        
    }

}


class MKCustomPullRefreshViewModel: BaseListViewModel {
    
    override func fetchData() {
        Async.main(after: 1) { [weak self] in
            self?.updateDataArray(["Cell","Cell","Cell"])
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
        self.setImages(IdleImages, forState: .Idle)
        
        //正在刷新状态动画
        self.setImages(IdleImages, forState: .Refreshing)
    }
}















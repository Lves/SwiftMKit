//
//  MKUIPullRefresh.swift
//  SwiftMKitDemo
//
//  Created by LiXingLe on 16/7/18.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import MJRefresh

class MKUIPullRefresh: BaseListViewController{
    
    
    struct InnerConst {
        static let CellIdentifier = "Cell"
    }

    @IBOutlet weak var tableView: UITableView!
    private var _viewModel = MKUIPullRefreshViewModel()
    override var viewModel: BaseKitViewModel!{
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
        
    
        
        tableView.snp_remakeConstraints { (make) in
            make.top.bottom.left.right.equalTo(0)
        }
        tableView.tableFooterView = UIView()
        
        
        self.listView.mj_header = self.llListViewHeaderWithRefreshingBlock {
            [weak self] in
            self?.listViewModel?.dataIndex = 0
            self?.listViewModel?.fetchData()
        }
        
        
        
    
        loadData()
    }
    override func loadData() {
        super.loadData()
        
        self.tableView.mj_header.beginRefreshing()
        
        
    }
    func llListViewHeaderWithRefreshingBlock(refreshingBlock:MJRefreshComponentRefreshingBlock)->MJRefreshHeader{
        let header = LLGifHeader(refreshingBlock: refreshingBlock)
        header.lastUpdatedTimeLabel.hidden = true
        header.stateLabel.hidden = true
        return header
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















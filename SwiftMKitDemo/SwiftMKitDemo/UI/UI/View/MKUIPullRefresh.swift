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
        
        //下拉刷新添加时间
        if let refreshHeader = listView.mj_header as? LLRefreshHeader {
            refreshHeader.lastUpdatedTimeText = { data in
                let format = NSDateFormatter()
                format.dateFormat = "MM-dd HH:mm"
                let str = format.stringFromDate(data)
                return "数据已于\(str) 更新"
            }
        }
        
        
    
        loadData()
    }
    override func loadData() {
        super.loadData()
        
        self.tableView.mj_header.beginRefreshing()
        
        
    }
    func llListViewHeaderWithRefreshingBlock(refreshingBlock:MJRefreshComponentRefreshingBlock)->MJRefreshHeader{
        let header = LLRefreshHeader(refreshingBlock: refreshingBlock)
        header.activityIndicatorViewStyle = .Gray
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







class LLRefreshHeader: MJRefreshNormalHeader {
    var tipLabel:UILabel?
    
    
    override func placeSubviews() {
        super.placeSubviews()
        
        self.lastUpdatedTimeLabel.mj_h = self.arrowView.mj_h
        self.lastUpdatedTimeLabel.mj_y = self.arrowView.mj_y
        self.stateLabel.textColor = UIColor.clearColor()
        
    }
    
    
}
















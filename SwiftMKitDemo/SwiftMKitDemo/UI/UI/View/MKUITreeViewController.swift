//
//  MKUITreeViewController.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/5/26.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

class MKUITreeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    struct InnerConst {
        static let CellName = "MKUITreeViewCellTableViewCell"
        static let CellID = "MKUITreeViewCellTableViewCell"
    }
}

class TreeTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    struct InnerConst {
        static let CellName = "MKUITreeViewCellTableViewCell"
        static let CellID = "MKUITreeViewCellTableViewCell"
        static let CellIndentationWidth: CGFloat = 30
    }
    /// 数据源
    var dataArray: [Node]? {
        willSet {
            if let data = dataArray {
                for node in data {
                    if node.expand {
                        tmpDataArray?.append(node)
                    }
                }
            }
        }
    }
    /// 保存需要展开的节点模型
    var tmpDataArray: [Node]?
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: .Grouped)
        setup()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }
    
    func setup() {
        // 设置代理
        dataSource = self
        delegate = self
        // 注册cell
        self.registerNib(UINib(nibName: InnerConst.CellName, bundle:nil), forCellReuseIdentifier: InnerConst.CellID)
    }
    
    // MARK: - <TableViewDelegate>
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tmpDataArray?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = dequeueReusableCellWithIdentifier(InnerConst.CellID)!
        let node = tmpDataArray![indexPath.row]
        // 缩进
        cell.indentationLevel = node.depth
        cell.indentationWidth = InnerConst.CellIndentationWidth
        cell.textLabel?.text = node.name
        return cell
    }
}

class Node {
    var parentId: Int
    var nodeId: Int
    var name: String
    var depth: Int
    var expand: Bool
    var children: [Node]?
    
    init(parentId: Int, nodeId: Int, name: String, depth: Int, expand: Bool, children: [Node]?) {
        self.parentId = parentId
        self.nodeId = nodeId
        self.name = name
        self.depth = depth
        self.expand = expand
        self.children = children
    }
}

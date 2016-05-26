//
//  MKUITreeViewController.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/5/26.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

class MKUITreeViewController: UIViewController {
    @IBOutlet weak var tableView: TreeTableView!
    var dataArray: [Node]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        tableView.dataArray = dataArray
        automaticallyAdjustsScrollViewInsets = false
        tableView.separatorStyle = .None
    }
    
    func setupData() {
        // 初始化静态数据
        let tianchao = Node(parentId: -1, nodeId: 0, name: "Tian Chao", depth: 0, expand: true, children: nil)
        let shiyan = Node(parentId: 0, nodeId: 1, name: "Shi Yan", depth: 1, expand: false, children: nil)
        let beijing = Node(parentId: 0, nodeId: 2, name: "Bei Jing", depth: 1, expand: false, children: nil)
        let shanghai = Node(parentId: 0, nodeId: 3, name: "Shang Hai", depth: 1, expand: false, children: nil)
        tianchao.children = [shiyan, beijing, shanghai]
        
        let usa = Node(parentId: -1, nodeId: 4, name: "USA", depth: 0, expand: true, children: nil)
        let luoshanji = Node(parentId: 4, nodeId: 5, name: "Luo Shan Ji", depth: 1, expand: false, children: nil)
        let dezhou = Node(parentId: 4, nodeId: 6, name: "De Zhou", depth: 1, expand: false, children: nil)
        usa.children = [luoshanji, dezhou]
        
        let japan = Node(parentId: -1, nodeId: 7, name: "Japan", depth: 0, expand: true, children: nil)
        let dongjing = Node(parentId: 7, nodeId: 8, name: "Dong Jing", depth: 1, expand: false, children: nil)
        japan.children = [dongjing]
        
        let sanpang = Node(parentId: -1, nodeId: 9, name: "San Pang", depth: 0, expand: true, children: nil)
        dataArray = [tianchao, shiyan, beijing, shanghai, usa, luoshanji, dezhou, japan, dongjing, sanpang]
    }
    
    deinit {
        DDLogError("我走了 : \(NSStringFromClass(self.dynamicType))")
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
            if let data = newValue {
                var list: [Node] = []
                for node in data {
                    if node.expand {
                        list.append(node)
                    }
                }
                tmpDataArray = list
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
//        self.registerNib(UINib(nibName: InnerConst.CellName, bundle:nil), forCellReuseIdentifier: InnerConst.CellID)
//        self.registerClass(MKUITreeViewCellTableViewCell.self, forCellReuseIdentifier: InnerConst.CellID)
    }
    
    // MARK: - <TableViewDelegate>
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tmpDataArray?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = dequeueReusableCellWithIdentifier(InnerConst.CellID) as! MKUITreeViewCellTableViewCell
        let node = tmpDataArray![indexPath.row]
        let isParentNode = node.parentId == -1
        let cell = MKUITreeViewCellTableViewCell.getCell(tableView, isParentNode: isParentNode)
        if !isParentNode {
            // 找出 parentNode
            let filterArray = tmpDataArray?.filter({ obj -> Bool in
                obj.nodeId == node.parentId
            })
            cell.parentNode = filterArray?.first
        }
        cell.node = node
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: 代理，让调用方知道点击的是哪个
        let parentNode = tmpDataArray![indexPath.row]
        let startPosition = indexPath.row + 1
        var endPosition = startPosition
        var expand = false
        for node in dataArray! {
            if node.parentId == parentNode.nodeId {
                node.expand = !node.expand
                if node.expand {
                    tmpDataArray?.insert(node, atIndex: endPosition)
                    expand = true
                    endPosition += 1
                } else {
                    expand = false
                    endPosition = removeAllNodesAtParentNode(parentNode)
                    break
                }
            }
        }
        
        var indexPathArray: [NSIndexPath] = []
        for i in startPosition ..< endPosition {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            indexPathArray.append(indexPath)
        }
        
        if expand {
            insertRowsAtIndexPaths(indexPathArray, withRowAnimation: .None)
        } else {
            deleteRowsAtIndexPaths(indexPathArray, withRowAnimation: .None)
        }
    }
    
    // MARK: - 删除当前节点下的所有子节点
    func removeAllNodesAtParentNode(parentNode: Node) -> Int {
        let startPosition = (tmpDataArray! as NSArray).indexOfObject(parentNode)
        var endPosition = startPosition
        
        for i in (startPosition + 1) ..< tmpDataArray!.count {
            let node = tmpDataArray![i]
            endPosition += 1
            if node.depth <= parentNode.depth {
                break
            }
            
            if endPosition == tmpDataArray!.count - 1 {
                endPosition += 1
                node.expand = false
                break
            }
            
            node.expand = false
        }
        if endPosition > startPosition {
            let range = NSMakeRange(startPosition + 1, endPosition - startPosition - 1)
            let list: NSArray = tmpDataArray! as NSArray
            let listM: NSMutableArray = NSMutableArray(array: list)
            listM.removeObjectsInRange(range)
            tmpDataArray?.removeAll()
            for obj in listM {
                tmpDataArray?.append(obj as! Node)
            }
        }
        return endPosition
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

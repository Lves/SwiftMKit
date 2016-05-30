//
//  MKUITreeViewController.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/5/26.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

class MKUITreeViewController: UIViewController, TreeTableViewDelegate {
    @IBOutlet weak var tableView: TreeTableView!
    @IBOutlet weak var containerView: UIView!
    private var containerVc: ContainerTableViewController? {
        get {
            return (self.childViewControllers.first) as? ContainerTableViewController
        }
    }

    var dataArray: [Node]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        tableView.dataArray = dataArray
        automaticallyAdjustsScrollViewInsets = false
        tableView.separatorStyle = .None
        // 设置代理
        tableView.tt_delegate = self
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
        let dongjing2 = Node(parentId: 7, nodeId: 10, name: "Dong Jing2", depth: 1, expand: false, children: nil)
        let dongjing3 = Node(parentId: 7, nodeId: 11, name: "Dong Jing3", depth: 1, expand: false, children: nil)
        let dongjing4 = Node(parentId: 7, nodeId: 12, name: "Dong Jing4", depth: 1, expand: false, children: nil)
        let dongjing5 = Node(parentId: 7, nodeId: 13, name: "Dong Jing5", depth: 1, expand: false, children: nil)
        let dongjing6 = Node(parentId: 7, nodeId: 14, name: "Dong Jing6", depth: 1, expand: false, children: nil)
        let dongjing7 = Node(parentId: 7, nodeId: 15, name: "Dong Jing7", depth: 1, expand: false, children: nil)
        let dongjing8 = Node(parentId: 7, nodeId: 16, name: "Dong Jing8", depth: 1, expand: false, children: nil)
        let dongjing9 = Node(parentId: 7, nodeId: 17, name: "Dong Jing9", depth: 1, expand: false, children: nil)
        let dongjing10 = Node(parentId: 7, nodeId: 18, name: "Dong Jing10", depth: 1, expand: false, children: nil)
        japan.children = [dongjing, dongjing2, dongjing3, dongjing4, dongjing5, dongjing6, dongjing7, dongjing8, dongjing9, dongjing10]
        
        let sanpang = Node(parentId: -1, nodeId: 9, name: "San Pang", depth: 0, expand: true, children: nil)
        dataArray = [tianchao, shiyan, beijing, shanghai, usa, luoshanji, dezhou, japan, dongjing, sanpang, dongjing2, dongjing3, dongjing4, dongjing5, dongjing6, dongjing7, dongjing8, dongjing9, dongjing10]
    }
    
    deinit {
        DDLogError("我走了 : \(NSStringFromClass(self.dynamicType))")
    }
    
    // MARK: - <TreeTableViewDelegate>
    func tableView(treeTableView: TreeTableView, didSelectRowAtIndexPath indexPath: NSIndexPath, node: Node) {
        DDLogInfo("选中了第 \(indexPath.row) 行，值是 \(node.name)")
    }
}

public protocol TreeTableViewDelegate: class {
    func tableView(treeTableView: TreeTableView, didSelectRowAtIndexPath indexPath: NSIndexPath, node: Node);
}

public extension TreeTableViewDelegate {
    public func tableView(treeTableView: TreeTableView, didSelectRowAtIndexPath indexPath: NSIndexPath, node: Node){}
}

public class TreeTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    struct InnerConst {
        static let CellName = "MKUITreeViewCellTableViewCell"
        static let CellID = "MKUITreeViewCellTableViewCell"
        static let Duration = 0.25
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
    var startIndex = 0
    var expandNodeCount = 0
    
    weak var tt_delegate: TreeTableViewDelegate?
    
    public override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: .Grouped)
        setup()
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }
    
    func setup() {
        // 设置代理
        dataSource = self
        delegate = self
    }
    
    // MARK: - <TableViewDelegate>
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tmpDataArray?.count ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let node = tmpDataArray![indexPath.row]
        let isParentNode = node.parentId == -1
        let cell = MKUITreeViewCellTableViewCell.getCell(tableView, isParentNode: isParentNode)
        if !isParentNode {
            // 找出 parentNode
            let filterArray = tmpDataArray?.filter({ obj -> Bool in
                obj.nodeId == node.parentId
            })
            cell.parentNode = filterArray?.first
        } else {
            let lastParentNode = tmpDataArray?.filter({ (obj) -> Bool in
                obj.parentId == -1
            }).last
            cell.imgLastArrow.hidden = !(lastParentNode!.nodeId == node.nodeId)
        }
        cell.node = node
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: 代理，让调用方知道点击的是哪个
        let parentNode = tmpDataArray![indexPath.row]
        if let handle = tt_delegate {
            handle.tableView(self, didSelectRowAtIndexPath: indexPath, node: parentNode)
        }
        let startPosition = indexPath.row + 1
        var endPosition = startPosition
        var expand = false
//        for node in dataArray! {
//            if node.parentId == parentNode.nodeId {
//                node.expand = !node.expand
//                if node.expand {
//                    tmpDataArray?.insert(node, atIndex: endPosition)
//                    expand = true
//                    endPosition += 1
//                } else {
//                    expand = false
//                    endPosition = removeAllNodesAtParentNode(parentNode)
//                    break
//                }
//            }
//        }
        if let children = parentNode.children {
            if children.first!.expand {
                // 折叠节点
                expand = false
                startIndex = (tmpDataArray! as NSArray).indexOfObject(parentNode)
                expandNodeCount += (startIndex + 1)
                endPosition = calcExpandNodesCountAtParentNode(parentNode)
                // 删除被折叠的元素
                for _ in startIndex + 1 ..< endPosition {
                    tmpDataArray?.removeAtIndex(startIndex + 1)
                }
                // 重置状态
                startIndex = 0
                expandNodeCount = 0
            } else {
                // 展开节点
                expand = true
                for node in children {
                    tmpDataArray?.insert(node, atIndex: endPosition)
                    endPosition += 1
                    node.expand = true
                }
            }
        }
        
        var indexPathArray: [NSIndexPath] = []
        for i in startPosition ..< endPosition {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            indexPathArray.append(indexPath)
        }
        // 旋转箭头
        if expand {
            insertRowsAtIndexPaths(indexPathArray, withRowAnimation: .None)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! MKUITreeViewCellTableViewCell
            guard let imgArrow = cell.imgArrow else {
                return
            }
            UIView.animateWithDuration(InnerConst.Duration) {
                imgArrow.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            }
        } else {
            deleteRowsAtIndexPaths(indexPathArray, withRowAnimation: .None)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! MKUITreeViewCellTableViewCell
            guard let imgArrow = cell.imgArrow else {
                return
            }
            UIView.animateWithDuration(InnerConst.Duration) {
                imgArrow.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI * 2))
            }
        }
    }
    
    // MARK: - 计算某个节点下展开的所有子节点数量
    func calcExpandNodesCountAtParentNode(parentNode: Node) -> Int {
        // 递归删除该节点下的所有子节点
        for node in parentNode.children! {
            expandNodeCount += 1
            node.expand = false
            guard let children = node.children where children.count > 0 && children.first!.expand else {
                continue
            }
            calcExpandNodesCountAtParentNode(node)
            
//            if let children = node.children {
//                if children.count > 0 && children.first!.expand {
//                    removeAllNodesAtParentNode(node)
//                }
//            }
        }
        return expandNodeCount
    }
    
//    func removeAllNodesAtParentNode(parentNode: Node) -> Int {
//        let startPosition = (tmpDataArray! as NSArray).indexOfObject(parentNode)
//        var endPosition = startPosition
//        
//        for i in (startPosition + 1) ..< tmpDataArray!.count {
//            let node = tmpDataArray![i]
//            endPosition += 1
//            if node.depth <= parentNode.depth {
//                break
//            }
//            
//            if endPosition == tmpDataArray!.count - 1 {
//                endPosition += 1
//                node.expand = false
//                break
//            }
//            
//            node.expand = false
//        }
//        if endPosition > startPosition {
//            let range = NSMakeRange(startPosition + 1, endPosition - startPosition - 1)
//            let list: NSArray = tmpDataArray! as NSArray
//            let listM: NSMutableArray = NSMutableArray(array: list)
//            listM.removeObjectsInRange(range)
//            tmpDataArray?.removeAll()
//            for obj in listM {
//                tmpDataArray?.append(obj as! Node)
//            }
//        }
//        return endPosition
//    }
}

// MARK: - 模型：Node
public class Node {
    var parentId: Int
    var nodeId: Int
    var name: String
    var depth: Int
    var expand: Bool
    var children: [Node]?
    
    public init(parentId: Int, nodeId: Int, name: String, depth: Int, expand: Bool, children: [Node]?) {
        self.parentId = parentId
        self.nodeId = nodeId
        self.name = name
        self.depth = depth
        self.expand = expand
        self.children = children
    }
}


// MARK: - ContainerTableViewController
class ContainerTableViewController: UITableViewController {
    
    
    var dataArray:[String: String]?
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContainerTableViewCell")!
        return cell
    }
}

class ContainerTableViewCell: UITableViewCell {
    @IBOutlet weak var lblLeft: UILabel!
    @IBOutlet weak var lblRight: UILabel!
}

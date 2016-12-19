//
//  MKUITreeViewController.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/5/26.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

class MKTreeViewController: BaseViewController, TreeTableViewDelegate {
    @IBOutlet weak var tableView: TreeTableView!
    @IBOutlet weak var containerView: UIView!
    fileprivate var containerVc: MKTreeContainerTableViewController? {
        get {
            return (self.childViewControllers.first) as? MKTreeContainerTableViewController
        }
    }

    var dataArray: [MKTreeViewNode]?
    
    override func setupUI() {
        super.setupUI()
        loadData()
        tableView.dataArray = dataArray
        automaticallyAdjustsScrollViewInsets = false
        tableView.separatorStyle = .none
        // 设置代理
        tableView.tt_delegate = self
        
        setupContainerViewData()
    }
    
    override func loadData() {
        super.loadData()
        // 初始化静态数据
        let tianchao = MKTreeViewNode(parentId: -1, nodeId: 0, name: "Tian Chao", depth: 0, expand: true, children: nil)
        let shiyan = MKTreeViewNode(parentId: 0, nodeId: 1, name: "Shi Yan", depth: 1, expand: false, children: nil)
        let beijing = MKTreeViewNode(parentId: 0, nodeId: 2, name: "Bei Jing", depth: 1, expand: false, children: nil)
        let shanghai = MKTreeViewNode(parentId: 0, nodeId: 3, name: "Shang Hai", depth: 1, expand: false, children: nil)
        tianchao.children = [shiyan, beijing, shanghai]
        
        let usa = MKTreeViewNode(parentId: -1, nodeId: 4, name: "USA", depth: 0, expand: true, children: nil)
        let luoshanji = MKTreeViewNode(parentId: 4, nodeId: 5, name: "Luo Shan Ji", depth: 1, expand: false, children: nil)
        let dezhou = MKTreeViewNode(parentId: 4, nodeId: 6, name: "De Zhou", depth: 1, expand: false, children: nil)
        usa.children = [luoshanji, dezhou]
        
        let japan = MKTreeViewNode(parentId: -1, nodeId: 7, name: "Japan", depth: 0, expand: true, children: nil)
        let dongjing = MKTreeViewNode(parentId: 7, nodeId: 8, name: "Dong Jing", depth: 1, expand: false, children: nil)
        let dongjing2 = MKTreeViewNode(parentId: 7, nodeId: 10, name: "Dong Jing2", depth: 1, expand: false, children: nil)
        let dongjing3 = MKTreeViewNode(parentId: 7, nodeId: 11, name: "Dong Jing3", depth: 1, expand: false, children: nil)
        let dongjing4 = MKTreeViewNode(parentId: 7, nodeId: 12, name: "Dong Jing4", depth: 1, expand: false, children: nil)
        let dongjing5 = MKTreeViewNode(parentId: 7, nodeId: 13, name: "Dong Jing5", depth: 1, expand: false, children: nil)
        let dongjing6 = MKTreeViewNode(parentId: 7, nodeId: 14, name: "Dong Jing6", depth: 1, expand: false, children: nil)
        let dongjing7 = MKTreeViewNode(parentId: 7, nodeId: 15, name: "Dong Jing7", depth: 1, expand: false, children: nil)
        let dongjing8 = MKTreeViewNode(parentId: 7, nodeId: 16, name: "Dong Jing8", depth: 1, expand: false, children: nil)
        let dongjing9 = MKTreeViewNode(parentId: 7, nodeId: 17, name: "Dong Jing9", depth: 1, expand: false, children: nil)
        let dongjing10 = MKTreeViewNode(parentId: 7, nodeId: 18, name: "Dong Jing10", depth: 1, expand: false, children: nil)
        japan.children = [dongjing, dongjing2, dongjing3, dongjing4, dongjing5, dongjing6, dongjing7, dongjing8, dongjing9, dongjing10]
        
        let sanpang = MKTreeViewNode(parentId: -1, nodeId: 9, name: "San Pang", depth: 0, expand: true, children: nil)
        dataArray = [tianchao, shiyan, beijing, shanghai, usa, luoshanji, dezhou, japan, dongjing, sanpang, dongjing2, dongjing3, dongjing4, dongjing5, dongjing6, dongjing7, dongjing8, dongjing9, dongjing10]
    }
    
    func setupContainerViewData() {
        let data = [
            ["key左1" : "value右1"],
            ["key左2" : "value右2"],
            ["key左3" : "value右3"],
            ["key左4" : "value右4"],
            ["key左5" : "value右5"]
        ]
        containerVc?.dataArray = data
        containerView.h = CGFloat(44 * data.count + 0)
    }
    
    // MARK: - <TreeTableViewDelegate>
    func tableView(_ treeTableView: TreeTableView, didSelectRowAtIndexPath indexPath: IndexPath, node: MKTreeViewNode) {
        DDLogInfo("选中了第 \(indexPath.row) 行，值是 \(node.name)")
    }
}

public protocol TreeTableViewDelegate: class {
    func tableView(_ treeTableView: TreeTableView, didSelectRowAtIndexPath indexPath: IndexPath, node: MKTreeViewNode);
}

public extension TreeTableViewDelegate {
    public func tableView(_ treeTableView: TreeTableView, didSelectRowAtIndexPath indexPath: IndexPath, node: MKTreeViewNode){}
}

open class TreeTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    struct InnerConst {
        static let CellName = "MKUITreeViewCellTableViewCell"
        static let CellID = "MKUITreeViewCellTableViewCell"
        static let Duration = 0.25
    }
    /// 数据源
    var dataArray: [MKTreeViewNode]? {
        willSet {
            if let data = newValue {
                var list: [MKTreeViewNode] = []
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
    var tmpDataArray: [MKTreeViewNode]?
    var startIndex = 0
    var expandNodeCount = 0
    
    weak var tt_delegate: TreeTableViewDelegate?
    
    public override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: .grouped)
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
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tmpDataArray?.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = tmpDataArray![indexPath.row]
        let isParentNode = node.parentId == -1
        let cell = MKUITreeViewCellTableViewCell.getCell(tableView, isParentNode: isParentNode)
        if !isParentNode {  // 不是父节点
            // 找出 parentNode
            let filterArray = tmpDataArray?.filter({ obj -> Bool in
                obj.nodeId == node.parentId
            })
            cell.parentNode = filterArray?.first
        } else {    // 是父节点
            let lastParentNode = tmpDataArray?.filter({ (obj) -> Bool in
                obj.parentId == -1
            }).last
            cell.imgLastArrow.isHidden = !(lastParentNode!.nodeId == node.nodeId)
        }
        cell.node = node
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
                startIndex = (tmpDataArray! as NSArray).index(of: parentNode)
                expandNodeCount += (startIndex + 1)
                endPosition = calcExpandNodesCountAtParentNode(parentNode)
                // 删除被折叠的元素
                for _ in startIndex + 1 ..< endPosition {
                    tmpDataArray?.remove(at: startIndex + 1)
                }
                // 重置状态
                startIndex = 0
                expandNodeCount = 0
            } else {
                // 展开节点
                expand = true
                for node in children {
                    tmpDataArray?.insert(node, at: endPosition)
                    endPosition += 1
                    node.expand = true
                }
            }
        }
        
        var indexPathArray: [IndexPath] = []
        for i in startPosition ..< endPosition {
            let indexPath = IndexPath(row: i, section: 0)
            indexPathArray.append(indexPath)
        }
        // 旋转箭头
        if expand {
            insertRows(at: indexPathArray, with: .none)
            let cell = tableView.cellForRow(at: indexPath) as! MKUITreeViewCellTableViewCell
            guard let imgArrow = cell.imgArrow else {
                return
            }
            UIView.animate(withDuration: InnerConst.Duration, animations: {
                imgArrow.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            }) 
        } else {
            deleteRows(at: indexPathArray, with: .none)
            let cell = tableView.cellForRow(at: indexPath) as! MKUITreeViewCellTableViewCell
            guard let imgArrow = cell.imgArrow else {
                return
            }
            UIView.animate(withDuration: InnerConst.Duration, animations: {
                imgArrow.transform = CGAffineTransform(rotationAngle: -CGFloat(M_PI * 2))
            }) 
        }
    }
    
    // MARK: - 计算某个节点下展开的所有子节点数量
    func calcExpandNodesCountAtParentNode(_ parentNode: MKTreeViewNode) -> Int {
        // 递归删除该节点下的所有子节点
        for node in parentNode.children! {
            expandNodeCount += 1
            node.expand = false
            guard let children = node.children, children.count > 0 && children.first!.expand else {
                continue
            }
            _ = calcExpandNodesCountAtParentNode(node)
            
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
open class MKTreeViewNode {
    var parentId: Int
    var nodeId: Int
    var name: String
    var depth: Int
    var expand: Bool
    var children: [MKTreeViewNode]?
    
    public init(parentId: Int, nodeId: Int, name: String, depth: Int, expand: Bool, children: [MKTreeViewNode]?) {
        self.parentId = parentId
        self.nodeId = nodeId
        self.name = name
        self.depth = depth
        self.expand = expand
        self.children = children
    }
}


// MARK: - ContainerTableViewController
class MKTreeContainerTableViewController: UITableViewController {
    // 数据源
    var dataArray:[[String: String]]? {
        didSet {
            // 刷新表格
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MKTreeContainerTableViewCell") as! MKTreeContainerTableViewCell
        let data = dataArray![indexPath.row]
        for (key, value) in data {
            cell.lblLeft.text = "\(key)"
            cell.lblRight.text = "\(value)"
        }
        return cell
    }
}

class MKTreeContainerTableViewCell: UITableViewCell {
    @IBOutlet weak var lblLeft: UILabel!
    @IBOutlet weak var lblRight: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(colorLiteralRed: 35/255.0, green: 39/255.0, blue: 57/255.0, alpha: 1.0)
        lblLeft.textColor = UIColor.lightText
        lblRight.textColor = UIColor.white
    }
}

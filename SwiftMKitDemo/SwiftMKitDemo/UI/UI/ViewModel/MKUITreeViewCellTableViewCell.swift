//
//  MKUITreeViewCellTableViewCell.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/5/26.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

class MKUITreeViewCellTableViewCell: UITableViewCell {
    var parentNode: Node?
    var node: Node? {
        willSet {
            if lblName != nil {
                lblName.text = newValue!.name
                indentationLevel = newValue!.depth
                indentationWidth = 30
                if imgPoint != nil {
                    imgPoint.hidden = newValue!.parentId != -1
                }
                
                // 判断是否需要设置圆角
                if let fatherNode = parentNode {
                    if let children = fatherNode.children {
                        var maskPath: UIBezierPath = UIBezierPath()
                        // FIXME: 宽度计算！！！
                        bgView.w = UIScreen.mainScreen().bounds.size.width - 39 - 15
                        if children.count == 1 {
                            // 上下左右四个圆角
                            maskPath = UIBezierPath(roundedRect: bgView.bounds, byRoundingCorners: .AllCorners, cornerRadii: CGSizeMake(InnerConst.CornerRadius, InnerConst.CornerRadius))
                        } else {
                            if newValue?.nodeId == children.first?.nodeId {  // 第一个cell 上边需要圆角
                                maskPath = UIBezierPath(roundedRect: bgView.bounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSizeMake(InnerConst.CornerRadius, InnerConst.CornerRadius))
                            } else if newValue?.nodeId == children.last?.nodeId {  // 最后一个cell 下边需要圆角
                                maskPath = UIBezierPath(roundedRect: bgView.bounds, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: CGSizeMake(InnerConst.CornerRadius, InnerConst.CornerRadius))
                            } else {
                                maskPath = UIBezierPath(roundedRect: bgView.bounds, byRoundingCorners: .AllCorners, cornerRadii: CGSizeZero)
                            }
                        }
                        let maskLayer = CAShapeLayer()
                        maskLayer.frame = bgView.bounds
                        maskLayer.path = maskPath.CGPath
                        bgView.layer.mask = maskLayer
                    }
                } else {
                    guard let children = newValue!.children where children.count > 0 else {
                        DDLogError("\(newValue!.name) 没有子节点")
                        imgArrow.hidden = true
                        return
                    }
                    // 这里可以正常使用children变量
                }
            }
        }
    }
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgPoint: UIImageView!
    @IBOutlet weak var lineView_V: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var imgLastArrow: UIImageView!
    
    weak var lbl: UILabel?
    
    @IBOutlet weak var lblName_LeftConstraint: NSLayoutConstraint!
    
    struct InnerConst {
        static let CellID_Parent = "ParentCell"
        static let CellID_Sub = "SubCell"
        static let NibName = "MKUITreeViewCellTableViewCell"
        static let CornerRadius: CGFloat = 7
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
    }
    
    class func getCell(tableView: UITableView, isParentNode: Bool) -> MKUITreeViewCellTableViewCell {
        let ID = isParentNode ? InnerConst.CellID_Parent : InnerConst.CellID_Sub
        var cell = tableView.dequeueReusableCellWithIdentifier(ID) as? MKUITreeViewCellTableViewCell
        if cell == nil {
            let index = isParentNode ? 0 : 1
            cell = NSBundle.mainBundle().loadNibNamed(InnerConst.NibName, owner: nil, options: nil)[index] as? MKUITreeViewCellTableViewCell
        }
        return cell!
    }
    
}

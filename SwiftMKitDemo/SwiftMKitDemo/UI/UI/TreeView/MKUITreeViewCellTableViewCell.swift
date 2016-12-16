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
    var parentNode: MKTreeViewNode?
    var node: MKTreeViewNode? {
        willSet {
            if lblName != nil {
                lblName.text = newValue!.name
                indentationLevel = newValue!.depth
                indentationWidth = 30
                if imgPoint != nil {
                    imgPoint.isHidden = newValue!.parentId != -1
                }
                
                // 判断是否需要设置圆角
                if let fatherNode = parentNode {
                    if let children = fatherNode.children {
                        var maskPath: UIBezierPath = UIBezierPath()
                        // FIXME: 宽度计算！！！
                        bgView.w = UIScreen.main.bounds.size.width - 39 - 15
                        if children.count == 1 {
                            // 上下左右四个圆角
                            maskPath = UIBezierPath(roundedRect: bgView.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: InnerConst.CornerRadius, height: InnerConst.CornerRadius))
                        } else {
                            if newValue?.nodeId == children.first?.nodeId {  // 第一个cell 上边需要圆角
                                maskPath = UIBezierPath(roundedRect: bgView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: InnerConst.CornerRadius, height: InnerConst.CornerRadius))
                            } else if newValue?.nodeId == children.last?.nodeId {  // 最后一个cell 下边需要圆角
                                maskPath = UIBezierPath(roundedRect: bgView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: InnerConst.CornerRadius, height: InnerConst.CornerRadius))
                            } else {
                                maskPath = UIBezierPath(roundedRect: bgView.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize.zero)
                            }
                        }
                        let maskLayer = CAShapeLayer()
                        maskLayer.frame = bgView.bounds
                        maskLayer.path = maskPath.cgPath
                        bgView.layer.mask = maskLayer
                    }
                } else {
                    guard let children = newValue!.children, children.count > 0 else {
                        imgArrow.isHidden = true
                        return
                    }
                    // 这里可以正常使用children变量
                    imgArrow.isHidden = false
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
        self.selectionStyle = .none
        contentView.backgroundColor = UIColor(colorLiteralRed: 240/255.0, green: 243/255.0, blue: 252/255.0, alpha: 1.0)
    }
    
    class func getCell(_ tableView: UITableView, isParentNode: Bool) -> MKUITreeViewCellTableViewCell {
        let ID = isParentNode ? InnerConst.CellID_Parent : InnerConst.CellID_Sub
        var cell = tableView.dequeueReusableCell(withIdentifier: ID) as? MKUITreeViewCellTableViewCell
        if cell == nil {
            let index = isParentNode ? 0 : 1
            cell = Bundle.main.loadNibNamed(InnerConst.NibName, owner: nil, options: nil)![index] as? MKUITreeViewCellTableViewCell
        }
        return cell!
    }
    
}

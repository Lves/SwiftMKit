//
//  File: MyOptionalEditTableViewCell.swift
//  Project: Fund
//  Description:
//  Author: cheny
//  Date: 16/9/17
//  Version:
//  Copyright © 2016年 pintec. All rights reserved.
//

import UIKit

class MKUIOrderTableViewModel: NSObject {
    var name: String?
    var code: String?
    var value: String?
    var isSelect: Bool = false
}

class MKUIOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblRight: UILabel!
    
    var imgEdit = UIImageView(image: UIImage(named: "order_cell_unselected"))
    
    var model = MKUIOrderTableViewModel() {
        didSet {
            lblName.text = model.name
            lblCode.text = model.code
            lblRight.text = model.value
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //自定义选中图像
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            self.addSubview(imgEdit)
        }
        imgEdit.image = model.isSelect ? UIImage(named: "order_cell_selected") : UIImage(named: "order_cell_unselected")
        imgEdit.center = CGPointMake(-CGRectGetWidth(imgEdit.frame) * 0.5, CGRectGetHeight(self.bounds) * 0.5)
        imgEdit.frame.size = CGSizeMake(19, 19)
        setCustomImageViewCenter(CGPointMake(20.5, CGRectGetHeight(bounds) * 0.5), alpha: 1.0, animated: animated)
    }
    
    func setCustomImageViewCenter(pt: CGPoint, alpha: CGFloat, animated: Bool) {
        if animated {
            let options = UIViewAnimationOptions.CurveEaseOut
            UIView.animateWithDuration(0.3, delay: 0.0, options: options, animations: { [weak self] _ in
                self?.imgEdit.center = pt
                self?.imgEdit.alpha = alpha
                }, completion: nil)
        } else {
            imgEdit.center = pt
            imgEdit.alpha = alpha
        }
    }
}

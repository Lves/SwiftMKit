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

class MKOrderViewModel: NSObject {
    var name: String?
    var code: String?
    var value: String?
    var isSelect: Bool = false
}

class MKOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblRight: UILabel!
    
    var imgEdit = UIImageView(image: UIImage(named: "order_cell_unselected"))
    
    var model = MKOrderViewModel() {
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
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            self.addSubview(imgEdit)
        }
        imgEdit.image = model.isSelect ? UIImage(named: "order_cell_selected") : UIImage(named: "order_cell_unselected")
        imgEdit.center = CGPoint(x: -imgEdit.frame.width * 0.5, y: self.bounds.height * 0.5)
        imgEdit.frame.size = CGSize(width: 19, height: 19)
        setCustomImageViewCenter(CGPoint(x: 20.5, y: bounds.height * 0.5), alpha: 1.0, animated: animated)
    }
    
    func setCustomImageViewCenter(_ pt: CGPoint, alpha: CGFloat, animated: Bool) {
        if animated {
            let options = UIViewAnimationOptions.curveEaseOut
            UIView.animate(withDuration: 0.3, delay: 0.0, options: options, animations: { [weak self] in
                self?.imgEdit.center = pt
                self?.imgEdit.alpha = alpha
                }, completion: nil)
        } else {
            imgEdit.center = pt
            imgEdit.alpha = alpha
        }
    }
}

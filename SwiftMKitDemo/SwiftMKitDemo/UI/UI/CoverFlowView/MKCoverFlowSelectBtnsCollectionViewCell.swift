//
//  MKSelectBtnsCollectionViewCell.swift
//  SwiftMKitDemo
//
//  Created by Mao on 18/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

enum MKCoverFlowSelectBtnCellType: Int {
    case Normal
    case Disabled
    case Selected
}
class MKCoverFlowSelectBtnsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblNumber: UILabel!
    var type : MKCoverFlowSelectBtnCellType? {
        didSet {
            if type == .Normal {
                self.imageView.image = nil
                self.lblNumber.textColor = UIColor(hex6: 0xFD734C)
            } else if type == .Disabled {
                self.imageView.image = nil
                self.lblNumber.textColor = UIColor(hex6: 0x969CA4)
            }else if type == .Selected {
                self.imageView.image = UIImage(named: "coverflow_btn_select")
                self.lblNumber.textColor = UIColor(hex6: 0xFFFFFF)
            }
        }
    }
}

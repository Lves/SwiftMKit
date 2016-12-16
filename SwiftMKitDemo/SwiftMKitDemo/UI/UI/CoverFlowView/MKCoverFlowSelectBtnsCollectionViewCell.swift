//
//  MKSelectBtnsCollectionViewCell.swift
//  SwiftMKitDemo
//
//  Created by Mao on 18/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

enum MKCoverFlowSelectBtnCellType: Int {
    case normal
    case disabled
    case selected
}
class MKCoverFlowSelectBtnsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblNumber: UILabel!
    var type : MKCoverFlowSelectBtnCellType? {
        didSet {
            if type == .normal {
                self.imageView.image = nil
                self.lblNumber.textColor = UIColor(hex6: 0xFD734C)
            } else if type == .disabled {
                self.imageView.image = nil
                self.lblNumber.textColor = UIColor(hex6: 0x969CA4)
            }else if type == .selected {
                self.imageView.image = UIImage(named: "coverflow_btn_select")
                self.lblNumber.textColor = UIColor(hex6: 0xFFFFFF)
            }
        }
    }
}

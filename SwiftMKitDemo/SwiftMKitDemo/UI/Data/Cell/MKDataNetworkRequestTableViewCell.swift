//
//  MKDataNetworkRequestTableViewCell.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/18/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKDataNetworkRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var imgHead: UIImageView!
    @IBOutlet weak var imgPic: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var constraintImagePicAspect: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imgPic.image = nil
        aspectConstraint = nil
    }
    
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                imgPic.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                imgPic.addConstraint(aspectConstraint!)
            }
        }
    }
    func setPostImage(image : UIImage) {
        
        let aspect = image.size.width / image.size.height
        constraintImagePicAspect.setMultiplier(aspect)
        imgPic.image = image
    }


}

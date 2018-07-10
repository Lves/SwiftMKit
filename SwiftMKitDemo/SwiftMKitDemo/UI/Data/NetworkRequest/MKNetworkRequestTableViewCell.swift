//
//  MKDataNetworkRequestTableViewCell.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/18/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Haneke

class MKNetworkRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var imgPic: HQImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var constraintImageHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imgPic.image = nil
    }

    var newsModel: NewsModel? {
        didSet {
            self.lblTitle?.text = newsModel?.title
            self.lblContent?.text = newsModel?.abstract
            if let imageUrl = newsModel?.image_url {
                self.imgPic.hnk_setImageFromURL(URL(string: imageUrl)!, placeholder: UIImage(named:"icon_user_head"))
                self.imgPic.imageViewHighQualitySrc = imageUrl
            } else {
                self.imgPic.image = nil
                self.imgPic.imageViewHighQualitySrc = nil
                self.constraintImageHeight.constant = 1
                self.setNeedsLayout()
            }
        }
    }
}

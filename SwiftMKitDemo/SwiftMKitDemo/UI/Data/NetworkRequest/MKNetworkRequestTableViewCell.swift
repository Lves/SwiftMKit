//
//  MKDataNetworkRequestTableViewCell.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/18/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Kingfisher

class MKNetworkRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var imgPic: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblComments: UILabel!
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
            guard let newsModel = newsModel else { return }
            self.lblTitle?.text = newsModel.title
            self.lblContent?.text = newsModel.digest + "..."
            if let imageUrl = newsModel.imgsrc {
                self.imgPic.kf.setImage(with: URL(string: imageUrl)!, placeholder: UIImage(named: "default_image"))
            } else {
                self.imgPic.image = nil
                self.constraintImageHeight.constant = 0
                self.setNeedsLayout()
            }
            self.lblTime.text = newsModel.displayTime
            self.lblComments.text = "\(newsModel.displayCommentCount)跟帖"
        }
    }
    
}

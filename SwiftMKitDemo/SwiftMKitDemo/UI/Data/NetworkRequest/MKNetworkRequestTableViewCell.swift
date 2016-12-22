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

    @IBOutlet weak var imgHead: UIImageView!
    @IBOutlet weak var imgPic: HQImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var constraintImagePicAspect: NSLayoutConstraint!
    
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
    func setPostImage(_ image : UIImage) {
        let aspect = image.size.width / image.size.height
        constraintImagePicAspect.constant = aspect
        setNeedsLayout()
        imgPic.image = image
    }

    var photoModel: PX500PopularPhotoModel? {
        didSet {
            self.lblTitle?.text = photoModel?.name
            self.lblContent?.text = photoModel?.descriptionString
            self.imgHead.hnk_setImageFromURL(URL(string: (photoModel?.userpic)!)!, placeholder: UIImage(named:"icon_user_head"))
            if let imageUrl = photoModel?.imageurl {
                imgPic.imageViewHighQualitySrc = imageUrl
                self.imgPic.hnk_setImageFromURL(URL(string: imageUrl)!, placeholder:UIImage(named:"view_default_loading"), format: Format<UIImage>(name: "original")) {
                    [weak self] image in
                    self?.setPostImage(image)
                    self?.layoutIfNeeded()
                }
            }else {
                self.imgPic.image = nil
            }
        }
    }
    
    var photoEntity: PX500PhotoEntity? {
        didSet {
            self.lblTitle?.text = photoEntity?.name
            self.lblContent?.text = photoEntity?.descriptionString
            self.imgHead.hnk_setImageFromURL(URL(string: (photoEntity?.user?.userPicUrl)!)!, placeholder: UIImage(named:"icon_user_head"))
            if let imageUrl = photoEntity?.imageUrl {
                self.imgPic.hnk_setImageFromURL(URL(string: imageUrl)!, placeholder:UIImage(named:"view_default_loading"), format: Format<UIImage>(name: "original")) {
                    [weak self] image in
                    self?.setPostImage(image)
                    self?.layoutIfNeeded()
                }
            }else {
                self.imgPic.image = nil
            }
        }
    }
}

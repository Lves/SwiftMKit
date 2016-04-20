//
//  MKDataNetworkWithImagesViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/4/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Alamofire
import CocoaLumberjack
import ReactiveCocoa
import Haneke

class MKDataNetworkRequestDetailViewController: BaseViewController {
    var photoId: String?
    
    @IBOutlet weak var imgHead: UIImageView!
    @IBOutlet weak var imgPic: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var constraintImgPicAspect: NSLayoutConstraint!
    
    private var _viewModel = MKDataNetworkRequestDetailViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    
    override func setupUI() {
        super.setupUI()
        self.title = "Photo Detail"
        self.lblName.text = ""
        self.lblContent.text = ""
        loadData()
    }
    override func loadData() {
        super.loadData()
        _viewModel.fetchData()
    }
    override func bindingData() {
        _viewModel.photo.producer.startWithNext { [weak self] model in
            if let photo = model {
                self?.imgPic.hnk_setImageFromURL(NSURL(string: photo.imageurl!)!, placeholder:UIImage(named:"view_default_loading"), format: Format<UIImage>(name: "original")) {
                    image in
                    let aspect = image.size.width / image.size.height
                    self?.constraintImgPicAspect.setMultiplier(aspect)
                    self?.imgPic.image = image
                }
                self?.imgHead.hnk_setImageFromURL(NSURL(string: (photo.userpic)!)!, placeholder: UIImage(named:"icon_user_head"))
                self?.lblName.text = photo.username
                self?.lblContent.text = photo.descriptionString
            }
        }
    }
}
extension NSLayoutConstraint {
        
        func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
            
            let newConstraint = NSLayoutConstraint(
                item: firstItem,
                attribute: firstAttribute,
                relatedBy: relation,
                toItem: secondItem,
                attribute: secondAttribute,
                multiplier: multiplier,
                constant: constant)
            
            newConstraint.priority = priority
            newConstraint.shouldBeArchived = self.shouldBeArchived
            newConstraint.identifier = self.identifier
            newConstraint.active = self.active
            
            NSLayoutConstraint.deactivateConstraints([self])
            NSLayoutConstraint.activateConstraints([newConstraint])
            return newConstraint
        }
}
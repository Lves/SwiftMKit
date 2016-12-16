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

class MKNetworkRequestDetailViewController: BaseViewController {
    var photoId: String?
    
    @IBOutlet weak var imgHead: UIImageView!
    @IBOutlet weak var imgPic: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var constraintImgPicAspect: NSLayoutConstraint!
    
    fileprivate var _viewModel = MKNetworkRequestDetailViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    
    override func setupUI() {
        super.setupUI()
        self.title = "Detail"
        self.lblName.text = ""
        self.lblContent.text = ""
        self.btnLike.isHidden = true
        loadData()
    }
    override func loadData() {
        super.loadData()
        _viewModel.fetchData()
    }
    override func bindingData() {
        super.bindingData()
        _viewModel.photo.producer.startWithNext { [weak self] model in
            if let photo = model {
                self?.imgPic.hnk_setImageFromURL(NSURL(string: photo.imageurl!)!, placeholder:UIImage(named:"view_default_loading"), format: Format<UIImage>(name: "original")) {
                    image in
                    let aspect = image.size.width / image.size.height
                    self?.constraintImgPicAspect.setMultiplier(aspect)
                    self?.imgPic.image = image
                }
                self?.imgPic.hnk_setImageFromURL(NSURL(string: photo.imageurl!)!, placeholder:UIImage(named:"view_default_loading"), format: Format<UIImage>(name: "original"))
                self?.imgHead.hnk_setImageFromURL(NSURL(string: (photo.userpic)!)!, placeholder: UIImage(named:"icon_user_head"))
                self?.lblName.text = photo.username
                self?.lblContent.text = photo.descriptionString
                self?.btnLike.hidden = false
            }
        }
        _viewModel.isLike.producer.startWithNext { [weak self] isLike in
            self?.btnLike.selected = isLike
        }
        self.btnLike.addTarget(_viewModel.actionLike.toCocoaAction, action: CocoaAction.selector, forControlEvents: .TouchUpInside)
    }
}

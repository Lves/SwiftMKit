//
//  HQImageView.swift
//  SwiftMKitDemo
//
//  Created by HeLi on 16/12/21.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

class HQImageView: UIImageView {
    
    var imageViewHighQualitySrc: String?
    let transition = HQPopAnimator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    override init(image: UIImage?) {
        super.init(image: image)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        setupUI()
    }
    
    func setupUI() {
        self.isUserInteractionEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showHighQualityImage(recoginzer:)))
        self.addGestureRecognizer(tap)
    }
    
    func showHighQualityImage(recoginzer: UITapGestureRecognizer) {
        if recoginzer.numberOfTouches != 1 {
            return
        }
        let imageUrls = self.superview?.subviews
            .filter {
                $0 is HQImageView && (($0 as! HQImageView).imageViewHighQualitySrc?.length ?? 0) > 0
            }.map{
                ($0 as! HQImageView).imageViewHighQualitySrc!
            }
        let index = imageUrls?.indexesOf(imageViewHighQualitySrc ?? "").first ?? 0
        
        let imageModels : [HQImageModel] = (self.superview?.subviews
            .filter {
                $0 is HQImageView && (($0 as! HQImageView).imageViewHighQualitySrc?.length ?? 0) > 0
            }.map{
                let imgev = ($0 as! HQImageView)
                return HQImageModel(image: imgev.image, imageUrl: imgev.imageViewHighQualitySrc!, imageType: .PNG, originFrame :(imgev.superview?.convert(imgev.frame, to: nil)))
            })!
        
        let hqvc : HQImageViewController = HQImageViewController(imageModels: imageModels, selectedIndex: index)
        hqvc.view.frame = (self.getViewController()?.view.bounds)!
        hqvc.transitioningDelegate = self //设置过渡代理
        self.getViewController()?.presentVC(hqvc)
    }
}

extension HQImageView : UIViewControllerTransitioningDelegate{
    
    //Present的时候 使用自定义的动画
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = true
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}

public enum HQImageType : Int {
    case PNG
}

// MARK: - 模型：HQImageModel
public class HQImageModel{
    
    var image: UIImage?
    var imageUrl: String?
    var imageType: HQImageType
    var originFrame: CGRect
    
    public init(image: UIImage?, imageUrl:String? = "", imageType:HQImageType ,originFrame: CGRect?) {
        self.image = image
        self.imageUrl = imageUrl
        self.imageType = imageType
        self.originFrame = originFrame ?? CGRect.zero
    }
}

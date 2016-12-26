//
//  HQImageViewController.swift
//  SwiftMKitDemo
//
//  Created by HeLi on 16/12/21.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import SnapKit
import Haneke

public class HQImageViewController: BaseKitViewController {

    var imageModels: [HQImageModel] = []
    var selectedIndex : Int = 0
    var lastSelectedIndex : Int = 0
    var scrollView : UIScrollView!
    var pageControl: UIPageControl!
    var imageCount : Int {
        get {
            return imageModels.count
        }
    }
    
    struct InnerConst {
        static let pageControlColor : UIColor = UIColor(hex6: 0x768EAF)
        static let pageControlCurColor : UIColor = UIColor(hex6: 0xFFFFFF)
        static let zoomViewTag : Int = 200
    }
    
    init(imageModels: [HQImageModel] ,selectedIndex: Int) {
        self.imageModels = imageModels
        self.selectedIndex = selectedIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func setupUI() {
        
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.backgroundColor = UIColor.black
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: (self.screenW * CGFloat(imageCount)), height: 0)
        self.view.addSubview(scrollView)
        
        pageControl = UIPageControl(frame: CGRect.zero)
        pageControl.numberOfPages = imageCount
        pageControl.currentPageIndicatorTintColor = InnerConst.pageControlCurColor
        pageControl.pageIndicatorTintColor = InnerConst.pageControlColor
        
        self.view.addSubview(pageControl)
        pageControl.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(self.view).offset(-70)
            maker.width.equalTo(100)
            maker.height.equalTo(30)
            maker.centerX.equalTo(self.view.snp.centerX)
        }
        self.view.layoutIfNeeded()
        
        scrollView.setContentOffset(CGPoint(x: (CGFloat)(selectedIndex) * self.screenW, y: 0), animated: false)
        pageControl.currentPage = selectedIndex
        pageControl.isHidden = true
        
        for i in 1...imageModels.count{ //loading the images
            let imageModel : HQImageModel = imageModels[i-1]
            let imageUrl : String = imageModel.imageUrl ?? ""
            let x = CGFloat(i - 1) * self.screenW
            let image = imageModel.image ?? UIImage(named: "appicon")
            
            let zoomView = HQZoomView(frame: CGRect(x: x, y: 0, w: self.screenW, h: self.screenH))
            zoomView.tag = InnerConst.zoomViewTag + i - 1
            zoomView.isUserInteractionEnabled = true
            zoomView.delegate = self
            zoomView.imageView?.hnk_setImageFromURL(URL(string: imageUrl)!, placeholder: image, format: Format<UIImage>(name: "original"), failure: nil, success: { (image) in
                zoomView.image = image
            })
            scrollView.addSubview(zoomView)
        }
        
        Async.main(after: 0.25) { _ in
            if self.imageModels.count > 1 {
                self.pageControl.isHidden = false
            }
        }
    }
    
    func dismissView(recoginzer: UITapGestureRecognizer) {
        self.pageControl.isHidden = true
        self.dismissVC(completion: nil)
    }
}

extension HQImageViewController : UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = self.screenW
        let offsetX = scrollView.contentOffset.x
        let index = (offsetX + width / 2) / width
        pageControl.currentPage = Int(index)
        selectedIndex = Int(index)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //恢复上一张图片
        if lastSelectedIndex != selectedIndex {
            if let zoomView : HQZoomView = self.scrollView.viewWithTag(InnerConst.zoomViewTag + lastSelectedIndex) as? HQZoomView {
                zoomView.reset()
            }
            lastSelectedIndex = selectedIndex
        }
    }
}

extension HQImageViewController : HQZoomViewDelegate {
    public func hqzv_singleTapClick(tap: UITapGestureRecognizer){
        scrollView.backgroundColor = UIColor.clear
        self.dismissView(recoginzer: tap)
    }
}


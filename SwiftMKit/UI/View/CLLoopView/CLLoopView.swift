//
//  CLLoopView.swift
//  CLLoopScrollView
//
//  Created by Chris on 16/1/4.
//  Copyright © 2016年 ChrisLian. All rights reserved.
//

import UIKit
import Kingfisher

public protocol CLLoopViewDelegate{
    func selectLoopViewPage(idx:Int);
}

public class CLLoopView: UIView,UIScrollViewDelegate {
    
    //MARK: - setter & getter
    private var timer:Timer?       = nil
    private let pageControl:UIPageControl   = UIPageControl()
    private let loopScrollView:UIScrollView = UIScrollView()
    private let imageView0:UIImageView = UIImageView()
    private let imageView1:UIImageView = UIImageView()
    private let imageView2:UIImageView = UIImageView()
    
    public var delegate:CLLoopViewDelegate? = nil
    
    /// 页面之间的间距
    public var pageMargin:CGFloat = 10
    public var subPageTopMargin:CGFloat = 10
    public var subPageWidth:CGFloat = 20
    
    /// 当前页
    public var currentPage:Int = 0
    /// 定时跳转到下一页
    public var timeInterval:TimeInterval = 3{
        willSet{
            if autoShow{
                self.stopTimer()
            }
        }
        didSet{
            if autoShow{
                self.startTimer()
            }
        }
    }
    /// 是否定时跳转到下一页
    public var autoShow:Bool = false{
        didSet{
            if autoShow{
                self.startTimer()
            }else{
                self.stopTimer()
            }
        }
    }
    /// 是否显示指示器
    public var showPageControl:Bool = true{
        didSet{
            self.pageControl.isHidden = !showPageControl
        }
    }
    /// 图片数组
    public var arrImage:[UIImage] = []{
        willSet{
            currentPage = 0
            pageControl.numberOfPages = newValue.count
        }
        didSet{
            self.updateImageData()
        }
    }
    /// 图片Url数组
    public var arrImageUrl:[String] = []{
        willSet{
            currentPage = 0
            pageControl.numberOfPages = newValue.count
        }
        didSet{
            self.updateImageData()
        }
    }
    /// 指示器当前页颜色
    public var currentPageIndicatorTintColor:UIColor = UIColor ( red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0 ){
        willSet{
            pageControl.currentPageIndicatorTintColor = newValue
        }
    }
    /// 指示器颜色
    public var pageIndicatorTintColor:UIColor = UIColor ( red: 0.902, green: 0.902, blue: 0.902, alpha: 1.0 ){
        willSet{
            pageControl.pageIndicatorTintColor = newValue
        }
    }
    
    /**
     初始化
     
     - returns:
     */
    private func initializeUI(){
        
        let width = self.frame.size.width;
        let height = self.frame.size.height;
        
        loopScrollView.frame = CGRect(x: 0, y: 0, w: width, h: height)
        loopScrollView.contentSize = CGSize(width: width * 3.0, height: 0)
        loopScrollView.showsVerticalScrollIndicator = false
        loopScrollView.showsHorizontalScrollIndicator = false
        loopScrollView.delegate = self
        loopScrollView.bounces = false
        loopScrollView.isPagingEnabled = true
//        loopScrollView.decelerationRate = 0.85
        self.addSubview(loopScrollView)
        
        pageControl.frame = CGRect(x: 0, y: height - 20, w: width, h: 20)
        pageControl.isUserInteractionEnabled = false
        pageControl.currentPageIndicatorTintColor = self.currentPageIndicatorTintColor
        pageControl.pageIndicatorTintColor = self.pageIndicatorTintColor
        self.addSubview(pageControl)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandle(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        loopScrollView.addGestureRecognizer(tap)
        
        let imgWidth : CGFloat = width - (pageMargin + subPageWidth)*2
        
        imageView0.frame = CGRect(x: subPageWidth + (pageMargin + subPageWidth) * 2, y: subPageTopMargin, width: imgWidth, height: height - subPageTopMargin * 2)
        imageView1.frame = CGRect(x: width + pageMargin + subPageWidth, y: 0, width: imgWidth, height: height)
        imageView2.frame = CGRect(x: width * 2.0 - subPageWidth, y: subPageTopMargin, width: imgWidth, height: height - subPageTopMargin * 2)
        loopScrollView.addSubview(imageView0)
        loopScrollView.addSubview(imageView1)
        loopScrollView.addSubview(imageView2)
    }
    
    //MARK: - life cycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        self.stopTimer()
    }
    
    //MARK: - UIScrollView delegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let ratio = scrollView.contentOffset.x/self.frame.size.width
        
        let marginRatio = (4 + (subPageWidth + pageMargin) * 2)/self.frame.size.width
        
        if ratio <= marginRatio {
            self.endScrollMethod(ratio: ratio)
        } else if ratio >= (2 - marginRatio) {
            self.endScrollMethod(ratio: ratio)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let ratio = scrollView.contentOffset.x/self.frame.size.width
        self.endScrollMethod(ratio: ratio)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate{
            let ratio = scrollView.contentOffset.x/self.frame.size.width
            self.endScrollMethod(ratio: ratio)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopTimer()
    }
    
    func loadImage(fromUrl:String? ,toImagev : UIImageView){
        if fromUrl == nil {
            return
        }
        toImagev.kf.setImage(with: URL(string: fromUrl ?? "")!, placeholder:UIImage(named:"default_image")) {
            [weak self] image, error, cacheType, imageURL in
            if let image = image {
                toImagev.image = image
                self?.layoutIfNeeded()
            }
        }
    }
    
    //MARK: - reload data
    private func updateImageData(){
        
        if arrImageUrl.count > 0{
            if currentPage == 0{
                loadImage(fromUrl: arrImageUrl.last, toImagev: imageView0)
                loadImage(fromUrl: arrImageUrl[currentPage], toImagev: imageView1)
                loadImage(fromUrl: arrImageUrl[currentPage + 1], toImagev: imageView2)
            }else if currentPage == arrImageUrl.count - 1{
                loadImage(fromUrl: arrImageUrl[currentPage - 1], toImagev: imageView0)
                loadImage(fromUrl: arrImageUrl[currentPage], toImagev: imageView1)
                loadImage(fromUrl: arrImageUrl.first, toImagev: imageView2)
            }else{
                loadImage(fromUrl: arrImageUrl[currentPage - 1], toImagev: imageView0)
                loadImage(fromUrl: arrImageUrl[currentPage], toImagev: imageView1)
                loadImage(fromUrl: arrImageUrl[currentPage + 1], toImagev: imageView2)
            }
        }else{
            if currentPage == 0 {
                imageView0.image = arrImage.last
                imageView1.image = arrImage[currentPage]
                imageView2.image = arrImage[currentPage + 1]
            }else if currentPage == arrImage.count - 1{
                imageView0.image = arrImage[currentPage - 1]
                imageView1.image = arrImage[currentPage]
                imageView2.image = arrImage.first
            }else{
                imageView0.image = arrImage[currentPage - 1]
                imageView1.image = arrImage[currentPage]
                imageView2.image = arrImage[currentPage + 1]
            }
        }
        
        pageControl.currentPage = currentPage
        loopScrollView.contentOffset = CGPoint(x: self.frame.size.width,y: 0)
    }
    //
    private func endScrollMethod(ratio:CGFloat){
        
        let imageCount : Int = arrImageUrl.count > 0 ? arrImageUrl.count : arrImage.count
        
        if ratio <= 0.7{
            if currentPage - 1 < 0{
                currentPage = imageCount - 1
            }else{
                currentPage -= 1
            }
        }
        if ratio >= 1.3{
            if currentPage == imageCount - 1{
                currentPage = 0
            }else{
                currentPage += 1
            }
        }
        
        self.updateImageData()
        self.startTimer()
    }
    
    private func startTimer(){
        if autoShow{
            timer = nil
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(CLLoopView.autoTurnNextView), userInfo: nil, repeats: true)
        }
    }
    private func stopTimer(){
        if autoShow{
            guard let timer = self.timer else{
                return
            }
            if timer.isValid{
                timer.invalidate()
            }
        }
    }
    
    //MARK: event response
    @objc private func tapGestureHandle(_ tap:UITapGestureRecognizer){
        guard let tmp = delegate else{
            print("delegate is nil")
            return
        }
        tmp.selectLoopViewPage(idx: currentPage)
    }
    @objc private func autoTurnNextView(){
        
        let imageCount : Int = arrImageUrl.count > 0 ? arrImageUrl.count : arrImage.count
        
        if currentPage == imageCount - 1{
            currentPage = 0
        }else{
            currentPage += 1
        }
        self.updateImageData()
    }
}

//
//  ZoomView.swift
//  图片浏览Swift
//
//  Created by Merak on 16/5/6.
//  Copyright © 2016年. All rights reserved.
//  图片预览控件

import UIKit
import CocoaLumberjack

public protocol HQZoomViewDelegate : class {
    func hqzv_singleTapClick(tap: UITapGestureRecognizer)
}

public class HQZoomView: UIControl, UIScrollViewDelegate {
    
    private let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    private let screenHeight: CGFloat = UIScreen.main.bounds.size.height
    private let maxScale: CGFloat = 3.0 // 最大的缩放比例
    private let minScale: CGFloat = 1.0 // 最小的缩放比例
    private let animDuration: TimeInterval = 0.2 // 动画时长
    
    weak var delegate : HQZoomViewDelegate?
    
    // MARK: - Public property
    
    // 图片开始时的frame
    public var originFrame: CGRect = CGRect.zero
    // 要显示的图片
    public var image: UIImage? {
        didSet {
            if let _image = image {
                let imageViewH = _image.size.height / _image.size.width * screenWidth
                self.imageView?.bounds = CGRect(x: 0, y: 0, width: screenWidth, height: imageViewH)
                self.imageView?.center = (scrollView?.center)!
                self.imageView?.image = image
                originFrame = (self.imageView?.frame)!
            }
        }
    }

    // MARK: - Private property
    
    private var scrollView: UIScrollView?
    var imageView: UIImageView?
    
    private var scale: CGFloat = 1.0 // 当前的缩放比例
    private var touchX: CGFloat = 0.0 // 双击点的X坐标
    private var touchY: CGFloat = 0.0 // 双击点的Y坐标
    
    private var isDoubleTapingForZoom: Bool = false // 是否是双击缩放
    
    // MARK: - Life cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        // 初始化View
        self.initAllView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func initAllView() {
        // UIScrollView
        self.scrollView = UIScrollView()
        self.scrollView?.frame = self.bounds
        self.scrollView?.delegate = self
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.maximumZoomScale = maxScale // scrollView最大缩放比例
        self.scrollView?.minimumZoomScale = minScale // scrollView最小缩放比例
        self.scrollView?.backgroundColor = UIColor.black
        self.scrollView?.contentSize = CGSize(width: self.scrollView?.w ?? 0, height: self.scrollView?.h ?? 0)
        self.addSubview(self.scrollView!)
        
        // 添加手势
        // 1.单击手势
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapClick(tap:)))
        singleTap.numberOfTapsRequired = 1
        self.scrollView?.addGestureRecognizer(singleTap)
        // 2.双击手势
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapClick(tap:)))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView?.addGestureRecognizer(doubleTap)
        // 必须加上这句，否则双击手势不管用
        singleTap.require(toFail: doubleTap)
        
        // UIImageView
        self.imageView = UIImageView()
        self.scrollView?.addSubview(self.imageView!)
    }
    
    // MARK: - Public methods
    public func reset(){
        self.scrollView?.setZoomScale(self.minScale, animated: true)
    }
    
    // MARK: - deinit
    deinit {
        print("ZoomView.swift释放了！");
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //当捏或移动时，需要对center重新定义以达到正确显示位置
        var centerX = scrollView.center.x
        var centerY = scrollView.center.y
        centerX = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width / 2 : centerX
        centerY = scrollView.contentSize.height > scrollView.frame.size.height ?scrollView.contentSize.height / 2 : centerY
        self.imageView?.center = CGPoint(x: centerX, y: centerY)
        
        // ****************双击放大图片关键代码*******************
        if isDoubleTapingForZoom {
            let contentOffset = self.scrollView?.contentOffset
            let offsetX = self.bounds.midX - self.touchX
            self.scrollView?.contentOffset = CGPoint(x: (contentOffset?.x)! - offsetX * 2.2, y: (contentOffset?.y)!)
        }
        // ****************************************************
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.scale = scale
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView!
    }
    
    // MARK: - Event response
    // 单击手势事件
    @objc func singleTapClick(tap: UITapGestureRecognizer) {
        self.reset()
        self.delegate?.hqzv_singleTapClick(tap: tap)
    }
    
    // 双击手势事件
    @objc func doubleTapClick(tap: UITapGestureRecognizer) {
        self.touchX = tap.location(in: tap.view).x
        self.touchY = tap.location(in: tap.view).y
        
        if self.scale > 1.0 {
            self.scale = 1
            self.scrollView?.setZoomScale(self.scale, animated: true)
        } else {
            self.scale = maxScale
            self.isDoubleTapingForZoom = true
            self.scrollView?.setZoomScale(maxScale, animated: true)
        }
        
        self.isDoubleTapingForZoom = false
    }
}

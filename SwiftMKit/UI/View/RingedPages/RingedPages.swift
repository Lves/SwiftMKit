//
//  RingedPages.swift
//  RingedPages
//
//  Created by admin on 16/9/28.
//  Copyright © 2016年 Ding. All rights reserved.
//

import UIKit

public enum RPPageControlPositon: Int {
    case bellowBody, inBodyBottom, inBodyTop, aboveBody
}

public protocol RingedPagesDataSource {
    func numberOfItems(in ringedPages: RingedPages) -> Int
    func ringedPages(_ pages: RingedPages, viewForItemAt index: Int) -> UIView
}
public protocol RingedPagesDelegate {
    func didSelectPage(in pages: RingedPages, pageIndex: Int)
    func ringedPages(_ pages: RingedPages, didScrollTo index: Int)
}
extension RingedPagesDelegate {// This extension makes the protocal optional~
    func didSelectPage(in pages: RingedPages, pageIndex: Int) {}
    func ringedPages(_ pages: RingedPages, didScrollTo index: Int) {}
}


public class RingedPages: UIView {
    /// PageControl
    public var showPageControl = true
    public var pageControlPosition = RPPageControlPositon.bellowBody
    public var pageControlHeight:CGFloat = 15
    public var pageControlMarginTop: CGFloat = 5
    public var pageControlMarginBottom: CGFloat = 5
    public var pageControl: ImagePageControl {
        get {
            return m_pageControl
        }
    }
    
    /// Carousel - main view
    public var carousel: PagesCarousel {
        get {
            return m_carousel
        }
    }
    
    /// Data source and delegate
    public var dataSource: RingedPagesDataSource?
    public var delegate: RingedPagesDelegate?
    
    /// Main API
    public var currentIndex: Int {
        get {
            return carousel.currentIndex
        }
    }
    public func scroll(to index: Int) {
        carousel.scroll(to: index)
    }
    public func reloadData() {
        layoutPageControlAndCarousel()
        carousel.reloadData()
    }
    public func dequeueReusablePage() -> UIView? {
        return carousel.dequeueReusablePage()
    }
    
    private lazy var m_pageControl: ImagePageControl = {
        let pageControl = ImagePageControl()
        pageControl.addTarget(self, action: #selector(pageControlTapped), for: .valueChanged)
        return pageControl
    }()
    private lazy var m_carousel: PagesCarousel = {
        let carousel = PagesCarousel()
        carousel.dataSource = self
        carousel.delegate = self
        return carousel
    }()
}

extension RingedPages: PagesCarouselDataSource, PagesCarouselDelegate {
    public func numberOfItems(inCarousel carousel: PagesCarousel) -> Int {
        if let number = dataSource?.numberOfItems(in: self) {
            return number
        }
        return 0
    }
    public func carousel(_ carousel: PagesCarousel, pageForItemAt index: Int) -> UIView {
        if let page = dataSource?.ringedPages(self, viewForItemAt: index) {
            return page
        }
        return UIView()
    }
    
    public func didSelectPage(in carousel: PagesCarousel, pageIndex:Int) {
        delegate?.didSelectPage(in: self ,pageIndex: pageIndex)
    }
    public func carousel(carousel: PagesCarousel, didScrollTo index: Int) {
        if pageControl.currentIndex != index {
            pageControl.currentIndex = index
        }
        delegate?.ringedPages(self, didScrollTo: index)
    }
}

private extension RingedPages {
    @objc func pageControlTapped(pageControl: ImagePageControl) {
        let index = pageControl.currentIndex
        carousel.scroll(to: index)
    }
    func layoutPageControlAndCarousel() {
        layoutIfNeeded()
        pageControl.numberOfPages = 0
        pageControl.removeFromSuperview()
        carousel.removeFromSuperview()
        let num = dataSource?.numberOfItems(in: self)
        guard num != nil && num! > 0 else {
            return
        }
        let number = num!
        pageControl.numberOfPages = number
        pageControl.currentIndex = 0
        var carouselFrame = CGRect.zero
        var pageControlFrame = CGRect.zero
        let size = frame.size
        let pageControlSpaceHeight = pageControlMarginBottom + pageControlMarginTop + pageControlHeight
        switch pageControlPosition {
        case .aboveBody:
            pageControlFrame = CGRect(x: 0, y: pageControlMarginTop, width: size.width, height: pageControlHeight)
            carouselFrame = CGRect(x: 0, y: pageControlSpaceHeight, width: size.width, height: size.height - pageControlSpaceHeight)
        case .inBodyTop:
            pageControlFrame = CGRect(x: 0, y: pageControlMarginTop, width: size.width, height: pageControlHeight)
            carouselFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        case .inBodyBottom:
            pageControlFrame = CGRect(x: 0, y: size.height - pageControlMarginBottom - pageControlHeight, width: size.width, height: pageControlHeight)
            carouselFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        default:
            pageControlFrame = CGRect(x: 0, y: size.height - pageControlHeight - pageControlMarginBottom, width: size.width, height: pageControlHeight)
            carouselFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height - pageControlSpaceHeight)
        }
        carousel.frame = carouselFrame
        pageControl.frame = pageControlFrame
        addSubview(carousel)
        addSubview(pageControl)
        pageControl.isHidden = false
        if !showPageControl {
            pageControl.isHidden = true
            carousel.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
    }
}

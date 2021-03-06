//
//  PagesCarousel.swift
//  RingedPages
//
//  Created by admin on 16/9/28.
//  Copyright © 2016年 Ding. All rights reserved.
//

import UIKit
import CocoaLumberjack

public protocol PagesCarouselDataSource {
    func numberOfItems(inCarousel carousel: PagesCarousel) -> Int
    func carousel(_ carousel: PagesCarousel, pageForItemAt index: Int) -> UIView
}

public protocol PagesCarouselDelegate {
    func carousel(_ carousel: PagesCarousel, didScrollTo index: Int)
    func didSelectPage(in carousel: PagesCarousel ,pageIndex: Int)
}
public extension PagesCarouselDelegate {
    func carousel(_ carousel: PagesCarousel, didScrollTo index: Int) {}
    func didSelectPage(in carousel: PagesCarousel ,pageIndex: Int) {}
}

public class PagesCarousel: UIView, UIScrollViewDelegate {
    
    /// The size of the center main page. Infact, if you don't set, will be the size of whole PagesCarousel.
    public var mainPageSize = CGSize.zero
    /// When the center page is moved to left or right, it's size will change, so we use pageScale for this.
    public var pageScale: CGFloat = 1.0
    public var autoScrollInterval: TimeInterval = 0.0 // is <= 0, will not scroll automatically
    public var dataSource: PagesCarouselDataSource?
    public var delegate: PagesCarouselDelegate?
    public var currentIndex: Int {
        get {
            return p_currentIndex
        }
    }
    fileprivate var contentPageCount: Int = 0 //页面展示了多少个page
    
    /// Main API
    public func reloadData() {
        needsReload = true
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        removeTimer()
        setNeedsLayout()
    }
    
    /// To get the reusing views.
    /// Normally, pages are the same type views, so we can use an array to stroy reusingViews, not dictionary or chache
    /// - Returns: A view as page for reusing.
    public func dequeueReusablePage() -> UIView? {
        let page = reusablePages.last
        if page != nil {
            reusablePages.removeLast()
        }
        return page
    }
    
    public func scroll(to index: Int) {
        if index < pageCount {
            removeTimer()
            indexForTimer = index + orginPageCount
            let point = CGPoint(x: mainPageSize.width * CGFloat(index + orginPageCount), y: 0)
            scrollView.setContentOffset(point, animated: true)
            setPages(at: scrollView.contentOffset)
            refreshVisiblePageAppearance()
            addTimer()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        p_setUp()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        p_setUp()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if needsReload {
            orginPageCount = 0
            if let dataSource = dataSource {
                orginPageCount = dataSource.numberOfItems(inCarousel: self)
                
                // * 3!!!!! for cyclely scrolling.
                pageCount = orginPageCount == 1 ? 1 : orginPageCount * 3
            }
            reusablePages.removeAll()
            pages.removeAll()
            visibleRange = NSRange(location: 0, length: 0)
            
            for _ in 0..<pageCount {
                pages.append(nil)
            }
            
            scrollView.frame = CGRect(x: 0, y: 0, width: mainPageSize.width, height: mainPageSize.height)
            scrollView.contentSize = CGSize(width: mainPageSize.width * CGFloat(pageCount), height: mainPageSize.height)
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            scrollView.center = center
            
            if orginPageCount > 1 {
                let x = mainPageSize.width * CGFloat(orginPageCount)
                scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
                indexForTimer = orginPageCount
                addTimer()
            }
            needsReload = false
        }
        setPages(at: scrollView.contentOffset)
        refreshVisiblePageAppearance()
    }
    
    fileprivate lazy var scrollView: UIScrollView = {
        let carousel = UIScrollView()
        carousel.scrollsToTop = false
        carousel.delegate = self
        carousel.isPagingEnabled = true
        carousel.clipsToBounds = false
        carousel.showsVerticalScrollIndicator = false
        carousel.showsHorizontalScrollIndicator = false
        return carousel
    }()
    fileprivate var needsReload = true
    fileprivate var pageCount = 0
    fileprivate var orginPageCount = 0
    fileprivate var p_currentIndex = 0
    fileprivate var visibleRange = NSRange(location: 0, length: 0)
    fileprivate var pages = [UIView?]()
    fileprivate var reusablePages = [UIView]()
    fileprivate var timer: Timer?
    fileprivate var indexForTimer = 0
    
    deinit {
        timer?.invalidate()
    }
}

public extension  PagesCarousel {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard orginPageCount > 0 else { return }
        
        let number = scrollView.contentOffset.x / mainPageSize.width
        var pageIndex =  Int(floor(number)) % orginPageCount
        
        if orginPageCount > 1 {
            if number >= CGFloat(2 * orginPageCount) {
                let point = CGPoint(x: mainPageSize.width * CGFloat(orginPageCount), y: 0)
                scrollView.setContentOffset(point, animated: false)
                indexForTimer = orginPageCount
            }
            if number <= CGFloat(orginPageCount - 1) {
                let point = CGPoint(x: mainPageSize.width * CGFloat(2 * orginPageCount - 1), y: 0)
                scrollView.setContentOffset(point, animated: false)
                indexForTimer = 2 * orginPageCount
            }
        } else {
            pageIndex = 0
        }
        
        setPages(at: scrollView.contentOffset)
        refreshVisiblePageAppearance()
        if p_currentIndex != pageIndex {
            delegate?.carousel(self, didScrollTo: pageIndex)
        }
        p_currentIndex = pageIndex
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        removeTimer()
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if orginPageCount > 1 && autoScrollInterval > 0 {
            addTimer()
            let number = Int(floor(scrollView.contentOffset.x / mainPageSize.width))
            if indexForTimer == number {
                indexForTimer = number + 1
            } else {
                indexForTimer = number
            }
        }
    }
}

private extension PagesCarousel {
    func p_setUp() {
        let scrollViewContainner = UIView(frame: bounds)
        scrollViewContainner.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.frame = bounds
        scrollViewContainner.addSubview(scrollView)
        addSubview(scrollViewContainner)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pagesTapedAction(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func pagesTapedAction(_ sender : UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: self) //获取点击的位置
            let touchX = point.x
            let firstPageW = (bounds.w - (mainPageSize.width * (CGFloat)(contentPageCount))) / 2 //获取第一个page显示的宽度
            let index = Int((touchX - firstPageW) / mainPageSize.width) //获取点击的是当前显示的第几个page
            let midIndex = contentPageCount / 2
            let dvalueIndex = index - midIndex //获取点击的是或左或右的第几个page

            var touchIndex = currentIndex
            for _ in 0..<abs(dvalueIndex){
                if dvalueIndex < 0{
                    if touchIndex - 1 < 0 {
                        touchIndex = orginPageCount
                    }
                    touchIndex -= 1
                }else if dvalueIndex > 0{
                    if touchIndex + 1 > orginPageCount - 1 {
                        touchIndex = 0
                    }else{
                        touchIndex += 1
                    }
                }
            }
            delegate?.didSelectPage(in: self, pageIndex: touchIndex)
            
            /*
            var tempIndex = 1
            if (dvalueIndex < 0){
                tempIndex = -1
            }
            let scrollToPointX = scrollView.contentOffset.x + (CGFloat)(tempIndex) * mainPageSize.width //获取点击page的x
            let scrollToPoint = CGPoint(x: scrollToPointX, y: 0)
            scrollView.setContentOffset(scrollToPoint, animated: true)
            */
        }
    }
    
    func addTimer() {
        if orginPageCount > 1 && autoScrollInterval > 0 {
            timer = Timer.scheduledTimer(timeInterval: autoScrollInterval, target: self, selector: #selector(autoScrollToNextPage), userInfo: nil, repeats: true)
        }
    }
    func removeTimer() {
        timer?.invalidate()
    }
    @objc func autoScrollToNextPage() {
        indexForTimer += 1
        let point = CGPoint(x: mainPageSize.width * CGFloat(indexForTimer), y: 0)
        scrollView.setContentOffset(point, animated: true)
    }
    func setPages(at contentOffset: CGPoint) {
        let startPoint = CGPoint(x: contentOffset.x - scrollView.frame.origin.x, y: contentOffset.y - scrollView.frame.origin.y)
        let endPoint = CGPoint(x: startPoint.x + bounds.size.width, y: startPoint.y + bounds.size.height)
        var startIndex = 0
        for i in 0..<pages.count {
            if mainPageSize.width * CGFloat(i + 1) > startPoint.x {
                startIndex = i
                break
            }
        }
        var endIndex = startIndex
        for i in startIndex..<pages.count {
            if (mainPageSize.width * CGFloat(i + 1) < endPoint.x && mainPageSize.width * CGFloat(i + 2) >= endPoint.x) || i + 2 == pages.count {
                endIndex = i + 1
                break
            }
        }
        startIndex = max(startIndex, 0)
        endIndex = min(endIndex + 1, pages.count - 1)
        contentPageCount = endIndex - startIndex
        visibleRange = NSRange(location: startIndex, length: endIndex - startIndex + 1)
        for i in startIndex...endIndex {
            setPage(at: i)
        }
        for i in 0..<startIndex {
            removePage(at: i)
        }
        for i in (endIndex + 1)..<pages.count {
            removePage(at: i)
        }
    }
    func refreshVisiblePageAppearance() {
        guard pageScale < 1 && pageScale >= 0 else { return }
        let offset = scrollView.contentOffset.x
        for i in visibleRange.location..<visibleRange.location + visibleRange.length {
            if let page = pages[i] {
                let originX = page.frame.origin.x
                let delta = fabs(originX - offset)
                let originPageFrame = CGRect(x: mainPageSize.width * CGFloat(i), y: 0, width: mainPageSize.width, height: mainPageSize.height)
                var inset = mainPageSize.width * CGFloat(1 - pageScale) * 0.5
                if delta < mainPageSize.width {
                    inset *= (delta / mainPageSize.width)
                }
                let edgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
                page.frame = UIEdgeInsetsInsetRect(originPageFrame, edgeInsets)
            }
        }
    }
    
    func setPage(at index: Int) {
        assert(index >= 0 && index < pages.count)
        var page = pages[index]
        if page == nil {
            if let dataSource = dataSource {
                page = dataSource.carousel(self, pageForItemAt: index % orginPageCount)
                assert(page != nil)
                pages[index] = page
                page!.frame = CGRect(x: mainPageSize.width * CGFloat(index), y: 0, width: mainPageSize.width, height: mainPageSize.height)
                if page!.superview == nil {
                    scrollView.addSubview(page!)
                }
            }
        }
    }
    func removePage(at index: Int) {
        let page = pages[index]
        guard page != nil else {
            return
        }
        queueReusable(page: page!)
        if page!.superview != nil {
            page!.removeFromSuperview()
        }
        pages[index] = nil
        
    }
    func queueReusable(page: UIView) {
        reusablePages.append(page)
    }
    
}

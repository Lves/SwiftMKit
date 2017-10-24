//
//  SegmentContainerViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/12/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack
import ReactiveCocoa
import ReactiveSwift

public protocol SegmentContainerViewControllerDelegate : class {
    func didSelectSegment(_ segmentContainer: SegmentContainerViewController, index: Int, viewController: UIViewController)
}
public extension SegmentContainerViewControllerDelegate {
    func didSelectSegment(_ segmentContainer: SegmentContainerViewController, index: Int, viewController: UIViewController){}
}

open class SegmentContainerViewController: UIViewController ,UIScrollViewDelegate{
    
    open let screenW: CGFloat = UIScreen.main.bounds.w
    open let screenH: CGFloat = UIScreen.main.bounds.h
    
    fileprivate var _viewControllers = [UIViewController]()
    
    open var viewControllers:[UIViewController] {
        get {
            return _viewControllers
        }
    }
    
    fileprivate var _selectedSegment: Int = 0
    
    open var selectedSegment: Int {
        get {
            return _selectedSegment
        }
    }
    
    open var selectedViewController: UIViewController? {
        get {
            return viewControllers[safe: selectedSegment]
        }
    }
    open weak var delegate: SegmentContainerViewControllerDelegate?
    open var scrollView : UIScrollView!
    open var offsetX = MutableProperty<CGFloat>(0)

    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override open func viewDidLayoutSubviews() {
        
        if scrollView == nil {
            self.setUI()
        }else{
            self.resetSubUIFrame()
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func setUI() {
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.backgroundColor = UIColor.clear
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.view.backgroundColor = UIColor.clear
        self.view.addSubview(scrollView)
        self.resetChildControllerView()
    }
    
    open func addSegmentViewControllers(_ childController: [UIViewController], selectedSegment: Int = 0) {
        _viewControllers = childController
        _selectedSegment = selectedSegment
    }
    
    fileprivate func resetChildControllerView(){
        scrollView.contentSize = CGSize(width: (self.screenW * CGFloat(viewControllers.count)), height: 0)
        scrollView.removeSubviews()
        
        for index in 0..<viewControllers.count {
            let vc = viewControllers[index]
            self.addChildViewController(vc)
            if let listVC = vc as? BaseListKitViewController {
                listVC.listView?.scrollsToTop = (index == 0)
            }
            if index == selectedSegment && !(scrollView.subviews.contains(vc.view)) {
                scrollView.addSubview(vc.view)
            }
            scrollView.setContentOffset(CGPoint(x: (self.screenW * CGFloat(selectedSegment)), y: 0), animated: false)

        }
        self.resetSubUIFrame()
    }
    
    fileprivate func resetSubUIFrame() {
        if scrollView != nil{
            scrollView.frame = self.view.bounds
            for index in 0..<viewControllers.count {
                let vc = viewControllers[index]
                vc.view.frame.x = CGFloat(index) * screenW
                vc.view.frame.h = scrollView.h
            }
        }
    }

    fileprivate func handleScrollEndEvent(_ scrollView: UIScrollView) {
        let width = self.screenW
        let offsetX = scrollView.contentOffset.x
        let percentX : CGFloat = offsetX / scrollView.contentSize.width
        let index = (offsetX + width / 2) / width
        _selectedSegment = Int(index)
        self.offsetX.value = percentX * width

        delegate?.didSelectSegment(self, index: _selectedSegment, viewController: viewControllers[_selectedSegment])
        if let vc = viewControllers[safe: Int(_selectedSegment)] {
            if !(scrollView.subviews.contains(vc.view)) {
                vc.view.frame = CGRect(x: CGFloat(_selectedSegment) * screenW, y: 0, w: screenW, h: scrollView.h)
                scrollView.addSubview(vc.view)
            }
        }
    }
    
    dynamic public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handleScrollEndEvent(scrollView)
    }
    dynamic public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrollEndEvent(scrollView)
    }

    open func selectSegment(_ index: Int, animated: Bool = true) -> Bool {
        if index < 0 || index >= viewControllers.count {
            DDLogError("Segment Index out of bounds")
            return false
        }
        if let vc = viewControllers[safe: index] {
            if !(self.childViewControllers.contains(vc)) {
                self.addChildViewController(vc)
                self.resetSubUIFrame()
            }
        }
        if index == selectedSegment {
            DDLogDebug("Segment Index is same to old one, do nothing")
            return true
        }
        if let vc = viewControllers[safe: Int(index)] {
            if !(scrollView.subviews.contains(vc.view)) {
                vc.view.frame = CGRect(x: CGFloat(index) * screenW, y: 0, w: screenW, h: scrollView.h)
                scrollView.addSubview(vc.view)
            }
        }

        for vc in viewControllers {
            if let listVC = vc as? BaseListKitViewController {
                if index == viewControllers.index(of: vc) {
                    listVC.listView?.scrollsToTop = true
                } else {
                    listVC.listView?.scrollsToTop = false
                }
            }
        }
        _selectedSegment = index
        scrollView.setContentOffset(CGPoint(x: (self.screenW * CGFloat(selectedSegment)), y: 0), animated: animated)
        DDLogInfo("self.screenW \(self.screenW)")
        return true
    }
}

extension UIScrollView {
    /// 是否允许多个手势共存
    /// 需要侧边滑动时，返回true，scrollView的手势和页面的滑动返回手势共存，scrollView就不拦截手势
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return panBack(gestureRecognizer: gestureRecognizer)
    }
    /// 需要侧边滑动时，返回true，scrollView的手势和页面的滑动返回手势共存，scrollView就不拦截手势
    /// 侧滑时，让scrollView禁止滑动，否则滑动返回时，scrollView也跟着在滑动
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !panBack(gestureRecognizer: gestureRecognizer)
    }
    func panBack(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            let point = panGestureRecognizer.translation(in: self)
            let state = panGestureRecognizer.state
            if UIGestureRecognizerState.began == state || UIGestureRecognizerState.possible == state {
                let location = gestureRecognizer.location(in: self)
                if point.x > 0 && location.x < 30 && contentOffset.x <= 0 {
                    return true
                }
            }
            return false
        }
        return false
    }
}

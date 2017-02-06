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

public protocol SegmentContainerViewControllerDelegate : class {
    func didSelectSegment(segmentContainer: SegmentContainerViewController, index: Int, viewController: UIViewController)
}
public extension SegmentContainerViewControllerDelegate {
    func didSelectSegment(segmentContainer: SegmentContainerViewController, index: Int, viewController: UIViewController){}
}

public class SegmentContainerViewController: UIViewController ,UIScrollViewDelegate{
    
    public let screenW: CGFloat = UIScreen.mainScreen().bounds.w
    public let screenH: CGFloat = UIScreen.mainScreen().bounds.h
    
    private var _viewControllers = [UIViewController]()
    
    public var viewControllers:[UIViewController] {
        get {
            return _viewControllers
        }
    }
    
    private var _selectedSegment: Int = 0
    
    public var selectedSegment: Int {
        get {
            return _selectedSegment
        }
    }
    
    public var selectedViewController: UIViewController? {
        get {
            return viewControllers[safe: selectedSegment]
        }
    }
    public weak var delegate: SegmentContainerViewControllerDelegate?
    public var scrollView : UIScrollView!
    
    public var offsetX = MutableProperty<CGFloat>(0)

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override public func viewDidLayoutSubviews() {
        
        if scrollView == nil {
            self.setUI()
        }else{
            self.resetSubUIFrame()
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func setUI() {
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.delegate = self
        scrollView.scrollEnabled = true
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.view.backgroundColor = UIColor.clearColor()
        self.view.addSubview(scrollView)
        self.resetChildControllerView()
    }
    
    public func addSegmentViewControllers(childController: [UIViewController], selectedSegment: Int = 0) {
        _viewControllers = childController
        _selectedSegment = selectedSegment
    }
    
    private func resetChildControllerView(){
        scrollView.contentSize = CGSizeMake((self.screenW * CGFloat(viewControllers.count)), 0)
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
            scrollView.setContentOffset(CGPointMake((self.screenW * CGFloat(selectedSegment)), 0), animated: false)

        }
        self.resetSubUIFrame()
    }
    
    private func resetSubUIFrame() {
        if scrollView != nil{
            scrollView.frame = self.view.bounds
            for index in 0..<viewControllers.count {
                let vc = viewControllers[index]
                vc.view.frame.x = CGFloat(index) * screenW
                vc.view.frame.h = scrollView.h
            }
        }
    }
    
    dynamic public func scrollViewDidScroll(scrollView: UIScrollView) {
        let width = self.screenW
        let offsetX = scrollView.contentOffset.x
        let percentX : CGFloat = offsetX / scrollView.contentSize.width
        let index = (offsetX + width / 2) / width
        _selectedSegment = Int(index)
        self.offsetX.value = percentX * width
    }
    
    dynamic public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.w)
        delegate?.didSelectSegment(self, index: index, viewController: viewControllers[index])
        if let vc = viewControllers[safe: Int(index)] {
            if !(scrollView.subviews.contains(vc.view)) {
                vc.view.frame = CGRectMake(CGFloat(index) * screenW, 0, screenW, scrollView.h)
                scrollView.addSubview(vc.view)
            }
        }
    }
    
    dynamic public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }

    public func selectSegment(index: Int) -> Bool {
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
                vc.view.frame = CGRectMake(CGFloat(index) * screenW, 0, screenW, scrollView.h)
                scrollView.addSubview(vc.view)
            }
        }

        for vc in viewControllers {
            if let listVC = vc as? BaseListKitViewController {
                if index == viewControllers.indexOf(vc) {
                    listVC.listView?.scrollsToTop = true
                } else {
                    listVC.listView?.scrollsToTop = false
                }
            }
        }
        _selectedSegment = index
        scrollView.setContentOffset(CGPointMake((self.screenW * CGFloat(selectedSegment)), 0), animated: true)
        DDLogInfo("self.screenW \(self.screenW)")
        return true
    }
}

extension UIScrollView {
    /// 是否允许多个手势共存
    /// 需要侧边滑动时，返回true，scrollView的手势和页面的滑动返回手势共存，scrollView就不拦截手势
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return panBack(gestureRecognizer)
    }
    /// 需要侧边滑动时，返回true，scrollView的手势和页面的滑动返回手势共存，scrollView就不拦截手势
    /// 侧滑时，让scrollView禁止滑动，否则滑动返回时，scrollView也跟着在滑动
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !panBack(gestureRecognizer)
    }
    func panBack(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            let point = panGestureRecognizer.translationInView(self)
            let state = panGestureRecognizer.state
            if UIGestureRecognizerState.Began == state || UIGestureRecognizerState.Possible == state {
                let location = gestureRecognizer.locationInView(self)
                if point.x > 0 && location.x < 30 && contentOffset.x <= 0 {
                    return true
                }
            }
            return false
        }
        return false
    }
}

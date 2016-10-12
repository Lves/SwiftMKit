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
    func didSelectSegment(segmentContainer: SegmentContainerViewController, index: Int, viewController: UIViewController ,percentX : CGFloat)
}
public extension SegmentContainerViewControllerDelegate {
    func didSelectSegment(segmentContainer: SegmentContainerViewController, index: Int, viewController: UIViewController ,percentX : CGFloat) {}
}

public class SegmentContainerViewController: UIViewController ,UIScrollViewDelegate{
    
    public let screenW: CGFloat = UIScreen.mainScreen().bounds.w
    public let screenH: CGFloat = UIScreen.mainScreen().bounds.h
    
    private var loadedViewControllers = [UIViewController]()
    private var _viewControllers = [UIViewController]()
    
    public var viewControllers:[UIViewController] {
        get {
            return _viewControllers
        }
    }
    
    private var _selectedSegment: Int = -1
    
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
        self.view.addSubview(scrollView)
        self.resetChildControllerView()
    }
    
    public func addSegmentViewControllers(childController: [UIViewController]) {
        _viewControllers = childController
    }
    
    private func resetChildControllerView(){
        scrollView.contentSize = CGSizeMake((self.screenW * CGFloat(viewControllers.count)), 0)
        scrollView.removeSubviews()
        
        for index in 0..<viewControllers.count {
            let vc = viewControllers[index]
            scrollView.addSubview(vc.view)
            if !(self.childViewControllers.contains(vc)) {
                self.addChildViewController(vc)
                if let listVC = vc as? BaseListViewController {
                    listVC.listView?.scrollsToTop = (index == 0)
                }
            }
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
        if (delegate != nil) {
            delegate?.didSelectSegment(self, index: selectedSegment, viewController: viewControllers[selectedSegment] ,percentX: percentX)
        }
    }

    public func selectSegment(index: Int) -> Bool {
        if index < 0 || index >= viewControllers.count {
            DDLogError("Segment Index out of bounds")
            return false
        }
        if let vc = viewControllers[safe: index] {
            if !loadedViewControllers.contains(vc) {
                loadedViewControllers.append(vc)
                (vc as? BaseKitViewController)?.loadData()
            }
        }
        if index == selectedSegment {
            DDLogDebug("Segment Index is same to old one, do nothing")
            return true
        }
        for vc in viewControllers {
            if let listVC = vc as? BaseListViewController {
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
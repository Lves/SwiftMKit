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
        self.setUI()
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
        scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)
    }
    
    public func addSegmentViewControllers(childController: [UIViewController]) {
        _viewControllers = childController
        scrollView.contentSize = CGSizeMake((self.screenW * CGFloat(viewControllers.count)), 0)
        scrollView.removeSubviews()
        for index in 0..<viewControllers.count {
            let vc = viewControllers[index]
            vc.view.frame.x = CGFloat(index) * screenW
            scrollView.addSubview(vc.view)
            self.addChildViewController(vc)
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
        if index == selectedSegment {
            DDLogDebug("Segment Index is same to old one, do nothing")
            return true
        }
        _selectedSegment = index
        scrollView.setContentOffset(CGPointMake((self.screenW * CGFloat(selectedSegment)), 0), animated: true)
        return true
    }
}
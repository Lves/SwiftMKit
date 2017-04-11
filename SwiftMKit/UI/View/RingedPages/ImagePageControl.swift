//
//  ImagePageControl.swift
//  RingedPages
//
//  Created by admin on 16/9/28.
//  Copyright © 2016年 Ding. All rights reserved.
//

import UIKit

public enum ImagePageControlAlignment: Int {
    case left, center, right
}
public enum ImagePageControlVerticalAlignment: Int {
    case top, middle, bottom
}


/// We can only set indicatorTintColor and currentIndicatorTintColor (or do nothing) to use a pageControl like Apple's native UIPageControl, or, we can use images instead of the circles.
public class ImagePageControl: UIControl {
    public var numberOfPages: Int {
        get {
            return p_numberOfPages
        }
        set {
            guard p_numberOfPages != newValue else {
                return
            }
            systemPageControl.numberOfPages = newValue
            if newValue > 0 {
                systemPageControl.currentPage = 0
            }
            p_numberOfPages = max(0, newValue)
            invalidateIntrinsicContentSize()
            updateAccessibilityValue()
            setNeedsDisplay()
        }
    }
    public var currentIndex: Int {
        get {
            return p_currentIndex
        }
        set {
            setCurrentPage(newValue, sendEvent: false, canDefer: false)
        }
    }
    public var indicatorMargin: CGFloat  = 10.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    public var indicatorDiameter: CGFloat = 6.0 {
        didSet {
            if minHeight < indicatorMargin {
                minHeight = indicatorDiameter
            }
            updateMeasuredIndicatorSizes()
            setNeedsDisplay()
        }
    }
    public var minHeight: CGFloat = 36.0 {// cannot be less than indicatorDiameter
        didSet {
            if minHeight < indicatorMargin {
                indicatorDiameter = minHeight
            }
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    public var alignment = ImagePageControlAlignment.center
    public var verticaleAlignment = ImagePageControlVerticalAlignment.middle
    public var pageIndicatorImage: UIImage? {
        didSet {
            updateMeasuredIndicatorSizes()
            setNeedsDisplay()
        }
    }
    public var currentPageIndicatorImage: UIImage? {
        didSet {
            updateMeasuredIndicatorSizes()
            setNeedsDisplay()
        }
    }
    public var indicatorTintColor = UIColor.lightGray     // will be ignored if pageIndicatorImage setted
    public var currentIndicatorTintColor = UIColor.blue   // will be ignored if currentPageIndicatorImage setted
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.p_Initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.p_Initialize()
    }
    
    public override func draw(_ rect: CGRect) {
        renderPages(context: UIGraphicsGetCurrentContext(), rect: rect)
    }
    
    public override func sizeThatFits( _ size: CGSize) -> CGSize {
        var size = sizeFor(number: numberOfPages)
        size.height = max(size.height, minHeight)
        return size
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let touch = touch {
            let point = touch.location(in: self)
            let size = sizeFor(number: numberOfPages)
            let left = leftOffset()
            let middle = left + (size.width * 0.5)
            if point.x < middle {
                setCurrentPage(currentIndex - 1, sendEvent: true, canDefer: true)
            } else {
                setCurrentPage(currentIndex + 1, sendEvent: true, canDefer: true)
            }
        }
    }
    
    public override var frame: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }
    
    fileprivate lazy var systemPageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    fileprivate var measuredIndicatorWidth: CGFloat = 0
    fileprivate var measuredIndicatorHeight: CGFloat = 0
    fileprivate var displayedPage = 0
    fileprivate var p_currentIndex = 0
    fileprivate var p_numberOfPages = 0
}

private extension ImagePageControl {
    func p_Initialize() {
        backgroundColor = UIColor.clear
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitUpdatesFrequently
        contentMode = .redraw
        addTarget(self, action: #selector(valueDidChanged), for: .valueChanged)
    }
    @objc func valueDidChanged() {
        currentIndex = systemPageControl.currentPage
    }
    func renderPages(context: CGContext?, rect: CGRect) {
        let left = leftOffset()
        var xOffset = left
        var yOffset: CGFloat = 0
        var image: UIImage?
        
        for i in 0..<numberOfPages {
            if i == displayedPage {
                image = currentPageIndicatorImage
            } else {
                image = pageIndicatorImage
            }
            if let image = image {// draw the images
                yOffset = topOffset(forHeight: image.size.height, rect: rect)
                let centeredXOffset = xOffset + floor((measuredIndicatorWidth - image.size.width) * 0.5)
                image.draw(at: CGPoint(x: centeredXOffset, y: yOffset))
            } else {// draw the circles
                yOffset = topOffset(forHeight: indicatorDiameter, rect: rect)
                let centeredXOffset = xOffset + floor((measuredIndicatorWidth - indicatorDiameter) * 0.5)
                let indicatorRect = CGRect(x: centeredXOffset, y: yOffset, width: indicatorDiameter, height: indicatorDiameter)
                if i == displayedPage {
                    (context)!.setFillColor(currentIndicatorTintColor.cgColor)
                } else {
                    (context)!.setFillColor(indicatorTintColor.cgColor)
                }
                (context)!.fillEllipse(in: indicatorRect)
            }
            xOffset += measuredIndicatorWidth + indicatorMargin
        }
        layoutIfNeeded()
        
    }
    func leftOffset() -> CGFloat {
        let rect = bounds
        let size = sizeFor(number: numberOfPages)
        var left: CGFloat = 0
        switch alignment {
        case .center:
            left = ceil( rect.midX - (size.width * 0.5) )
        case .right:
            left = rect.maxX - size.width
        default:
            break
        }
        return left
    }
    func topOffset(forHeight height: CGFloat, rect: CGRect) -> CGFloat {
        var top:CGFloat = 0
        switch verticaleAlignment {
        case .middle:
            top = rect.midY - height * 0.5
        case .bottom:
            top = rect.maxY - height
        default:
            break
        }
        return top
    }
    func sizeFor( number: Int) -> CGSize {
        let marginSpace = CGFloat(max(0, number - 1)) * indicatorMargin
        let indicatorSpace = CGFloat(number) * measuredIndicatorWidth
        let size = CGSize(width: marginSpace + indicatorSpace, height: measuredIndicatorHeight)
        return size
    }
    func updateMeasuredIndicatorSizes() {
        measuredIndicatorWidth = indicatorDiameter
        measuredIndicatorHeight = indicatorDiameter
        if pageIndicatorImage != nil && currentPageIndicatorImage != nil {
            measuredIndicatorWidth = 0
            measuredIndicatorHeight = 0
        }
        if let image = pageIndicatorImage {
            updateMeasuredIndicatorSize(withSize: image.size)
        }
        if let image = currentPageIndicatorImage {
            updateMeasuredIndicatorSize(withSize: image.size)
        }
        invalidateIntrinsicContentSize()
    }
    func updateMeasuredIndicatorSize(withSize size: CGSize) {
        measuredIndicatorHeight = max(measuredIndicatorHeight, size.height)
        measuredIndicatorWidth = max(measuredIndicatorWidth, size.width)
    }
    func setCurrentPage(_ page: Int, sendEvent: Bool, canDefer: Bool) {
        p_currentIndex = min(numberOfPages - 1, max(0, page))
        systemPageControl.currentPage = currentIndex
        updateAccessibilityValue()
        if !canDefer {
            displayedPage = p_currentIndex
            setNeedsDisplay()
        }
        if sendEvent {
            sendActions(for: .valueChanged)
        }
    }
    func updateAccessibilityValue() {
        accessibilityValue = systemPageControl.accessibilityValue
    }
}

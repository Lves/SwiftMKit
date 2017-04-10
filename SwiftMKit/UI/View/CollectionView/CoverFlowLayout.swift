//
//  CoverFlowLayout.swift
//  SwiftMKitDemo
//
//  Created by why on 16/5/31.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import Foundation

open class CoverFlowLayout: UICollectionViewFlowLayout {

    fileprivate struct InnerConstant {
        static let kDistanceToProjectionPlane : CGFloat = 500.0
        
        static let MaxCoverDegree: CGFloat = 20.0
        static let CoverDensity: CGFloat = 0.00
        static let minCoverScale: CGFloat = 0.85
        static let MinCoverOpacity: CGFloat = 0.9
    }
    
    open var maxCoverDegree = InnerConstant.MaxCoverDegree
    open var coverDensity = InnerConstant.CoverDensity
    open var minCoverOpacity = InnerConstant.MinCoverOpacity
    open var minCoverScale = InnerConstant.minCoverScale
    
    var collectionViewHeight: CGFloat {
        get {
            return (self.collectionView?.bounds.size.height)!
        }
    }
    
    var collectionViewWidth: CGFloat {
        get {
            return (self.collectionView?.bounds.size.width)!
        }
    }

    override open var collectionViewContentSize : CGSize {
        return CGSize(width: self.collectionView!.bounds.size.width * CGFloat(self.collectionView!.numberOfItems(inSection: 0)), height: self.collectionView!.bounds.size.height)
    }
    
    ///  准备操作  设置一些初始化参数
    override open func prepare() {
        super.prepare()
    }
    
    ///  当collectionView的bounds发生改变时，是否要刷新布局
    ///  一定要调用这个方法
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
        let idxPaths = self.indexPathsContainedInRect(rect) as? [IndexPath]
        
        var resultingAttributes = [UICollectionViewLayoutAttributes]()
        if idxPaths!.count > 0  {
            for path in idxPaths! {
                resultingAttributes.append(self.layoutAttributesForItem(at: path)!)
            }
        }
        return resultingAttributes
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attributes: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        
        attributes.size = self.itemSize
        attributes.center = CGPoint(x: self.collectionViewWidth * CGFloat(indexPath.row) + self.collectionViewWidth,
                                        y: self.collectionViewHeight / 2)
        
        self.interpolateAttributes(attributes, forOffset: self.collectionView!.contentOffset.x)
        
        return attributes;
        
    }
    
    fileprivate func itemCenterForRow(_ row: NSInteger) -> CGPoint {
        let collectionViewSize: CGSize = self.collectionView!.bounds.size
        return CGPoint(x: CGFloat(row) * collectionViewSize.width + collectionViewSize.width / 2 , y: collectionViewSize.height / 2)
    }
    
    fileprivate func minXForRow(_ row: NSInteger) -> CGFloat {
        return self.itemCenterForRow(row - 1).x + (1.0 / 2 - self.coverDensity) * self.itemSize.width
    }
    
    fileprivate func maxXForRow(_ row: NSInteger) -> CGFloat {
        return self.itemCenterForRow(row + 1).x - (1.0 / 2 - self.coverDensity) * self.itemSize.width
    }
    
    
    fileprivate func degreesToRad(_ degrees: CGFloat) -> CGFloat {
        return degrees * .pi / 180
    }
    
    fileprivate func minXCenterForRow(_ row: NSInteger) -> CGFloat {
        
        let halfWidth: Double = Double(self.itemSize.width) / 2
        let maxRads: Double = Double(self.degreesToRad(self.maxCoverDegree))
        let center: Double = Double(self.itemCenterForRow(row - 1).x)
        let prevItemRightEdge = center + halfWidth
        let projectedLeftEdgeLocal:Double = halfWidth * cos(maxRads) * Double(InnerConstant.kDistanceToProjectionPlane) / (Double(InnerConstant.kDistanceToProjectionPlane) + halfWidth * sin(maxRads))

        return CGFloat(prevItemRightEdge) - self.coverDensity * self.itemSize.width + CGFloat(projectedLeftEdgeLocal)
    }
    
    fileprivate func maxXCenterForRow(_ row: NSInteger) -> CGFloat {
        
        let halfWidth: Double = Double(self.itemSize.width) / 2
        let maxRads: Double = Double(self.degreesToRad(self.maxCoverDegree))
        let center: Double = Double(self.itemCenterForRow(row + 1).x)
        let nextItemLeftEdge = center - halfWidth
        let projectedRightEdgeLocal:Double = fabs(halfWidth * cos(maxRads) * Double(InnerConstant.kDistanceToProjectionPlane) / (-halfWidth * sin(maxRads) - Double(InnerConstant.kDistanceToProjectionPlane)))
        
        return CGFloat(nextItemLeftEdge) + self.coverDensity * self.itemSize.width - CGFloat(projectedRightEdgeLocal)
        
    }
    
    fileprivate func indexPathsContainedInRect(_ rect: CGRect) -> NSArray {
     
        if self.collectionView!.numberOfItems(inSection: 0) == 0 {
            return []
        }
    
        // Find min and max rows that can be determined for sure.
        var minRow: NSInteger = max(NSInteger(rect.origin.x / self.collectionViewWidth) , 0)
        var maxRow: NSInteger = NSInteger(rect.maxX / self.collectionViewWidth)
        
        // Additional check for rows that also can be included (our rows are moving depending on content size).
        let candidateMinRow: NSInteger = max(minRow - 1, 0)
        
        if self.maxXForRow(candidateMinRow) >= rect.origin.x {
            // We have a row that is less than given minimum.
            minRow = candidateMinRow
        }
        
        
        let candidateMaxRow: NSInteger = min(maxRow + 1, self.collectionView!.numberOfItems(inSection: 0) - 1)
        
        if self.minXForRow(candidateMaxRow) <= rect.maxX {
            maxRow = candidateMaxRow
        }
        
        // Simply add index paths between min and max.
        let resultingIdxPaths: NSMutableArray = NSMutableArray()
        
        for i in minRow...maxRow {
            resultingIdxPaths.add(IndexPath(row: i, section: 0))
        }
        
        return NSArray(array: resultingIdxPaths);
    }
    
    
    fileprivate func interpolateAttributes(_ attributes:UICollectionViewLayoutAttributes , forOffset offset:CGFloat){
        
        let attributesPath: IndexPath = attributes.indexPath
        
        // Interpolate offset for given attribute. For this task we need min max interval and min and max x allowed for item.

        let minInterval: CGFloat = (CGFloat(attributesPath.row) - 1) * self.collectionViewWidth
        let maxInterval: CGFloat = (CGFloat(attributesPath.row) + 1) * self.collectionViewWidth
        
        let minX: CGFloat = self.minXCenterForRow(attributesPath.row)
        let maxX: CGFloat = self.maxXCenterForRow(attributesPath.row)
        let spanX = maxX - minX
        
        // Interpolate by formula
        let interpolatedX: CGFloat = min(max(minX + ((spanX / (maxInterval - minInterval)) * (offset - minInterval)), minX), maxX)
        
        attributes.center = CGPoint(x: interpolatedX, y: attributes.center.y)
        
        var transform: CATransform3D = CATransform3DIdentity
        
        // Add perspective.
        transform.m34 = -1.0 / InnerConstant.kDistanceToProjectionPlane
        
        // Then rotate.
        let angle: CGFloat = -self.maxCoverDegree + (interpolatedX - minX) * 2 * self.maxCoverDegree / spanX
        transform = CATransform3DRotate(transform, angle * .pi / 180, 0, 1, 0)

        
        // Then scale: 1 - abs(1 - Q - 2 * x * (1 - Q))
        let scale: CGFloat = 1.0 - abs(1.0 - self.minCoverScale - (interpolatedX - minX) * 2 * (1.0 - self.minCoverScale) / spanX)
        transform = CATransform3DScale(transform, scale, scale, scale)

        // Apply transform.
        attributes.transform3D = transform
        
        // Add opacity: 1 - abs(1 - Q - 2 * x * (1 - Q))
        let opacity: CGFloat = 1.0 - abs(1.0 - self.minCoverOpacity - (interpolatedX - minX) * 2 * (1.0 - self.minCoverOpacity) / spanX)
        attributes.alpha = opacity
    }
    
}

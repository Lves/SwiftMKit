//
//  GalaryCollcetionView.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/20/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit

public class GalaryLinearLayout: UICollectionViewFlowLayout {
    private struct InnerConstant {
        static let MinScaleW: CGFloat = 0.8
        static let MinScaleH: CGFloat = 0.3
        static let MinAlpha: CGFloat = 0
        static let SetAlpha = true
    }

    public var minScaleW = InnerConstant.MinScaleW
    public var minScaleH = InnerConstant.MinScaleH
    public var minAlpha = InnerConstant.MinAlpha
    public var setAlpha = InnerConstant.SetAlpha
    
    // MARK: - 公开属性
    ///  准备操作  设置一些初始化参数
    override public func prepareLayout() {
        let inset = (collectionView!.frame.size.width - itemSize.width) * 0.5
        sectionInset = UIEdgeInsetsMake(0, inset, 0, inset)
        // 要后调用super.prepareLayout()方法，否则有很多警告……
        // http://stackoverflow.com/questions/32082726/the-behavior-of-the-uicollectionviewflowlayout-is-not-defined-because-the-cell
        super.prepareLayout()
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // 屏幕上显示的cell
        let array = super.layoutAttributesForElementsInRect(rect) ?? []
        
        // This is likely occurring because the flow layout subclass BillManager.LinerLayout is modifying attributes returned by UICollectionViewFlowLayout without copying them
        // http://stackoverflow.com/questions/32720358/xcode-7-copy-layoutattributes
        var attributesCopy = [UICollectionViewLayoutAttributes]()
        for itemAttributes in array {
            let itemAttributesCopy = itemAttributes.copy() as! UICollectionViewLayoutAttributes
            // add the changes to the itemAttributesCopy
            attributesCopy.append(itemAttributesCopy)
        }
        
        // 计算 CollectionView 的中点
        let centerX = collectionView!.contentOffset.x + collectionView!.frame.size.width * 0.5
        for attrs in attributesCopy {
            // 计算 cell 中点的 x 值 与 centerX 的差值
            let delta = abs(centerX - attrs.center.x)
            // W：[0.8 ~ 1.0]
            // H：[0.3 ~ 1.0]
            // 反比
            let baseScale = 1 - delta / (collectionView!.frame.size.width + itemSize.width)
            let scaleW = minScaleW + baseScale * (1 - minScaleW)
            let scaleH = minScaleH + baseScale * (1 - minScaleH)
            let alpha = minAlpha + baseScale * (1 - minAlpha)
            // 改变transform（越到中间 越大）
            attrs.transform = CGAffineTransformMakeScale(scaleW, scaleH)
            if setAlpha {
                // 改变透明度（越到中间 越不透明）
                attrs.alpha = abs(alpha)
            }
        }
        return attributesCopy
    }
    
    ///  当collectionView的bounds发生改变时，是否要刷新布局
    ///
    ///  一定要调用这个方法
    override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    ///  targetContentOffset ：通过修改后，collectionView最终的contentOffset(取决定情况)
    ///  proposedContentOffset ：默认情况下，collectionView最终的contentOffset
    override public func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let size = collectionView!.frame.size
        // 计算可见区域的面积
        let rect = CGRectMake(proposedContentOffset.x, proposedContentOffset.y, size.width, size.height)
        // ??前面要加个空格！
        let array = super.layoutAttributesForElementsInRect(rect) ?? []
        // 计算 CollectionView 中点值
        let centerX = proposedContentOffset.x + collectionView!.frame.size.width * 0.5
        // 标记 cell 的中点与 UICollectionView 中点最小的间距
        var minDetal = CGFloat(MAXFLOAT)
        for attrs in array {
            if abs(minDetal) > abs(centerX - attrs.center.x) {
                minDetal = attrs.center.x - centerX
            }
        }
        return CGPointMake(proposedContentOffset.x + minDetal, proposedContentOffset.y)
    }
}
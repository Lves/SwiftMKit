//
//  MSearch.swift
//  SwiftMKitDemo
//
//  Created by Mao on 8/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

open class MSearch {
    
    /**
     二分搜索
     
     - parameter nums:   数据源
     - parameter target: 目标值
     
     - returns: 是否找到
     */
    open class func binarySearch<T: Comparable>(_ nums: [T], target: T) -> Int? {
        var range = 0..<nums.count
        
        while range.lowerBound < range.upperBound {
            let midIndex = range.lowerBound + (range.upperBound - range.lowerBound) / 2
            
            if nums[midIndex] == target {
                return midIndex
            } else if nums[midIndex] < target {
                range = midIndex + 1..<range.upperBound
            } else {
                range = range.lowerBound..<(midIndex+1)
            }
        }
        return nil
    }
    
    /**
     二分搜索(递归)
     
     - parameter nums:   数据源
     - parameter target: 目标值
     
     - returns: 是否找到
     */
    fileprivate class func binarySearchRecursive<T: Comparable>(_ nums: [T], target: T) -> Bool {
        return binarySearchRecursive(nums, target: target, left: 0, right: nums.count - 1)
    }
    fileprivate class func binarySearchRecursive<T: Comparable>(_ nums: [T], target: T, left: Int, right: Int) -> Bool {
        guard left <= right else { return false }
        let mid = (right - left) / 2 + left
        if nums[mid] == target {
            return true
        } else if nums[mid] < target {
            return binarySearchRecursive(nums, target: target, left: mid + 1, right: right)
        } else {
            return binarySearchRecursive(nums, target: target, left: left, right: mid - 1)
        }
    }
    
}

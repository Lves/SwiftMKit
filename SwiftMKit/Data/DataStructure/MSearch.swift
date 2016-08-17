//
//  MSearch.swift
//  SwiftMKitDemo
//
//  Created by Mao on 8/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

public class MSearch {
    
    /**
     二分搜索
     
     - parameter nums:   数据源
     - parameter target: 目标值
     
     - returns: 是否找到
     */
    public class func binarySearch<T: Comparable>(nums: [T], target: T) -> Bool {
        var left = 0
        var right = nums.count - 1
        var mid = 0
        
        while left <= right {
            mid = (right - left) / 2 + left
            
            if nums[mid] == target {
                return true
            } else if nums[mid] < target {
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        return false
    }
    
    /**
     二分搜索(递归)
     
     - parameter nums:   数据源
     - parameter target: 目标值
     
     - returns: 是否找到
     */
    private class func binarySearchRecursive<T: Comparable>(nums: [T], target: T) -> Bool {
        return binarySearchRecursive(nums, target: target, left: 0, right: nums.count - 1)
    }
    private class func binarySearchRecursive<T: Comparable>(nums: [T], target: T, left: Int, right: Int) -> Bool {
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

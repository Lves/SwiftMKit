//
//  NSTimeInterval+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/27/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public extension NSTimeInterval {
    
    func secondsToHHmmss () -> (Int, Int, Int) {
        let seconds : Int = Int(self)
        return (seconds / 3600, (seconds % 3600) / 60, seconds % 60)
    }
    func secondsToHHmmssString () -> String {
        let (h, m, s) = secondsToHHmmss ()
        return "\(String(format: "%02d", h)):\(String(format: "%02d", m)):\(String(format: "%02d", s))"
    }
}
//
//  CollectionType+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/27/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import CocoaLumberjack

extension CollectionType {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        if indices.contains(index) {
            return self[index]
        } else {
            DDLogError("Collection Type Out of bounds with: \(index)/\(indices.count)")
            return nil
        }
    }
}
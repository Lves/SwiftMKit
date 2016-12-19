//
//  CollectionType+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/27/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import CocoaLumberjack

/*
 * swift 2.3
 */
/*
extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        if indices.contains(index) {
            return self[index]
        } else {
            DDLogError("Collection Type Out of bounds with: \(index)/\(indices.count)")
            return nil
        }
    }
}
*/

/*
 * swift 3.0
 */
extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return (startIndex..<endIndex).contains(index) ? self[index] : nil
    }
}

extension Collection
    where Indices.Iterator.Element: Equatable, Index == Indices.Iterator.Element{
    subscript (safe index: Indices.Iterator.Element) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

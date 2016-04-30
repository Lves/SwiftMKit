//
//  BaseKitEntity.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/28/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

struct BaseEntityProperty {
    static let entityId = "entityId"
    static let entityOrder = "entityOrder"
    static let entityUpdateTime = "entityUpdateTime"
    static let defaultSort = [
        NSSortDescriptor(key: BaseEntityProperty.entityOrder, ascending: true),
        NSSortDescriptor(key: BaseEntityProperty.entityUpdateTime, ascending: false)]
    static func predicateUpdateTimeNotNil() -> NSPredicate {
        return NSPredicate(format: "\(entityUpdateTime) != nil")
    }
}



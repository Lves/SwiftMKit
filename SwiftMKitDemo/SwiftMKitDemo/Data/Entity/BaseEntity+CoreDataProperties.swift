//
//  BaseEntity+CoreDataProperties.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/27/16.
//  Copyright © 2016 cdts. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BaseEntity {

    @NSManaged var entityId: String?
    @NSManaged var entityOrder: Int64
    @NSManaged var entityType: String?
    @NSManaged var entityUpdateTime: NSTimeInterval

}

//
//  PX500PhotosEntity+CoreDataProperties.swift
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

extension PX500PhotosEntity {

    @NSManaged var current_page: Int64
    @NSManaged var total_items: Int64
    @NSManaged var total_pages: Int64
    @NSManaged var photos: NSOrderedSet?

}

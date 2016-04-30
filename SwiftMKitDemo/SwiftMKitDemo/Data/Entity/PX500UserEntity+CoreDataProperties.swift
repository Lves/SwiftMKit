//
//  PX500UserEntity+CoreDataProperties.swift
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

extension PX500UserEntity {

    @NSManaged var fullName: String?
    @NSManaged var userId: String?
    @NSManaged var userName: String?
    @NSManaged var userPicUrl: String?
    @NSManaged var photos: NSSet?

}

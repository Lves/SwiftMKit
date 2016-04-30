//
//  PX500PhotoEntity+CoreDataProperties.swift
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

extension PX500PhotoEntity {

    @NSManaged var descriptionString: String?
    @NSManaged var favoritesCount: Int64
    @NSManaged var imageUrl: String?
    @NSManaged var name: String?
    @NSManaged var photoId: String?
    @NSManaged var url: String?
    @NSManaged var user_id: String?
    @NSManaged var votesCount: Int64
    @NSManaged var photos: PX500PhotosEntity?
    @NSManaged var user: PX500UserEntity?

}

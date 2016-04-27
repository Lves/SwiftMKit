//
//  TestStudentEntity+CoreDataProperties.swift
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

extension TestStudentEntity {

    @NSManaged var age: Int64
    @NSManaged var aliasName: String?
    @NSManaged var height: Double
    @NSManaged var money: Double
    @NSManaged var name: String?
    @NSManaged var teacher: TestTeacherEntity?

}

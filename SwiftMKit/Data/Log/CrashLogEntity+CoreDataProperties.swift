//
//  CrashLogEntity+CoreDataProperties.swift
//  
//
//  Created by Mao on 09/01/2017.
//
//

import Foundation
import CoreData


extension CrashLogEntity {
    @NSManaged public var createTime: NSDate?
    @NSManaged public var message: String?

}

//
//  LocalCrashLogReporter.swift
//  SwiftMKitDemo
//
//  Created by Mao on 09/01/2017.
//  Copyright © 2017 cdts. All rights reserved.
//

import UIKit
import CoreData

class LocalCrashLogReporter: NSObject, SwiftCrashReporter {
    static var shared = LocalCrashLogReporter()
    
    private var _managedObjectContext: NSManagedObjectContext?
    private var _managedObjectModel: NSManagedObjectModel?
    private var _persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    var managedObjectContext: NSManagedObjectContext {
        if _managedObjectContext != nil {
            return _managedObjectContext!
        }
        let coordinator = self.persistentStoreCoordinator
        _managedObjectContext = NSManagedObjectContext()
        _managedObjectContext?.persistentStoreCoordinator = coordinator
        return _managedObjectContext!
    }
    var managedObjectModel: NSManagedObjectModel {
        if _managedObjectModel != nil {
            return _managedObjectModel!
        }
        let modelURL = NSBundle.mainBundle().URLForResource("SwiftMKitLog", withExtension: "momd")
        _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        return _managedObjectModel!
    }
    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        if _persistentStoreCoordinator != nil {
            return _persistentStoreCoordinator!
        }
        _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let storeURL = applicationDocumentsDirectory?.URLByAppendingPathComponent("SwiftMKitLog.sqlite")
        try! _persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: [:])
        return _persistentStoreCoordinator!
    }
    
    var applicationDocumentsDirectory: NSURL? {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
    }
    
    func insertCrashLog(message: String) {
        let context = managedObjectContext
        if let model = NSEntityDescription.insertNewObjectForEntityForName("CrashLogEntity", inManagedObjectContext: context) as? CrashLogEntity {
            model.message = message
            model.createTime = NSDate()
            do {
                try context.save()
            } catch (let error) {
                print(error)
            }
        }
    }
    func queryCrashLog(page page: Int = 0, number: Int = 20) -> [CrashLogEntity] {
        let context = managedObjectContext
        let fetchRequest = NSFetchRequest()
        fetchRequest.fetchLimit = number
        fetchRequest.fetchOffset = page
        let entity = NSEntityDescription.entityForName("CrashLogEntity", inManagedObjectContext: context)
        fetchRequest.entity = entity
        let fetchedObjects = try! context.executeFetchRequest(fetchRequest)
        let array = fetchedObjects.map({ $0 as! CrashLogEntity })
        return array
    }
    
    override init() {
        SwiftCrashReport.install(LocalCrashLogReporter)
        super.init()
    }
    static func reportCrashMessage(message: String) {
        shared.insertCrashLog(message)
    }
}

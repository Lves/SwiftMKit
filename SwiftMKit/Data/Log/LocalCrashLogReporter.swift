//
//  LocalCrashLogReporter.swift
//  SwiftMKitDemo
//
//  Created by Mao on 09/01/2017.
//  Copyright © 2017 cdts. All rights reserved.
//

import UIKit
import CoreData

//class LocalCrashLogReporter: NSObject, SwiftCrashReporter {
//    static var shared = LocalCrashLogReporter()
//
//    private var _managedObjectContext: NSManagedObjectContext?
//    private var _managedObjectModel: NSManagedObjectModel?
//    private var _persistentStoreCoordinator: NSPersistentStoreCoordinator?
//
//    var managedObjectContext: NSManagedObjectContext {
//        if _managedObjectContext != nil {
//            return _managedObjectContext!
//        }
//        let coordinator = self.persistentStoreCoordinator
//        _managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        _managedObjectContext?.persistentStoreCoordinator = coordinator
//        return _managedObjectContext!
//    }
//    var managedObjectModel: NSManagedObjectModel {
//        if _managedObjectModel != nil {
//            return _managedObjectModel!
//        }
//        let modelURL = Bundle.main.url(forResource: "SwiftMKitLog", withExtension: "momd")
//        _managedObjectModel = NSManagedObjectModel(contentsOf: modelURL!)
//        return _managedObjectModel!
//    }
//    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
//        if _persistentStoreCoordinator != nil {
//            return _persistentStoreCoordinator!
//        }
//        _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//        let storeURL = applicationDocumentsDirectory?.appendingPathComponent("SwiftMKitLog.sqlite")
//        try! _persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [:])
//        return _persistentStoreCoordinator!
//    }
//
//    var applicationDocumentsDirectory: URL? {
//        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
//    }
//
//    func insertCrashLog(message: String) {
//        let context = managedObjectContext
//        if let model = NSEntityDescription.insertNewObject(forEntityName: "CrashLogEntity", into: context) as? CrashLogEntity {
//            model.message = message
//            model.createTime = Date()
//            do {
//                try context.save()
//            } catch (let error) {
//                print(error)
//            }
//        }
//    }
//    func queryCrashLog(page: Int = 0, number: Int = 20) -> [CrashLogEntity] {
//        let context = managedObjectContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
//        fetchRequest.fetchLimit = number
//        fetchRequest.fetchOffset = page
//        let entity = NSEntityDescription.entity(forEntityName: "CrashLogEntity", in: context)
//        fetchRequest.entity = entity
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: false)]
//        let fetchedObjects = try! context.fetch(fetchRequest)
//        let array = fetchedObjects.map({ $0 as! CrashLogEntity })
//        return array
//    }
//    func clean() {
//        let context = managedObjectContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
//        let entity = NSEntityDescription.entity(forEntityName: "CrashLogEntity", in: context)
//        fetchRequest.entity = entity
//        do
//        {
//            let results = try context.fetch(fetchRequest)
//            for managedObject in results
//            {
//                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
//                context.delete(managedObjectData)
//            }
//        } catch let error as NSError {
//            print("Detele all data in \(String(describing: entity)) error : \(error) \(error.userInfo)")
//        }
//    }
//
//    static func reportCrashMessage(_ message: String) {
//        shared.insertCrashLog(message: message)
//    }
//}

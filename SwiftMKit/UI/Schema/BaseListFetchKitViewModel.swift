//
//  BaseListFetchKitViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/27/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CoreData
import CocoaLumberjack

open class BaseListFetchKitViewModel: BaseListKitViewModel {
    open var listFetchViewController: BaseListFetchKitViewController! {
        get {
            return viewController as! BaseListFetchKitViewController
        }
    }
    open var fetchRequest: NSFetchRequest<NSFetchRequestResult>? {
        get {
            return nil
        }
    }
    public override var dataIndex: UInt {
        didSet {
            self.fetchRequest?.fetchLimit = Int(self.listLoadNumber * (self.dataIndex+1))
        }
    }
    open func fetchCachedData() {
        let logPrefix = "[\(NSStringFromClass(type(of: self))) \(#function)]"
        if let fetchedController = listFetchViewController.fetchedResultsController {
            if fetchedController.fetchRequest.predicate != nil {
                DDLogVerbose("\(logPrefix) fetching \(fetchedController.fetchRequest.entityName ?? "") with predicate: \(String(describing: fetchedController.fetchRequest.predicate))")
            } else {
                DDLogVerbose("\(logPrefix) fetching all \(fetchedController.fetchRequest.entityName ?? "") (no predicate)")
            }
            do {
                try fetchedController.performFetch()
                DDLogInfo("FetchedResultsController found \(fetchedController.fetchedObjects?.count ?? 0) objects")
                self.updateDataArray(fetchedController.fetchedObjects)
            } catch let error as NSError{
                DDLogError("\(logPrefix) perform fetch: failed. reason: \(error.localizedDescription) (\(error.localizedFailureReason ?? ""))")
            } catch {
                DDLogError("\(logPrefix) perform fetch: failed. reason: \(error)")
            }
        } else {
            DDLogError("\(logPrefix) no NSFetchedResultsController")
        }
    }
}

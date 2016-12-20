//
//  BaseListFetchKitViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/27/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CoreData
import CocoaLumberjack
import ReactiveCocoa

open class BaseListFetchKitViewController: BaseListKitViewController {
    open var listFetchViewModel: BaseListFetchKitViewModel! {
        get {
            return viewModel as! BaseListFetchKitViewModel
        }
    }
    open var listFetchView: UITableView! {
        get {
            return self.listView as! UITableView
        }
    }
    fileprivate var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    open var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        get {
            if _fetchedResultsController == nil {
                if let request = self.listFetchViewModel.fetchRequest {
                    _fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: NSManagedObjectContext.mr_default(), sectionNameKeyPath: nil, cacheName: nil)
                }
            }
            return _fetchedResultsController
        }
    }
    open override func loadData() {
        super.loadData()
        listFetchViewModel.fetchCachedData()
    }
    
    override open func objectByIndexPath(_ indexPath: IndexPath) -> Any? {
        let object = fetchedResultsController?.sections?[indexPath.section].objects?[safe: indexPath.row]
        return object as AnyObject?
    }
    
    override open func numberOfSections(in tableView: UITableView) -> Int {
        let sections = fetchedResultsController?.sections?.count
        return sections ?? 0
    }
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if (fetchedResultsController?.sections?.count ?? 0) > 0 {
            rows = fetchedResultsController?.sections?[section].numberOfObjects ?? 0
        }
        return rows
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(withTableView: tableView, indexPath: indexPath)!
        if let object = objectByIndexPath(indexPath) {
            configureCell(cell, object: object, indexPath: indexPath)
        }
        return cell
    }
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = getCell(withTableView: tableView, indexPath: indexPath)!
        if let object = objectByIndexPath(indexPath) {
            didSelectCell(cell, object: object, indexPath: indexPath)
        }
    }
}

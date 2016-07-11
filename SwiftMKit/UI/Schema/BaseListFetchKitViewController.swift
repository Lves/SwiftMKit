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

public class BaseListFetchKitViewController: BaseListKitViewController {
    public var listFetchViewModel: BaseListFetchKitViewModel! {
        get {
            return viewModel as! BaseListFetchKitViewModel
        }
    }
    public var listFetchView: UITableView! {
        get {
            return self.listView as! UITableView
        }
    }
    private var _fetchedResultsController: NSFetchedResultsController?
    public var fetchedResultsController: NSFetchedResultsController? {
        get {
            if _fetchedResultsController == nil {
                if let request = self.listFetchViewModel.fetchRequest {
                    _fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: NSManagedObjectContext.MR_defaultContext(), sectionNameKeyPath: nil, cacheName: nil)
                }
            }
            return _fetchedResultsController
        }
    }
    public override func loadData() {
        super.loadData()
        listFetchViewModel.fetchCachedData()
    }
    
    override public func objectByIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        let object = fetchedResultsController?.sections?[indexPath.section].objects?[safe: indexPath.row]
        return object
    }
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let sections = fetchedResultsController?.sections?.count
        return sections ?? 0
    }
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if fetchedResultsController?.sections?.count > 0 {
            rows = fetchedResultsController?.sections?[section].numberOfObjects ?? 0
        }
        return rows
    }
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCellWithTableView(tableView, indexPath: indexPath)!
        if let object = objectByIndexPath(indexPath) {
            configureCell(cell, object: object, indexPath: indexPath)
        }
        return cell
    }
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = getCellWithTableView(tableView, indexPath: indexPath)!
        if let object = objectByIndexPath(indexPath) {
            didSelectCell(cell, object: object, indexPath: indexPath)
        }
    }
}

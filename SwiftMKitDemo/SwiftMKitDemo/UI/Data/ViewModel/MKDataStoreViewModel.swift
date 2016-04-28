//
//  MKDataStoreViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa
import CoreData

class MKDataStoreViewModel: BaseListFetchViewModel {
    
    private var signalPX500PhotosCoreData: SignalProducer<PX500PopularPhotosCoreDataApiData, NetError> {
        get {
            return PX500PopularPhotosCoreDataApiData(page:self.dataIndex+1, number:self.listLoadNumber).setIndicatorList(self.listIndicator).signal().on(
                next: { [weak self] data in
                    if let photos = data.photosCoreData {
                        self?.updateDataSource(photos)
                    }
                },
                failed: { [weak self] error in
                    self?.showTip(error.message)
                })
        }
    }
    private var _fetchRequest: NSFetchRequest?
    override var fetchRequest: NSFetchRequest? {
        if _fetchRequest == nil {
            _fetchRequest = NSFetchRequest(entityName: "PX500PhotosEntity")
            let sort1 = NSSortDescriptor(key: "entityUpdateTime", ascending: false)
            let sort2 = NSSortDescriptor(key: "entityOrder", ascending: true)
            _fetchRequest?.sortDescriptors = [sort1, sort2]
        }
        return _fetchRequest
    }
    
    override func fetchData() {
        signalPX500PhotosCoreData.start()
    }
}

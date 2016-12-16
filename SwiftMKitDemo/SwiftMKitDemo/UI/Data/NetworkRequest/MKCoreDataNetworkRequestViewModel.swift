//
//  MKDataStoreViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import CoreData

class MKCoreDataNetworkRequestViewModel: BaseListFetchViewModel {
    
    fileprivate var signalPX500PhotosCoreData: SignalProducer<PX500PopularPhotosCoreDataApiData, NetError> {
        get {
            return PX500PopularPhotosCoreDataApiData(page:self.dataIndex+1, number:self.listLoadNumber).setIndicator(self.listIndicator).signal().on(
                starting: { [weak self] data in
                    self?.fetchCachedData()
                },
                failed: { [weak self] error in
                    self?.showTip(error.message)
                })
        }
    }
    fileprivate var _fetchRequest: NSFetchRequest<NSFetchRequestResult>?
    override var fetchRequest: NSFetchRequest<NSFetchRequestResult>? {
        if _fetchRequest == nil {
            _fetchRequest = NSFetchRequest(entityName: NSStringFromClass(PX500PhotoEntity))
            _fetchRequest?.sortDescriptors = BaseEntityProperty.defaultSort
            _fetchRequest?.fetchBatchSize = Int(listLoadNumber)
            _fetchRequest?.fetchLimit = Int(listLoadNumber * (dataIndex + 1))
        }
        return _fetchRequest
    }
    
    override func fetchData() {
        signalPX500PhotosCoreData.start()
    }
}

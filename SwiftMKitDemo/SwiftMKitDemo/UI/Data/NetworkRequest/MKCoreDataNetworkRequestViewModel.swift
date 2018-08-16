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

public class MKCoreDataNetworkRequestViewModel: BaseListFetchViewModel {
    
//    fileprivate var signalPX500PhotosCoreData: SignalProducer<PX500PopularPhotosCoreDataApiData, NetError> {
//        get {
//            return PX500PopularPhotosCoreDataApiData(page:self.dataIndex+1, number:self.listLoadNumber).signal().on(
//                failed: { [weak self] error in
//                    self?.showTip(error.message)
//                }, value: { [weak self] data in
//                    self?.fetchCachedData()
//                })
//        }
//    }
//    fileprivate var _fetchRequest: NSFetchRequest<NSFetchRequestResult>?
//    override var fetchRequest: NSFetchRequest<NSFetchRequestResult>? {
//        if _fetchRequest == nil {
//            _fetchRequest = NSFetchRequest(entityName: NSStringFromClass(PX500PhotoEntity.self))
//            _fetchRequest?.sortDescriptors = BaseEntityProperty.defaultSort
//            _fetchRequest?.fetchBatchSize = Int(listLoadNumber)
//            _fetchRequest?.fetchLimit = Int(listLoadNumber * (dataIndex + 1))
//        }
//        return _fetchRequest
//    }
//    
//    override func fetchData() {
//        signalPX500PhotosCoreData.start()
//    }
}

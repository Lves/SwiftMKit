//
//  MKDataStoreViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa

class MKDataStoreViewModel: BaseListViewModel {
    
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
    
    override func fetchData() {
        signalPX500PhotosCoreData.start()
    }
}

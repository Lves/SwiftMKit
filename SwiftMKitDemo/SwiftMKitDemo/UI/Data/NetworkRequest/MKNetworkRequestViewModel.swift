//
//  MKDataNetworkRequestViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class MKNetworkRequestViewModel: BaseListViewModel {
    
    fileprivate var signalPX500Photos: SignalProducer<PX500PopularPhotosApiData, NetError> {
        get {
                return PX500PopularPhotosApiData(page:self.dataIndex+1, number:self.listLoadNumber).setIndicator(self.listIndicator).signal().on(
                    failed: { [weak self] error in
                        self?.showTip(error.message)
                    },
                    value: { [weak self] data in
                        if let photos = data.photos {
                            self?.updateDataArray(photos)
                        }
                })
        }
    }
    
    override func fetchData() {
        signalPX500Photos.start()
    }
    
    
}

//
//  MKDataNetworkRequestViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa

class MKNetworkRequestViewModel: BaseListViewModel {
    
    var encrypt = false
    
    private var signalPX500Photos: SignalProducer<PX500PopularPhotosApiData, NetError> {
        get {
                return PX500PopularPhotosApiData(page:self.dataIndex+1, number:self.listLoadNumber).setIndicator(self.listIndicator).signal().on(
                    next: { [weak self] data in
                        if let photos = data.photos {
                            self?.updateDataArray(photos)
                        }
                    },
                    failed: { [weak self] error in
                        self?.showTip(error.message)
                    })
        }
    }
    private var signalPX500PhotosEncrypt: SignalProducer<PX500PopularPhotosEncryptApiData, NetError> {
        get {
                return PX500PopularPhotosEncryptApiData(page:self.dataIndex+1, number:self.listLoadNumber).setIndicator(self.listIndicator).signal().on(
                    next: { [weak self] data in
                        if let photos = data.photos {
                            self?.updateDataArray(photos)
                        }
                    },
                    failed: { [weak self] error in
                        self?.showTip(error.message)
                    })
        }
    }
    
    override func fetchData() {
        if encrypt {
            signalPX500PhotosEncrypt.start()
        } else {
            signalPX500Photos.start()
        }
    }
    
    
}

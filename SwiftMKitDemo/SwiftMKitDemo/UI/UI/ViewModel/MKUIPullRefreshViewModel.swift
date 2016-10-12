//
//  MKUIPullRefreshViewModel.swift
//  SwiftMKitDemo
//
//  Created by LiXingLe on 16/7/18.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa
class MKUIPullRefreshViewModel: BaseListViewModel {
    
    
    private var signalRequest: SignalProducer<PX500PopularPhotosApiData, NetError> {
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
    
    override func fetchData() {

        self.signalRequest.start()
  
    }

}

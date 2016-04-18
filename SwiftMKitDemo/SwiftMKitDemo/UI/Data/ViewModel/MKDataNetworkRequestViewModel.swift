//
//  MKDataNetworkRequestViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa

class MKDataNetworkRequestViewModel: BaseListViewModel {
    
    lazy var signalPX500Photos: SignalProducer<PX500PopularPhotosApiData, NSError> = { [unowned self] in
        return PX500PopularPhotosApiData(page:self.dataIndex, number:self.listLoadNumber).setIndicator(self.listViewController).setIndicatorList(self.listViewController).signal().on(
            next: { [weak self] data in
                if let photos = data.photos {
                    self?.updateDataSource(photos)
                }
            },
            failed: { [weak self] error in
                self?.viewController.showTip(error.description)
        })
    }()
    
    override func fetchData() {
        signalPX500Photos.start()
    }
    
    
}

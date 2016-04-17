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
    
    var signalPX500Photos: SignalProducer<PX500PopularPhotosApiData, NSError> {
        get {
            return PX500PopularPhotosApiData(page:dataIndex, number:listLoadNumber).setIndicator(self.listViewController).setIndicatorList(self.listViewController).signal().on(
                next: { [weak self] data in
                    if let photos = data.photos {
                        self?.updateDataSource(photos)
                        let tableView = self?.listViewController?.listView as? UITableView
                        tableView?.reloadData()
                    }
                },
                failed: { error in
            })
        }
    }
    
    override func fetchData() {
        signalPX500Photos.start()
    }
}

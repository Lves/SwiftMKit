//
//  MKDataNetworkImagesViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/4/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa

class MKDataNetworkImagesViewModel: BaseListViewModel {
    
    var signalBaiduCities: SignalProducer<BaiduCitiesApiData, NSError> {
        get {
            return BaiduCitiesApiData().setIndicator(self.listViewController).signal().on(
                next: { [weak self] data in
                    if let cities = data.cities {
                        self?.dataSource = cities
                        let tableView = self?.listViewController?.listView as? UITableView
                        tableView?.reloadData()
                    }
                },
                failed: { error in
            })
        }
    }
    override func fetchData() {
        signalBaiduCities.start()
    }
}

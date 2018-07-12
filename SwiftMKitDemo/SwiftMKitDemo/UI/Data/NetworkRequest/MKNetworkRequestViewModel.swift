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
    
    var signalNews: SignalProducer<NewsListApi, NetError> {
        get {
            return NewsListApi(offset: dataIndex * listLoadNumber, size: listLoadNumber).setIndicator(taskListIndicator).get(format: .string) { [weak self] data in
                if let news = data.news {
                    self?.updateDataArray(news)
                }
            }
        }
    }
    
    override func fetchData() {
        signalNews.start()
    }
    
    
}

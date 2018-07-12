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
    
    var signalNews: SignalProducer<ToutiaoNewsListApi, NetError> {
        get {
            return ToutiaoNewsListApi(start: (self.dataArray.last as? NewsModel)?.behot_time ?? 0, count: 20).setIndicator(taskListIndicator).get { [weak self] data in
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

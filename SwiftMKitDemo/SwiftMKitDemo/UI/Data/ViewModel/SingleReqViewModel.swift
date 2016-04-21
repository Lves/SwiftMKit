//
//  SingleReqViewModel.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa
import CocoaLumberjack

class SingleReqViewModel: BaseViewModel {
    private var signalTmpAds: SignalProducer<BuDeJieADApiData, NSError> {
        get {
            return BuDeJieADApiData().setIndicator(self.indicator, view:self.view).signal().on(
                next: { data in
                    if let ads = data.ads {
                        DDLogInfo("\(ads)")
                    }
                },
                failed: { error in
                    self.showTip(error.description)
                }
            )
        }
    }
    
    var signal1: SignalProducer<BuDeJieADApiData, NSError> = BuDeJieADApiData().signal().flatMapError { error in
        DDLogError("error= \(error)")
        return SignalProducer.empty
    }
    var signal2: SignalProducer<BuDeJieADApiData, NSError> = BuDeJieADApiData().signal().flatMapError { error in
        DDLogError("error= \(error)")
        return SignalProducer.empty
    }
    var signalCombineLatest: SignalProducer<Bool, NSError> {
        get {
            return combineLatest(signal1, signal2).reduce(false, {  (data1, data2) in
                DDLogInfo("data1: \(data1)")
                DDLogInfo("data2: \(data2)")
                return true
            }).on(next: { [weak self] result in
                self?.hideLoading()
                DDLogInfo("result: \(result)")
                }, failed: { [weak self] error in
                    self?.showTip(error.description)
            })
        }
    }
    
    override func fetchData() {
        self.showLoading()
        signalCombineLatest.start()
    }
}

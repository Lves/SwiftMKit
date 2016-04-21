//
//  SingleReqViewModel.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SingleReqViewModel: BaseViewModel {
    private var signalTmpAds: SignalProducer<TmpADApiData, NSError> {
        get {
            // signal()： NetApiProtocol协议里的方法
            return TmpADApiData().setIndicator(self.indicator, view:self.view).signal().on(
                next: { data in
                    if let ads = data.ads {
                        print("\(ads)")
                    }
                },
                failed: { error in
                    self.viewController.showTip(error.description)
                }
            )
        }
    }
    
    var signal1: SignalProducer<TmpADApiData, NSError> = TmpADApiData().signal()
    var signal2: SignalProducer<TmpADApiData, NSError> = TmpADApiData().signal().map({ data in
        return data
    }).flatMapError { error in
        print("error= \(error)")
        return SignalProducer.empty
    }
    var singal3: SignalProducer<(Bool, TmpADApiData?, TmpADApiData?), NSError>?  {
        get {
            return signal1.combineLatestWith(signal2).reduce((false, nil, nil)) { (_, data) in
                let (result1, result2) = data
                print("===\(result1.ads!)  \(result2.ads!)")
                return (true, result1, result2)
                }
//                .on(next: { (flag, data1, data2) in
//                    print("\(flag)  \(data1!.ads!)   \(data2!.ads!)")
//                    NSThread.sleepForTimeInterval(5)
//                    self.hud?.hideHUDForView(self.viewController.view, animated: true)
//                },
//                failed: { error in
//                    self.hud?.hideHUDForView(self.viewController.view, animated: true)
//                })
        }
    }
    
    override func fetchData() {
        singal3!.start()
        hud.showHUDAddedTo(viewController.view, animated: true, text: "正在拼命加载中...")
    }
}

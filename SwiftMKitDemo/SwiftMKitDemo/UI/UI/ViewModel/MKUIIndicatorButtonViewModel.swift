//
//  MKUIIndicatorButtonViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/17/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa

class MKUIIndicatorButtonViewModel: BaseViewModel {
    
    var actionButton: Action<AnyObject, AnyObject, NSError> {
        get {
            return Action<AnyObject, AnyObject, NSError> { input in
                return SignalProducer { (sink, _) in
                    sink.sendNext(input)
                    sink.sendCompleted()
                    }.delay(1, onScheduler: QueueScheduler())
            }
        }
    }
}

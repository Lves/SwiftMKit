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
    
    lazy var actionButton: CocoaAction = {
        let action = Action<AnyObject, AnyObject, NSError> { [weak self] input in
            return SignalProducer { [weak self] (sink, _) in
                    sink.sendNext(input)
                    sink.sendCompleted()
                }.delay(2, onScheduler: QueueScheduler())
        }
        return CocoaAction(action, input:"")
    }()
}

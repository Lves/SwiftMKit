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
    
    func actionButton(button: UIButton) -> CocoaAction {
        let action = Action<AnyObject, AnyObject, NSError> { input in
            return SignalProducer { (sink, _) in
                sink.sendNext(input)
                sink.sendCompleted()
            }.delay(1, onScheduler: QueueScheduler())
        }
        return CocoaAction(action, input: button)
    }
    
    var actionButton: Action<AnyObject, AnyObject, NSError> {
        get {
        return Action { input in
            return SignalProducer { (sink, _) in
                sink.sendNext(input)
                sink.sendCompleted()
                }.delay(1, onScheduler: QueueScheduler())
        }
        }
    }
}

//
//  MKUIIndicatorButtonViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/17/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack
import ReactiveCocoa

class MKIndicatorButtonViewController: BaseViewController {
    
    @IBOutlet var buttons: [IndicatorButton]!
    private var _viewModel = MKUIIndicatorButtonViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    override func setupUI() {
        super.setupUI()
        self.title = "Indicator Button"
        buttons.last?.animateDirection = IndicatorButton.AnimateDirection.FromUpToDown
        buttons.first?.indicatorPosition = .Right
    }
    override func bindingData() {
        super.bindingData()
        for button in buttons {
            button.cornerRadius = 3
            button.addTarget(_viewModel.actionButton.toCocoaAction, action: CocoaAction.selector, forControlEvents: .TouchUpInside)

        }
    }
}

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
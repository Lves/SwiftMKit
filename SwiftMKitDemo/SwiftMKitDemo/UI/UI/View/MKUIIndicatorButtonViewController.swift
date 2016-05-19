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

class MKUIIndicatorButtonViewController: BaseViewController {
    
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
            let action = _viewModel.actionButton
            action.unsafeCocoaAction.rac_valuesForKeyPath("enabled", observer: nil).toSignalProducer().map{ $0! as! Bool }.startWithNext { enabled in
                button.enabled = enabled
            }
            button.addTarget(action.unsafeCocoaAction, action: CocoaAction.selector, forControlEvents: .TouchUpInside)

        }
    }
}

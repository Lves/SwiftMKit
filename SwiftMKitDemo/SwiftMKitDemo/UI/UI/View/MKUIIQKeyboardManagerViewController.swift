//
//  MKUIIQKeyboardManagerViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/29/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKUIIQKeyboardManagerViewController: BaseViewController {
    
    private var _viewModel = MKUIIQKeyboardManagerViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
}

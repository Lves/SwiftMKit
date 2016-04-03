//
//  BaseKitViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit

public class BaseKitViewController : UIViewController{
    public var viewModel: BaseKitViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public func setupUI() {
    }
    public func loadData() {
    }
}
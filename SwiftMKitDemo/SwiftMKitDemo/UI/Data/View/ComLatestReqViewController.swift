//
//  ComLatestReqViewController.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

/// 多个请求-combineLatest
class ComLatestReqViewController: BaseViewController {

    private var _viewModel = ComLatestReqViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    
    override func setupUI() {
        super.setupUI()
        self.title = "combineLatest"
        loadData()
    }
    override func loadData() {
        super.loadData()
        _viewModel.fetchData()
    }
    override func bindingData() {
        
    }

}

//
//  MergeReqViewController.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

/// 多个请求-Merge
class MergeReqViewController: BaseViewController {

    private var _viewModel = MergeReqViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    
    override func setupUI() {
        super.setupUI()
        self.title = "Merge"
        loadData()
    }
    override func loadData() {
        super.loadData()
        _viewModel.fetchData()
    }
    override func bindingData() {
        
    }
}

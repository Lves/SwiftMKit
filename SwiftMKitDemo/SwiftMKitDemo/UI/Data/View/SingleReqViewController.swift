//
//  SingleReqViewController.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

/// 多个请求-单独处理每个请求
class SingleReqViewController: BaseViewController {

    private var _viewModel = SingleReqViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    
    override func setupUI() {
        super.setupUI()
        self.title = "单独处理每个请求"
        loadData()
    }
    override func loadData() {
        super.loadData()
        _viewModel.fetchData()
    }
    override func bindingData() {
        
    }

}

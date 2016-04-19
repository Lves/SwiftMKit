//
//  MKDataNetworkWithImagesViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/4/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Alamofire
import CocoaLumberjack

class MKDataNetworkRequestDetailViewController: BaseViewController {
    var photoId: String?
    
    private var _viewModel = MKDataNetworkRequestDetailViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    
    override func setupUI() {
        super.setupUI()
        self.title = "Photo Detail"
        loadData()
    }
    override func loadData() {
        super.loadData()
        _viewModel.fetchData()
    }
    
}

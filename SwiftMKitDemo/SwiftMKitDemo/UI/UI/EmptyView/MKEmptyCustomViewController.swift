//
//  MKEmptyCustomViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 17/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKEmptyCustomViewController: BaseViewController {

    override func getEmptyView() -> BaseKitEmptyView {
        return MKCustomEmptyView.getView()
    }
    override func setupUI() {
        super.setupUI()
//        emptyView?.image = UIImage(named: "view_custom_empty")!
//        emptyView?.yOffset = -150
        emptyView?.titleLabel.textColor = UIColor.blue
        loadData()
        NetworkDemo().test()
    }
    override func loadData() {
        super.loadData()
        emptyView?.show(title: "这里没有数据哦")
    }

}

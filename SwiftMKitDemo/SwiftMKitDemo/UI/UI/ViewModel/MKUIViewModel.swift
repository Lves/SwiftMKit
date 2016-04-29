//
//  MKUIViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/29/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKUIViewModel: BaseListViewModel {
    override init() {
        super.init()
        self.dataSource = [MKDataListModel]()
        self.dataSource.append(MKDataListModel(title: "Web View", detail: "UIWebView"))
        self.dataSource.append(MKDataListModel(title: "IQKeyboardManager", detail: "Keyboard Auto Scroll"))
    }

}

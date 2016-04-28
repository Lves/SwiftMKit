//
//  MKDataViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKDataViewModel: BaseListViewModel {
    override init() {
        super.init()
        self.dataSource = [MKDataListModel]()
        self.dataSource.append(MKDataListModel(title: "Network Request", detail: "Request a url"))
        self.dataSource.append(MKDataListModel(title: "Data Store", detail: "CoreData"))
        self.dataSource.append(MKDataListModel(title: "Web View", detail: "UIWebView"))
    }
}

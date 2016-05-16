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
        self.dataArray = [MKDataListModel]()
        self.dataArray.append(MKDataListModel(title: "Web View", detail: "UIWebView"))
        self.dataArray.append(MKDataListModel(title: "IQKeyboardManager", detail: "Keyboard Auto Scroll"))
        self.dataArray.append(MKDataListModel(title: "Side View", detail: "Side View"))
        self.dataArray.append(MKDataListModel(title: "Chart View", detail: "Chart View"))
        self.dataArray.append(MKDataListModel(title: "Keyboard View", detail: "Custom Keyboard"))
        self.dataArray.append(MKDataListModel(title: "Segment ViewController", detail: "Child ViewController"))
        self.dataArray.append(MKDataListModel(title: "Gesture Password", detail: "Gesture View"))
    }

}

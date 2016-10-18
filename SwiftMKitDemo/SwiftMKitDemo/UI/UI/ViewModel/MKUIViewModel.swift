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
        self.dataArray.append(MKDataListModel(title: "Empty View", detail: "Empty View", route: "MKEmptyViewController", routeSB: "MKEmptyView"))
        self.dataArray.append(MKDataListModel(title: "Web View", detail: "UIWebView", route: "http://www.baidu.com"))
        self.dataArray.append(MKDataListModel(title: "Segment View", detail: "Segment View", route: "MKSegmentViewController", routeSB: "MKSegmentView"))
        self.dataArray.append(MKDataListModel(title: "Side View", detail: "Side View", route: "MKSideViewController", routeSB: "MKSideView"))
        self.dataArray.append(MKDataListModel(title: "Tree View", detail: "Tree View", route: "MKTreeViewController", routeSB: "MKTreeView"))
        self.dataArray.append(MKDataListModel(title: "Order View", detail: "Order TableView Cell", route: "MKOrderTableViewController", routeSB: "MKOrderView"))
        self.dataArray.append(MKDataListModel(title: "Chart View", detail: "Chart View", route: "MKChartViewController", routeSB: "MKChartView"))
        self.dataArray.append(MKDataListModel(title: "Keyboard View", detail: "Custom Keyboard", route: "MKKeyboardViewController"))
        self.dataArray.append(MKDataListModel(title: "IQKeyboard Manager", detail: "Keyboard Auto Scroll", route: "MKIQKeyboardManagerViewController"))
        self.dataArray.append(MKDataListModel(title: "Gesture Password View", detail: "Gesture Password View", route: "MKGesturePasswordViewController", routeSB: "MKGesturePasswordView"))
        self.dataArray.append(MKDataListModel(title: "Indicator Button", detail: "Button"))
        self.dataArray.append(MKDataListModel(title: "Galary Collection View", detail: "Collection View"))
        
        self.dataArray.append(MKDataListModel(title: "AlertView", detail: "Show Alert View"))
        self.dataArray.append(MKDataListModel(title: "CoverFlowView", detail: "Show CoverFlow View"))
        self.dataArray.append(MKDataListModel(title: "Pull Refresh", detail: "Custom Refresh Header"))

    }

}

//
//  MKUIViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/29/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import SwiftMKit

class MKUIViewModel: BaseListViewModel {
    override init() {
        super.init()
        self.dataArray = [MKDataListModel]()
        self.dataArray.append(MKDataListModel(title: "Empty View", detail: "Empty View", route: "MKEmptyViewController", routeSB: "MKEmptyView"))
        self.dataArray.append(MKDataListModel(title: "Web View", detail: "WKWebView", route: "https://www.baidu.com"))
        self.dataArray.append(MKDataListModel(title: "Segment View", detail: "Segment View", route: "MKSegmentViewController", routeSB: "MKSegmentView"))
        self.dataArray.append(MKDataListModel(title: "Side View", detail: "Side View", route: "MKSideViewController", routeSB: "MKSideView"))
        self.dataArray.append(MKDataListModel(title: "Tree View", detail: "Tree View", route: "MKTreeViewController", routeSB: "MKTreeView"))
        self.dataArray.append(MKDataListModel(title: "Order View", detail: "Order TableView Cell", route: "MKOrderTableViewController", routeSB: "MKOrderView"))
        self.dataArray.append(MKDataListModel(title: "Chart View", detail: "Chart View", route: "MKChartViewController", routeSB: "MKChartView"))
        self.dataArray.append(MKDataListModel(title: "Keyboard View", detail: "Custom Keyboard", route: "MKKeyboardViewController"))
        self.dataArray.append(MKDataListModel(title: "IQKeyboard Manager", detail: "Keyboard Auto Scroll", route: "MKIQKeyboardManagerViewController"))
        self.dataArray.append(MKDataListModel(title: "Gesture Password View", detail: "Gesture Password View", route: "MKGesturePasswordViewController", routeSB: "MKGesturePasswordView"))
        self.dataArray.append(MKDataListModel(title: "Galary Collection View", detail: "Collection View", route: "MKGalaryCollectionViewController", routeSB: "MKGalaryCollectionView"))
        self.dataArray.append(MKDataListModel(title: "CoverFlow View", detail: "CoverFlow View", route: "MKCoverFlowViewController", routeSB: "MKCoverFlowView"))
        self.dataArray.append(MKDataListModel(title: "Pull Refresh View", detail: "Custom Refresh Header", route: "MKCustomPullRefreshViewController"))
        self.dataArray.append(MKDataListModel(title: "Indicator Button", detail: "Indicator Button", route: "MKIndicatorButtonViewController"))
        self.dataArray.append(MKDataListModel(title: "MBProgress HUD", detail: "MBProgress HUD", route: "MKMBProgressHUDViewController"))
        self.dataArray.append(MKDataListModel(title: "CLLoopView", detail: "CLLoopView", route: "CLLoopViewController", routeSB: "CLLoopView"))
        self.dataArray.append(MKDataListModel(title: "RingedPages", detail: "RingedPages", route: "RingedPagesViewController", routeSB: "RingedPages"))
        self.dataArray.append(MKDataListModel(title: "PickerTextField", detail: "PickerTextField", route: "PickerTextFieldViewController", routeSB: "PickerTextField"))
        self.dataArray.append(MKDataListModel(title: "H5AndNativeDemo", detail: "H5AndNativeDemo", route: "H5AndNativeDemo", routeSB: "H5AndNative"))
        self.dataArray.append(MKDataListModel(title: "LinkTextView", detail: "LinkTextViewController", route: "LinkTextViewController", routeSB: "LinkText"))
        
    }

}

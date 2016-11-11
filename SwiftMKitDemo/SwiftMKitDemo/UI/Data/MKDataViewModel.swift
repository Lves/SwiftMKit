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
        self.dataArray = [MKDataListModel]()
        self.dataArray.append(MKDataListModel(title: "Network Status", detail: "Unknown"))
        self.dataArray.append(MKDataListModel(title: "Location Status", detail: "Unknown"))
        self.dataArray.append(MKDataListModel(title: "User Notification", detail: "Notification", route: "MKUserNotificationViewController", routeSB: "MKUserNotification"))
        self.dataArray.append(MKDataListModel(title: "Network Request", detail: "Request a url", route: "MKNetworkRequestViewController", routeSB: "MKNetworkRequestView"))
        self.dataArray.append(MKDataListModel(title: "CoreData & Network Request", detail: "CoreData", route: "MKCoreDataNetworkRequestViewController", routeSB: "MKNetworkRequestView"))
    }
}

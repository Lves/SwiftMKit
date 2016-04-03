//
//  BaseListKitViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

public class BaseListKitViewModel: BaseKitViewModel {
    public var listViewController: BaseListKitViewController? {
        get {
            return viewController as? BaseListKitViewController
        }
    }
    var dataSource:Array<AnyObject> = Array<AnyObject>()
    var dataIndex: UInt = 0
    let listLoadNumber: UInt = 20
    let listMaxNumber = UIntMax()
}

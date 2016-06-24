//
//  UpgradeAppProtocol.swift
//  Merak
//
//  Created by Mao on 6/24/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import Foundation

public protocol UpgradeAppProtocol {
    var appId: String { get }
    func checkUpgrade(appId: String, version: String, channelId: String)
}
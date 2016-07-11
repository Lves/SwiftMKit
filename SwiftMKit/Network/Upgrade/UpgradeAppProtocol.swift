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
    var channelId: String { get }
    var version: String { get }
    func requestUpgrade(appId: String, version: String, channelId: String, deviceId: String, completion:(needUpgrade: Bool, newVersion: String, upgradeMessage: String, downloadUrl: String) -> Void)
}
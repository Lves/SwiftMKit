//
//  UpgradeAppProtocol.swift
//  Merak
//
//  Created by Mao on 6/24/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import Foundation

public protocol UpgradeAppProtocol {
    static var appId: String { get }
    static var channelId: String { get }
    static var version: String { get }
    static func requestUpgrade(appId: String, version: String, channelId: String, deviceId: String, completion:(needUpgrade: Bool, newVersion: String, upgradeMessage: String, downloadUrl: String) -> Void)
}
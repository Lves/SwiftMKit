//
//  UpgradeAppProtocol.swift
//  Merak
//
//  Created by Mao on 6/24/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import Foundation

public protocol UpgradeAppProtocol {
    var version: String { get }
    func requestUpgrade(version: String, completion:(_ needUpgrade: Bool, _ newVersion: String, _ upgradeMessage: String, _ downloadUrl: String) -> Void)
}

//
//  EncryptNetworkManager.swift
//  SwiftMKitDemo
//
//  Created by yushouren on 16/10/19.
//  Copyright © 2016年 cdts. All rights reserved.
//

import Foundation
import NetworkEncrypt

public enum NetworkEncryptStatusCode: Int {
    case UpgradeApp = 9000
    case NetworkUnsafe = 9001
}

public class EncryptNetworkManager: NSObject {
    private var encryptedTimer: NSTimer?
    private override init() {
    }
    public static let shared = EncryptNetworkManager()
    
    public func initEncryptFramework(appId: String, vId: String) {
        EncryptedNetworkManager.sharedEncryptedNetworkManager().setAppId(appId, vId: vId)
    }
    
    public func disableEncrypt() {
        EncryptedRequest.disableEncrypt = true;
        self.encryptedTimer = NSTimer(timeInterval: DisableEncryptTime, target: self, selector: #selector(enableEncrypt), userInfo: nil, repeats: false);
    }
    
    @objc private func enableEncrypt() {
        EncryptedRequest.disableEncrypt = false;
        self.encryptedTimer?.invalidate();
        self.encryptedTimer = nil;
    }
}
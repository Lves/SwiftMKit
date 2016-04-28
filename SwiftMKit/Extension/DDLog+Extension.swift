//
//  DDLog+Extension.swift
//  SwiftMKitDemo
//
//  Created by Juxin on 4/28/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import CocoaLumberjack

public extension DDLog {
    public class func setup(level: DDLogLevel = DDLogLevel.Debug) {
        defaultDebugLevel = level
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        DDLog.addLogger(DDASLLogger.sharedInstance())
        DDTTYLogger.sharedInstance().colorsEnabled = true
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.blueColor(), backgroundColor: nil, forFlag: .Info)
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor(rgba: "#008040"), backgroundColor: nil, forFlag: .Verbose)
        DDLogVerbose("Verbose")
        DDLogDebug("Debug")
        DDLogInfo("Info")
        DDLogWarn("Warn")
        DDLogError("Error")
    }
}
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
    public class func setup(level: DDLogLevel = DDLogLevel.debug) {
        defaultDebugLevel = level
        DDLog.add(DDTTYLogger.sharedInstance())
        DDLog.add(DDASLLogger.sharedInstance())
        DDTTYLogger.sharedInstance().colorsEnabled = true
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor.blue, backgroundColor: nil, for: .info)
        DDTTYLogger.sharedInstance().setForegroundColor(UIColor(rgba: "#008040"), backgroundColor: nil, for: .verbose)
        DDLogVerbose("Verbose")
        DDLogDebug("Debug")
        DDLogInfo("Info")
        DDLogWarn("Warn")
        DDLogError("Error")
    }
}

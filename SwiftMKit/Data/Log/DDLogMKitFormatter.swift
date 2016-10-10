//
//  DDLogCustomFormatter.swift
//  SwiftMKitDemo
//
//  Created by Mao on 09/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import CocoaLumberjack

class DDLogMKitFormatter: NSObject, DDLogFormatter {
    func formatLogMessage(logMessage: DDLogMessage) -> String {
        let date = dateFormatter().stringFromDate(logMessage.timestamp)
        return "\(date) \(logMessage.fileName)[T\(logMessage.threadID):L\(logMessage.line)] " + logMessage.message
    }
    
    private func dateFormatter() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        return formatter
    }
}
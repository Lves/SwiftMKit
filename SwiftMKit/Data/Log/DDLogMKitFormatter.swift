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
    /**
     * Formatters may optionally be added to any logger.
     * This allows for increased flexibility in the logging environment.
     * For example, log messages for log files may be formatted differently than log messages for the console.
     *
     * For more information about formatters, see the "Custom Formatters" page:
     * Documentation/CustomFormatters.md
     *
     * The formatter may also optionally filter the log message by returning nil,
     * in which case the logger will not log the message.
     **/
    public func format(message logMessage: DDLogMessage!) -> String! {
        let date = dateFormatter().string(from: logMessage.timestamp)
        return "\(date) \(logMessage.fileName)[T\(logMessage.threadID):L\(logMessage.line)] " + logMessage.message
    }
    
    fileprivate func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        return formatter
    }
}

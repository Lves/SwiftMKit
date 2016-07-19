//
//  SwiftCrashConsoleReporter.swift
//  SwiftCrashReport
//
//  Created by yingdong.guo on 16/7/14.
//  Copyright © 2016年 pintec.com. All rights reserved.
//

import Foundation

/**
 * Default implementation of crash reporter, output the crash report to stdout.
 */
class SwiftCrashConsoleReporter : SwiftCrashReporter {
    @objc class func reportCrashMessage(message: String) {
        print(message)
    }
}
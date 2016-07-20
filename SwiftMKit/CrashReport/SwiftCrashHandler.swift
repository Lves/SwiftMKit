//
//  SwiftCrashHandler.swift
//  SwiftCrashReport
//
//  Created by yingdong.guo on 16/7/14.
//  Copyright © 2016年 pintec.com. All rights reserved.
//

import Foundation

func handleSwiftCrash(crashContext: UnsafeMutablePointer<MachExceptionContext>) {
    SwiftCrashHandler.reportCrashWithContext(crashContext.memory)
}

class SwiftCrashHandler {
    private static var _formatter: SwiftCrashFormatter.Type = SwiftCrashDefaultFormatter.self
    private static var _reporter: SwiftCrashReporter.Type = SwiftCrashConsoleReporter.self
    
    class func setFormatter(formatter: SwiftCrashFormatter.Type) {
        _formatter = formatter
    }
    
    class func setReporter(reporter: SwiftCrashReporter.Type) {
        _reporter = reporter
    }
    
     class func reportCrashWithContext(crashContext: MachExceptionContext) {
        _reporter.reportCrashMessage(_formatter.formatCrashMessage(crashContext))
    }
}
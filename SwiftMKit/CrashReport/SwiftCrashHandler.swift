//
//  SwiftCrashHandler.swift
//  SwiftCrashReport
//
//  Created by yingdong.guo on 16/7/14.
//  Copyright © 2016年 All rights reserved.
//

import Foundation

func handleSwiftCrash(_ crashContext: UnsafeMutablePointer<MachExceptionContext>) {
    SwiftCrashHandler.reportCrashWithContext(crashContext.pointee)
}

class SwiftCrashHandler {
    fileprivate static var _formatter: SwiftCrashFormatter.Type = SwiftCrashDefaultFormatter.self
    fileprivate static var _reporter: SwiftCrashReporter.Type = SwiftCrashConsoleReporter.self
    
    class func setFormatter(_ formatter: SwiftCrashFormatter.Type) {
        _formatter = formatter
    }
    
    class func setReporter(_ reporter: SwiftCrashReporter.Type) {
        _reporter = reporter
    }
    
     class func reportCrashWithContext(_ crashContext: MachExceptionContext) {
        _reporter.reportCrashMessage(_formatter.formatCrashMessage(crashContext))
    }
}

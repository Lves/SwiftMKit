//
//  SwiftCrashReporter.swift
//  SwiftCrashReport
//
//  Created by yingdong.guo on 16/7/14.
//  Copyright © 2016年 pintec.com. All rights reserved.
//

import Foundation

// protocol definition in swift is hard to export (module name is required)
//@objc protocol SwiftCrashFormatter {
//    static func formatCrashMessage(crashContext: MachExceptionContext) -> String
//}
//
//@objc protocol SwiftCrashReporter {
//    static func reportCrashMessage(message: String)
//}

class SwiftCrashReport {
    @available(*, deprecated, message="default exception handler report to console, please specify a custom reporter")
    class func install() {
        machExceptionHandlerInstall(handleSwiftCrash)
    }
    
    class func install(reporter: SwiftCrashReporter.Type) {
        SwiftCrashHandler.setReporter(reporter)
        machExceptionHandlerInstall(handleSwiftCrash)
    }
    
    class func install(formatter: SwiftCrashFormatter.Type, reporter: SwiftCrashReporter.Type) {
        SwiftCrashHandler.setFormatter(formatter)
        SwiftCrashHandler.setReporter(reporter)
        machExceptionHandlerInstall(handleSwiftCrash)
    }
    
    class func uninstall() {
        machExceptionHandlerUninstall()
    }
}

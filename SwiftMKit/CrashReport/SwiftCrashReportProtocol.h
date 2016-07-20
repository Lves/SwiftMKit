//
//  SwiftCrashReportProtocol.h
//  SwiftCrashReport
//
//  Created by yingdong.guo on 16/7/18.
//  Copyright © 2016年 pintec.com. All rights reserved.
//

#ifndef SwiftCrashReportProtocol_h
#define SwiftCrashReportProtocol_h

#include "MachExceptionHandler.h"
@class NSString;

@protocol SwiftCrashFormatter
+ (NSString * _Nonnull)formatCrashMessage:(MachExceptionContext)crashContext;
@end

@protocol SwiftCrashReporter
+ (void)reportCrashMessage:(NSString * _Nonnull)message;
@end

#endif /* SwiftCrashReportProtocol_h */

//
//  SwiftCrashUmengReporter.m
//  SwiftCrashReport
//
//  Created by yingdong.guo on 16/7/18.
//  Copyright © 2016年 All rights reserved.
//

#import "SwiftCrashUmengReporter.h"

@implementation SwiftCrashUmengReporter

/**
 *  Warning: This reporter use Umeng internal class.
 *  The original SDK does not provide API for reporting crash directly.
 *
 *  written in objc because swift does not support performSelector / NSInvocation
 *
 *  @param message crash report message
 */
+ (void)reportCrashMessage:(NSString *)message {
    Class umengReporterClass = NSClassFromString(@"MobClickInternal");
    if (!umengReporterClass) {
        NSLog(@"Umeng framework is not available");
        return;
    }
    
    NSMethodSignature *signature = [umengReporterClass methodSignatureForSelector:NSSelectorFromString(@"sharedInstance")];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation invokeWithTarget:umengReporterClass];
    
    id umengReporter;
    [invocation getReturnValue:&umengReporter];
    if (!umengReporter) {
        NSLog(@"Getting reporter failed");
        return;
    }
    
    signature = [umengReporter methodSignatureForSelector:NSSelectorFromString(@"error:")];
    invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setArgument:&message atIndex:2];
    [invocation invokeWithTarget:umengReporter];
}

@end

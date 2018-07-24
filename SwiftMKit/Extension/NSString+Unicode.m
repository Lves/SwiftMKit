//
//  NSString+Unicode.m
//  JimuDuMiao
//
//  Created by lixingle on 2018/7/24.
//  Copyright © 2018年 jm. All rights reserved.
//

#import "NSString+Unicode.h"

@implementation NSString (Unicode)
- (NSString *)mkStringByReplaceUnicode {
    NSMutableString *convertedString = [self mutableCopy];
    [convertedString replaceOccurrencesOfString:@"\\U"
                                     withString:@"\\u"
                                        options:0
                                          range:NSMakeRange(0, convertedString.length)];
    
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    return convertedString;
}

@end

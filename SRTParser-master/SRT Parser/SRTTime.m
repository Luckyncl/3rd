//
//  SRTTime.m
//  VideoPlayer
//
//  Created by Nick Steinhauer on 9/11/14.
//  Copyright (c) 2014 Nicolaos Steinhauer. All rights reserved.
//
//  Code is provided under GNU GENERAL PUBLIC LICENSE

#import "SRTTime.h"

@implementation SRTTime
{
    double _seconds;
}

- (instancetype)initWithSRTTime:(NSString *)time
{
    self = [super init];
    if (self) {
        self.time = time;
    }
    return self;
}

- (float)getTimeInSeconds
{
    _seconds += [self milliseconds];
    _seconds += [self seconds];
    _seconds += [self minutes];
    _seconds += [self hours];

    return _seconds;
}

- (float)milliseconds
{
    NSError *mRegExpError;
    NSRegularExpression *mRegExp = [NSRegularExpression
                                         regularExpressionWithPattern:@",\\d{3}"
                                         options:NSRegularExpressionCaseInsensitive
                                         error:&mRegExpError];
    NSRange millisecondsRange = [mRegExp
                              rangeOfFirstMatchInString:self.time
                              options:NSMatchingReportCompletion
                              range:NSMakeRange(0, self.time.length)];
    NSString *milliseconds = [self.time substringWithRange:millisecondsRange];
    milliseconds = [milliseconds stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    
    return [milliseconds floatValue] / 1000.0f;
}

- (int)seconds
{
    NSError *sRegExpError;
    NSRegularExpression *sRegExp = [NSRegularExpression
                                    regularExpressionWithPattern:@":\\d{2},"
                                    options:NSRegularExpressionCaseInsensitive
                                    error:&sRegExpError];
    NSRange secondsRange = [sRegExp
                                 rangeOfFirstMatchInString:self.time
                                 options:NSMatchingReportCompletion
                                 range:NSMakeRange(0, self.time.length)];
    NSString *seconds = [self.time substringWithRange:secondsRange];
    seconds = [seconds stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",:"]];
    
    return [seconds intValue];
}

- (int)minutes
{
    NSError *mRegExpError;
    NSRegularExpression *mRegExp = [NSRegularExpression
                                    regularExpressionWithPattern:@":\\d{2}:"
                                    options:NSRegularExpressionCaseInsensitive
                                    error:&mRegExpError];
    NSRange minutesRange = [mRegExp
                            rangeOfFirstMatchInString:self.time
                            options:NSMatchingReportCompletion
                            range:NSMakeRange(0, self.time.length)];
    NSString *minutes = [self.time substringWithRange:minutesRange];
    minutes = [minutes stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    
    return [minutes intValue] * 60;
}

- (int)hours
{
    NSError *hRegExpError;
    NSRegularExpression *hRegExp = [NSRegularExpression
                                    regularExpressionWithPattern:@"^\\d{2}:"
                                    options:NSRegularExpressionCaseInsensitive
                                    error:&hRegExpError];
    NSRange hoursRange = [hRegExp
                            rangeOfFirstMatchInString:self.time
                            options:NSMatchingReportCompletion
                            range:NSMakeRange(0, self.time.length)];
    NSString *hours = [self.time substringWithRange:hoursRange];
    hours = [hours stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    
    return [hours intValue] * 3600;
}

@end

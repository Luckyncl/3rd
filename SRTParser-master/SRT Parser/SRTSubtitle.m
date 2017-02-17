//
//  SRTSubtitle.m
//  VideoPlayer
//
//  Created by Nicolaos Steinhauer on 9/13/14.
//  Copyright (c) 2014 Nicolaos Steinhauer. All rights reserved.
//
//  SRTSubtitle is a helper Class for SRTParser that accepts the
//  subtitle set and returns a 4-cell array with the subtitle
//  parts, i.e. index, start and end times (in seconds) and text.
//
//  Code is provided under GNU GENERAL PUBLIC LICENSE

#import "SRTSubtitle.h"
#import "SRTTime.h"

@interface SRTSubtitle ()

@property (strong, nonatomic, readwrite) NSArray *subtitle;

@end

@implementation SRTSubtitle

- (instancetype)initWithString:(NSString *)subtitle
{
    self = [super init];
    if (self) {
        NSString *indexRegExpPattern = @"\\d+\\r\\n";
        NSString *startTimeRegExpPattern = @"\\d{2}:\\d{2}:\\d{2},\\d{3} -->";
        NSString *endTimeRegExpPattern = @"--> \\d{2}:\\d{2}:\\d{2},\\d{3}";
        NSString *textRegExpPattern = @"\n[^0-9][a-zA-z0-9\u4e00-\u9fa5\u0800-\u4e00\u9fa5,.\"?》!' ]+";
        
        NSRegularExpression *indexRegExp = [NSRegularExpression regularExpressionWithPattern:indexRegExpPattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSRegularExpression *startTimeRegExp = [NSRegularExpression regularExpressionWithPattern:startTimeRegExpPattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSRegularExpression *endTimeRegExp = [NSRegularExpression regularExpressionWithPattern:endTimeRegExpPattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSRegularExpression *textRegExp = [NSRegularExpression regularExpressionWithPattern:textRegExpPattern options:NSRegularExpressionCaseInsensitive error:nil];
        
        NSRange indexRange = [indexRegExp firstMatchInString:subtitle options:kNilOptions range:NSMakeRange(0, subtitle.length)].range;
        NSRange startTimeRange = [startTimeRegExp firstMatchInString:subtitle options:kNilOptions range:NSMakeRange(0, subtitle.length)].range;
        NSRange endTimeRange = [endTimeRegExp firstMatchInString:subtitle options:kNilOptions range:NSMakeRange(0, subtitle.length)].range;
        NSRange textRange = [textRegExp firstMatchInString:subtitle options:kNilOptions range:NSMakeRange(0, subtitle.length)].range;
        
        self.index = [subtitle substringWithRange:indexRange];
        self.index = [self.index stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
        NSString *startTime = [[subtitle substringWithRange:startTimeRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ->"]];
        self.startTime = [NSString stringWithFormat:@"%f",[[[SRTTime alloc] initWithSRTTime:startTime] getTimeInSeconds]];;
        NSString *endTime = [[subtitle substringWithRange:endTimeRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ->"]];;
        self.endTime = [NSString stringWithFormat:@"%f",[[[SRTTime alloc] initWithSRTTime:endTime] getTimeInSeconds]];
        self.text = [subtitle substringWithRange:textRange];
        self.text = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
        
        self.subtitle = [NSArray arrayWithObjects:self.index, self.startTime, self.endTime, self.text, nil];
    }
    return self;
}

@end

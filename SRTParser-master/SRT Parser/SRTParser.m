//
//  SRTParser.m
//  VideoPlayer
//
//  Created by Nick Steinhauer on 9/10/14.
//  Copyright (c) 2014 Nicolaos Steinhauer. All rights reserved.
//
//  Parsing is done by first going through each set of subtitle.
//  A subtitle set consists of an index (e.g. 1), the start and
//  end time and finally the text of the subtitle. Every set is
//  analyzed and the result is return in a subtitle array[4] consisting
//  of the subtitle index, the start and end times in seconds (float)
//  and of course the text string.
//
//  Code is provided under GNU GENERAL PUBLIC LICENSE

#import "SRTParser.h"
#import "SRTSubtitle.h"
#import "SRTTime.h"

@interface SRTParser ()

@end

@implementation SRTParser
{
    NSMutableArray *_srtArray;
    NSData *_srtData;
}

- (instancetype)initWithSRTFile:(NSString *)path
{
    self = [super init];
    if (self) {
        _srtData = [NSData dataWithContentsOfFile:path];
    }
    return self;
}

- (void)parse
{
    _srtArray = [NSMutableArray array];
    NSString *srtString = [[NSString alloc] initWithData:_srtData encoding:NSUTF8StringEncoding];
    
    NSError *regExpError;
//    [\u4e00-\u9fa5] 中文 \u0800-\u4e00 日文 韩文
    NSString *regExpPattern = @"\\d+\\r\\n\\d{2}:\\d{2}:\\d{2},\\d{3} --> \\d{2}:\\d{2}:\\d{2},\\d{3}\\r\\n[a-zA-z0-9\u4e00-\u9fa5\u0800-\u4e00\u9fa5,.?/》!@\'; :\"]+";
    NSRegularExpression *regExpSRT = [NSRegularExpression regularExpressionWithPattern:regExpPattern
                                                                               options:NSRegularExpressionCaseInsensitive error:&regExpError];
    //Each subtitle set is analyzed here with the aid of the SRTSubtitle helper Class
    [regExpSRT enumerateMatchesInString:srtString
                                options:kNilOptions range:NSMakeRange(0, srtString.length)
                             usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        SRTSubtitle *subtitle = [[SRTSubtitle alloc] initWithString:[srtString substringWithRange:result.range]];
//        NSLog(@"%@",subtitle.text);
                                 
        [_srtArray addObject:subtitle.subtitle];
//
             switch (flags) {
                 case NSMatchingProgress:
                 {
                     NSLog(@"---解析中---");
                 }
                     break;
                     
                 case NSMatchingCompleted:
                    NSLog(@"---完成中---");
                     break;
                 case NSMatchingHitEnd:
                     NSLog(@"---热点结束---");
                     break;

                 case NSMatchingRequiredEnd:
                     NSLog(@"---需要结束---");
                     break;

                 case NSMatchingInternalError:
                     NSLog(@"---发生错误---");
                     break;
                 default:
                     break;
             }
        if (stop) {
            [self.delegate parsingFinishedWithSubs:[_srtArray copy]];
        }
    }];
}

@end

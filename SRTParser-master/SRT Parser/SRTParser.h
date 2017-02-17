//
//  SRTParser.h
//  VideoPlayer
//
//  Created by Nick Steinhauer on 9/10/14.
//  Copyright (c) 2014 Nicolaos Steinhauer. All rights reserved.
//
//  Code is provided under GNU GENERAL PUBLIC LICENSE

#import <Foundation/Foundation.h>

@protocol SRTParserDelegate <NSObject>

- (void)parsingFinishedWithSubs:(NSArray *)subs;

@end

@interface SRTParser : NSObject

@property (weak, nonatomic) id <SRTParserDelegate> delegate;

- (instancetype)initWithSRTFile:(NSString *)path;
- (void)parse;

@end

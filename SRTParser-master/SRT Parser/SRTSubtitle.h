//
//  SRTSubtitle.h
//  VideoPlayer
//
//  Created by Nicolaos Steinhauer on 9/13/14.
//  Copyright (c) 2014 Nicolaos Steinhauer. All rights reserved.
//
//  Code is provided under GNU GENERAL PUBLIC LICENSE

#import <Foundation/Foundation.h>

@interface SRTSubtitle : NSObject

@property (strong, nonatomic, readonly) NSArray *subtitle;
@property (strong, nonatomic) NSString *index;
@property (strong, nonatomic) NSString *startTime;
@property (strong, nonatomic) NSString *endTime;
@property (strong, nonatomic) NSString *text;

- (instancetype)initWithString:(NSString *)subtitle;

@end

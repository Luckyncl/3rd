//
//  SRTTime.h
//  VideoPlayer
//
//  Created by Nick Steinhauer on 9/11/14.
//  Copyright (c) 2014 Nicolaos Steinhauer. All rights reserved.
//
//  Code is provided under GNU GENERAL PUBLIC LICENSE

#import <Foundation/Foundation.h>

@interface SRTTime : NSObject

@property (strong, nonatomic) NSString *time;

- (instancetype)initWithSRTTime:(NSString *)time;
- (float)getTimeInSeconds;

@end

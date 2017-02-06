//
//  AENewTimePitchFilter.h
//  The Amazing Audio Engine
//
//  Created by Jeremy Flores on 4/27/13.
//  Copyright (c) 2015 Dream Engine Interactive, Inc and A Tasty Pixel Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
        
    变声器
 
 */

#import "AEAudioUnitFilter.h"

@interface AENewTimePitchFilter : AEAudioUnitFilter

- (instancetype)init;

// range is from 1/32 to 32.0. Default is 1.0.
@property (nonatomic) double rate;                      // 频率 倍数

// range is from -2400 cents to 2400 cents. Default is 1.0 cents.
@property (nonatomic) double pitch;                     // 声调

// range is from 3.0 to 32.0. Default is 8.0.
@property (nonatomic) double overlap;

// value is either 0 or 1. Default is 1.
@property (nonatomic) double enablePeakLocking;          // 是否锁定 峰值

@end

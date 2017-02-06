//
//  AEDelayFilter.h
//  The Amazing Audio Engine
//
//  Created by Jeremy Flores on 4/25/13.
//  Copyright (c) 2015 Dream Engine Interactive, Inc and A Tasty Pixel Pty Ltd. All rights reserved.
//

/**

    延迟过滤器  ( 可以制作回声 )

 */
#import <Foundation/Foundation.h>

#import "AEAudioUnitFilter.h"

@interface AEDelayFilter : AEAudioUnitFilter

- (instancetype)init;

// range is from 0 to 100 (percentage). Default is 50.
@property (nonatomic) double wetDryMix;                     // 干湿混合

// range is from 0 to 2 seconds. Default is 1 second.
@property (nonatomic) double delayTime;                     // 延迟时间

// range is from -100 to 100. default is 50.
@property (nonatomic) double feedback;                      // 反馈

// range is from 10 to ($SAMPLERATE/2). Default is 15000.
@property (nonatomic) double lopassCutoff;                  // 低通截止

@end

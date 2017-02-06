//
//  AEReverbFilter.h
//  The Amazing Audio Engine
//
//  Created by Jeremy Flores on 4/25/13.
//  Copyright (c) 2015 Dream Engine Interactive, Inc and A Tasty Pixel Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEAudioUnitFilter.h"


#pragma mark: - 混响器

@interface AEReverbFilter : AEAudioUnitFilter

- (instancetype)init;

// range is from 0 to 100 (percentage). Default is 0.
@property (nonatomic) double dryWetMix;

// range is from -20dB to 20dB. Default is 0dB.
@property (nonatomic) double gain;                      //   分贝 增益

// range is from 0.0001 to 1.0 seconds. Default is 0.008 seconds.
@property (nonatomic) double minDelayTime;              //   最小的延迟时间

// range is from 0.0001 to 1.0 seconds. Default is 0.050 seconds.
@property (nonatomic) double maxDelayTime;              //   最大的延迟时间 

// range is from 0.001 to 20.0 seconds. Default is 1.0 seconds.
@property (nonatomic) double decayTimeAt0Hz;            //   在 0 Hz 时的衰减时间

// range is from 0.001 to 20.0 seconds. Default is 0.5 seconds.
@property (nonatomic) double decayTimeAtNyquist;        //   在最大hz的时候的衰减时间

// range is from 1 to 1000 (unitless). Default is 1.
@property (nonatomic) double randomizeReflections;      //   随机反射



@end

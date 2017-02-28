//
//  AEAudioController.h
//  TAAESample
//
//  Created by Michael Tyson on 24/03/2016.
//  Copyright © 2016 A Tasty Pixel. All rights reserved.
//
// Strictly for educational purposes only. No part of TAAESample is to be distributed
// in any form other than as source code within the TAAE2 repository.

#import <Foundation/Foundation.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>

extern NSString * _Nonnull const AEAudioControllerInputEnabledChangedNotification;
extern NSString * _Nonnull const AEAudioControllerInputPermissionErrorNotification;

@interface AEAudioController : NSObject


- (BOOL)start:(NSError * _Nullable * _Nullable)error;
- (void)stop;


// 开始录音
- (BOOL)beginRecordingAtTime:(AEHostTicks)time error:(NSError * _Nullable * _Nullable)error;
- (void)stopRecordingAtTime:(AEHostTicks)time completionBlock:(void(^ _Nullable)())block;


/*          播放录音相关      */
- (void)playRecordingWithCompletionBlock:(void(^ _Nullable)())block;
- (void)stopPlayingRecording;






@property (nonatomic, strong) AEAudioFilePlayerModule *sample1;

@property (nonatomic, readonly) BOOL recording;
@property (nonatomic, readonly) NSURL * _Nonnull recordingPath;
@property (nonatomic, readonly) BOOL playingRecording;
@property (nonatomic) double recordingPlaybackPosition;
@property (nonatomic) BOOL inputEnabled;




//      设置音效相关

/*       0 to 100       */
@property (nonatomic, assign)double reverbValue;    // 混响

/*         -2400 cents to 2400         */
@property (nonatomic, assign)double pitchValue;     // 变声

/*     0 to 2              */
@property (nonatomic, assign)double delayValue;     // 延迟

/*     1 to 1000   */
@property (nonatomic, assign)double reverbRoom;     // 空间

@end

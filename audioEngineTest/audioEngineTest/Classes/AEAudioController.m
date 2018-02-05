//
//  AEAudioController.m
//  TAAESample
//
//  Created by Michael Tyson on 24/03/2016.
//  Copyright © 2016 A Tasty Pixel. All rights reserved.
//
// Strictly for educational purposes only. No part of TAAESample is to be distributed
// in any form other than as source code within the TAAE2 repository.

#import "AEAudioController.h"
#import <AVFoundation/AVFoundation.h>

NSString * const AEAudioControllerInputEnabledChangedNotification = @"AEAudioControllerInputEnabledChangedNotification";
NSString * const AEAudioControllerInputPermissionErrorNotification = @"AEAudioControllerInputPermissionErrorNotification";

static const AESeconds kCountInThreshold = 0.2;
static const double kMicBandpassCenterFrequency = 2000.0;

@interface AEAudioController ()


@property (nonatomic, strong, readwrite) AEAudioUnitInputModule * input;
@property (nonatomic, strong, readwrite) AEAudioUnitOutput * output;

@property (nonatomic, strong) AEDelayModule *delay;             // 延迟模块
@property (nonatomic, strong) AEReverbModule *reverb;           // 混响
@property (nonatomic, strong) AENewTimePitchModule *pitch;        // 变声模块


@property (nonatomic, strong) AEMixerModule *mixer;

@property (nonatomic, readwrite) BOOL recording;
@property (nonatomic, readwrite) BOOL playingRecording;
@property (nonatomic, strong) AEManagedValue * recorderValue;
@property (nonatomic, strong) AEManagedValue * playerValue;
@property (nonatomic) BOOL playingThroughSpeaker;
@property (nonatomic, strong) id routeChangeObserverToken;
@property (nonatomic, strong) id audioInterruptionObserverToken;


@end

@implementation AEAudioController
@dynamic recordingPlaybackPosition;

#pragma mark - Life-cycle


- (instancetype)init {
    if ( !(self = [super init]) ) return nil;
    
    AERenderer * renderer = [AERenderer new];
    AERenderer * subrenderer = [AERenderer new];
    // 设置输出节点
    self.output = [[AEAudioUnitOutput alloc] initWithRenderer:renderer];
    
    // 设置输入节点
    AEAudioUnitInputModule * input = self.output.inputModule;
    self.input = input;
    
    
    NSURL *mp3url = [[NSBundle mainBundle] URLForResource:@"Recording" withExtension:@"m4a"];
    // Start player
    AEAudioFilePlayerModule * players =
    [[AEAudioFilePlayerModule alloc] initWithRenderer:self.output.renderer URL:mp3url error:NULL];
;
    self.sample1 = players;

    
    
    // ****************   设置音效模块    *********************
    /*      延迟模块        */
    AEDelayModule * micDelay = [[AEDelayModule alloc] initWithRenderer:renderer];
    micDelay.delayTime = 0.f;
    self.delay = micDelay;
    
    /*    混响       */
    AEReverbModule *micReverb = [[AEReverbModule alloc] initWithRenderer:renderer];
    self.reverb = micReverb;
    
  
    //混音
    AEMixerModule *mixer = [[AEMixerModule alloc] initWithRenderer:subrenderer];
    
    self.mixer = mixer;
    
//    self.mixer.modules = @[players];
    
    subrenderer.block = ^(const AERenderContext * _Nonnull context) {
        
        AEModuleProcess(mixer, context);
        AERenderContextOutput(context, 1);
    };

    
    AENewTimePitchModule *pitch = [[AENewTimePitchModule alloc] initWithRenderer:renderer subrenderer:subrenderer];
    pitch.enablePeakLocking = NO;
//    pitch.pitch = 1200;
    self.pitch = pitch;

    
    // Setup recorder placeholder
    AEManagedValue * recorderValue = [AEManagedValue new];
    self.recorderValue = recorderValue;
    
    // Setup recording player placeholder
    AEManagedValue * playerValue = [AEManagedValue new];
    self.playerValue = playerValue;
    
    
    // Setup top-level renderer. This is all performed on the audio thread, so the usual
    // rules apply: No holding locks, no memory allocation, no Objective-C/Swift code.
    __unsafe_unretained AEAudioController * THIS = self;
    renderer.block = ^(const AERenderContext * _Nonnull context) {
        
        // See if we have an active recorder
        __unsafe_unretained AEAudioFileRecorderModule * recorder
        = (__bridge AEAudioFileRecorderModule *)AEManagedValueGetValue(recorderValue);
        
        // See if we have an active player
        __unsafe_unretained AEAudioFilePlayerModule * player
        = (__bridge AEAudioFilePlayerModule *)AEManagedValueGetValue(playerValue);
        

        if ( player ) {
            // If we're playing a recording, duck other output
//            AEDSPApplyGain(AEBufferStackGet(context->stack, 0), 0.1, context->frames);
            AEModuleProcess(micDelay, context);
            AEModuleProcess(pitch, context);
            AEModuleProcess(micReverb, context);
            // Put on output
            AERenderContextOutput(context, 1);
        }
        
        AEModuleProcess(self.sample1, context);
        AERenderContextOutput(context, 1);
        
        if ( THIS->_inputEnabled ) {
            // Add audio input
            AEModuleProcess(input, context);
            
            // Add effects to input, and amplify by a factor of 2x to recover lost gain from bandpass

            // If it's safe to do so, put this on the output
//            if ( !THIS->_playingThroughSpeaker ) {
//                if ( player ) {
//                    // If we're playing a recording, duck first
//                    AEDSPApplyGain(AEBufferStackGet(context->stack, 0), 0.1, context->frames);
//                }
////                      这里是用于输出硬件的 暂时先注释了，以后再说吧
////                AERenderContextOutput(context, 1);
//            }
        }
        
        // Run through recorder, if it's there
        if ( recorder && !player ) {
            if ( THIS->_inputEnabled ) {
                // We have a buffer from input to mix in
                AEBufferStackMix(context->stack, 2);
            }
            // Run through recorder
            AEModuleProcess(recorder, context);
        }
        
        // Play recorded file, if playing
        if ( player ) {
            // Play
//            AEModuleProcess(player, context);
//
////            // Put on output
//            AERenderContextOutput(context, 1);
        }
    };
    return self;
}

- (void)dealloc {
    [self stop];
}

- (BOOL)start:(NSError *__autoreleasing *)error {
    return [self start:error registerObservers:YES];
}

#pragma mark: - 音效模块

- (BOOL)start:(NSError *__autoreleasing *)error registerObservers:(BOOL)registerObservers {
    
#if TARGET_OS_IPHONE
    
    // Request a 128 frame hardware duration, for minimal latency
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setPreferredIOBufferDuration:128.0/session.sampleRate error:NULL];
    
    // Start the session
    if ( ![self setAudioSessionCategory:error] || ![session setActive:YES error:error] ) {
        return NO;
    }
    
    // Work out if we're playing through the speaker (which affects whether we do input monitoring, to avoid feedback)
    [self updatePlayingThroughSpeaker];
    
    if ( registerObservers ) {
        // Watch for some important notifications
        [self registerObservers];
    }
    
#endif
    
    // Start the output and input
    return [self.output start:error] && (!self.inputEnabled || [self.input start:error]);
//    return YES;
    
}

- (void)stop {
    [self stopAndRemoveObservers:YES];
}

- (void)stopAndRemoveObservers:(BOOL)removeObservers {
    // Stop, and deactivate the audio session
    [self.output stop];
    [self.input stop];
    
#if TARGET_OS_IPHONE
    
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
    
    if ( removeObservers ) {
        // Remove our notification handlers
        [self unregisterObservers];
    }
    
#endif
    
}

#pragma mark - Recording

- (BOOL)beginRecordingAtTime:(AEHostTicks)time error:(NSError**)error {
    if ( self.recording ) return NO;
    
    // Create recorder
    AEAudioFileRecorderModule * recorder = [[AEAudioFileRecorderModule alloc] initWithRenderer:self.output.renderer
                                                                                           URL:self.recordingPath type:AEAudioFileTypeM4A error:error];
    if ( !recorder ) {
        return NO;
    }
    
    // Make recorder available to audio renderer
    self.recorderValue.objectValue = recorder;
    
    self.recording = YES;
    [recorder beginRecordingAtTime:time];
    
    return YES;
}

- (void)stopRecordingAtTime:(AEHostTicks)time completionBlock:(void(^)())block {
    if ( !self.recording ) return;
    
    // End recording
    AEAudioFileRecorderModule * recorder = self.recorderValue.objectValue;
    __weak AEAudioController * weakSelf = self;
    [recorder stopRecordingAtTime:time completionBlock:^{
        weakSelf.recording = NO;
        weakSelf.recorderValue.objectValue = nil;
        if ( block ) block();
    }];
}

- (void)playRecordingWithCompletionBlock:(void (^)())block {
    NSURL * url = self.recordingPath;
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:url.path] ) {
        
        NSURL *mp3url = [[NSBundle mainBundle] URLForResource:@"凤凰传奇 - 最炫民族风(Live)" withExtension:@"mp3"];
        // Start player
//        AEAudioFilePlayerModule * player =
//        [[AEAudioFilePlayerModule alloc] initWithRenderer:self.output.renderer URL:url error:NULL];
        
        AEAudioFilePlayerModule * player =
                [[AEAudioFilePlayerModule alloc] initWithRenderer:self.output.renderer URL:mp3url error:NULL];
        self.mixer.modules = @[player];
      
        
        
        if ( !player ) return;
        
        // Make player available to audio renderer
        self.playerValue.objectValue = player;
        __weak AEAudioController * weakSelf = self;
        player.completionBlock = ^{
            // Keep track of when playback ends
            [weakSelf stopPlayingRecording];
            if ( block ) block();
        };
        
        // Go
        self.playingRecording = YES;
        [player playAtTime:AETimeStampNone];
    }
}

- (void)stopPlayingRecording {
    self.playingRecording = NO;
    self.playerValue.objectValue = nil;
}

#pragma mark - Timing



#pragma mark - Accessors

- (void)setInputEnabled:(BOOL)inputEnabled {
    if ( inputEnabled == _inputEnabled ) return;
    
    _inputEnabled = inputEnabled;
    
#if TARGET_OS_IPHONE
    
    if ( _inputEnabled ) {
        // See if we have record permissions
        __weak AEAudioController * weakSelf = self;
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( granted ) {
                    // All set!
                } else {
                    // We haven't been granted record permission. Send out a notification and disable input.
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:AEAudioControllerInputPermissionErrorNotification object:self];
                    weakSelf.inputEnabled = NO;
                }
            });
        }];
    }
    
    // Update audio session category
    if ( ![self setAudioSessionCategory:nil] ) {
        return;
    }
    
#endif
    
    // Start or stop the input module
    if ( _inputEnabled ) {
        NSError * error;
        if ( ![self.input start:&error] ) {
            NSLog(@"Couldn't start input unit: %@", error.localizedDescription);
        }
    } else {
        [self.input stop];
    }
    
    // Tell observers our input enabled status has changed
    [[NSNotificationCenter defaultCenter] postNotificationName:AEAudioControllerInputEnabledChangedNotification object:self];
}


- (void)setReverbRoom:(double)reverbRoom
{
    self.reverb.randomizeReflections = reverbRoom;
}

- (void)setReverbValue:(double)reverbValue
{
    self.reverb.dryWetMix = reverbValue;
}

- (void)setDelayValue:(double)delayValue
{
    self.delay.delayTime = delayValue;
}


- (void)setPitchValue:(double)pitchValue
{
    self.pitch.pitch = pitchValue;
}



- (NSURL *)recordingPath {
    NSURL * docs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    return [docs URLByAppendingPathComponent:@"Recording.m4a"];
}

- (double)recordingPlaybackPosition {
    AEAudioFilePlayerModule * player = self.playerValue.objectValue;
    if ( !player ) return 0.0;
    
    return player.currentTime / player.duration;
}

- (void)setRecordingPlaybackPosition:(double)recordingPlaybackPosition {
    AEAudioFilePlayerModule * player = self.playerValue.objectValue;
    if ( !player ) return;
    
    player.currentTime = recordingPlaybackPosition * player.duration;
}

#pragma mark - Helpers

#if TARGET_OS_IPHONE

- (void)updatePlayingThroughSpeaker {
    AVAudioSession * session = [AVAudioSession sharedInstance];
    AVAudioSessionRouteDescription *currentRoute = session.currentRoute;
    self.playingThroughSpeaker =
    [currentRoute.outputs filteredArrayUsingPredicate:
     [NSPredicate predicateWithFormat:@"portType = %@", AVAudioSessionPortBuiltInSpeaker]].count > 0;
}

- (BOOL)setAudioSessionCategory:(NSError **)error {
    NSError * e;
    AVAudioSession * session = [AVAudioSession sharedInstance];
    if ( ![session setCategory:self.inputEnabled ? AVAudioSessionCategoryPlayAndRecord : AVAudioSessionCategoryPlayback
                   withOptions:(self.inputEnabled ? AVAudioSessionCategoryOptionDefaultToSpeaker : 0)
           | AVAudioSessionCategoryOptionMixWithOthers
                         error:&e] ) {
        NSLog(@"Couldn't set category: %@", e.localizedDescription);
        if ( error ) *error = e;
        return NO;
    }
    return YES;
}

- (void)registerObservers {
    AVAudioSession * session = [AVAudioSession sharedInstance];
    __weak AEAudioController * weakSelf = self;
    
    // Watch for route changes, so we can keep track of whether we're playing through the speaker
    self.routeChangeObserverToken =
    [[NSNotificationCenter defaultCenter] addObserverForName:AVAudioSessionRouteChangeNotification
                                                      object:session queue:NULL usingBlock:^(NSNotification * _Nonnull note) {
                                                          
                                                          // Determine if we're playing through the speaker now
                                                          [weakSelf updatePlayingThroughSpeaker];
                                                      }];
    
    // Watch for audio session interruptions. Test this by setting a timer
    self.audioInterruptionObserverToken =
    [[NSNotificationCenter defaultCenter] addObserverForName:AVAudioSessionInterruptionNotification
                                                      object:session queue:NULL usingBlock:^(NSNotification * _Nonnull note) {
                                                          
                                                          // Stop at the beginning of the interruption, resume after
                                                          if ( [note.userInfo[AVAudioSessionInterruptionTypeKey] intValue] == AVAudioSessionInterruptionTypeBegan ) {
                                                              [weakSelf stopAndRemoveObservers:NO];
                                                          } else {
                                                              NSError * error = nil;
                                                              if ( ![weakSelf start:&error registerObservers:NO] ) {
                                                                  NSLog(@"Couldn't restart after interruption: %@", error);
                                                              }
                                                          }
                                                      }];
}

- (void)unregisterObservers {
    if ( self.routeChangeObserverToken ) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.routeChangeObserverToken];
        self.routeChangeObserverToken = nil;
    }
    if( self.audioInterruptionObserverToken ) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.audioInterruptionObserverToken];
        self.audioInterruptionObserverToken = nil;
    }
}

#endif

@end

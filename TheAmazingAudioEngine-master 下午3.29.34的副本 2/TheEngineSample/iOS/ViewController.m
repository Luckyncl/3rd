//
//  ViewController.m
//  Audio Controller Test Suite
//
//  Created by Michael Tyson on 13/02/2012.
//  Copyright (c) 2012 A Tasty Pixel. All rights reserved.
//

/**
 *  回声 要大于 0.01s 就行
 */


#import "ViewController.h"
#import "TheAmazingAudioEngine.h"
#import "TPOscilloscopeLayer.h"
#import "AEPlaythroughChannel.h"
#import "AEExpanderFilter.h"
#import "AERecorder.h"
#import "AEReverbFilter.h"
#import <QuartzCore/QuartzCore.h>
#import "AEBlockFilter.h"

#import "AENewTimePitchFilter.h" // 变音处理


#import "AEMemoryBufferPlayer.h"
static const int kInputChannelsChangedContext;

@interface ViewController () {
    AudioFileID _audioUnitFile;
    AEChannelGroupRef _group;
}
@property (nonatomic, strong) AEMemoryBufferPlayer *loop1;
@property (nonatomic, strong) AEAudioFilePlayer *loop2;
@property (nonatomic, strong) AEBlockChannel *oscillator;   // block
@property (nonatomic, strong) AEAudioUnitChannel *audioUnitPlayer;
@property (nonatomic, strong) AEAudioFilePlayer *oneshot;
@property (nonatomic, strong) AEReverbFilter *reverb;
@property (nonatomic, strong) AERecorder *recorder;
@property (nonatomic, strong) AEAudioFilePlayer *player;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *oneshotButton;
@property (nonatomic, strong) UIButton *oneshotAudioUnitButton;

@property (nonatomic, strong) AENewTimePitchFilter *pitch;  // 变音类
@end

@implementation ViewController

- (id)initWithAudioController:(AEAudioController*)audioController {
    if ( !(self = [super initWithStyle:UITableViewStyleGrouped]) ) return nil;
    
    self.audioController = audioController;
    
    return self;
}


// 重写setter方法
- (void)setAudioController:(AEAudioController *)audioController {
    if ( _audioController ) {
        [_audioController removeObserver:self forKeyPath:@"numberOfInputChannels"];
        
        NSMutableArray *channelsToRemove = [NSMutableArray arrayWithObjects:_loop1, _loop2, _oscillator, _audioUnitPlayer, nil];
        
        self.loop1 = nil;
        self.loop2 = nil;
        self.oscillator = nil;
        self.audioUnitPlayer = nil;
        
        if ( _player ) {
            [channelsToRemove addObject:_player];
            self.player = nil;
        }
        
        if ( _oneshot ) {
            [channelsToRemove addObject:_oneshot];
            self.oneshot = nil;
        }
 
        [_audioController removeChannels:channelsToRemove];
        
    
        if ( _reverb ) {
            [_audioController removeFilter:_reverb];
            self.reverb = nil;
        }
        if (_pitch) {
            [_audioController removeFilter:_pitch];
            self.pitch = nil;

        }
        
        [_audioController removeChannelGroup:_group];
        _group = NULL;
        
        if ( _audioUnitFile ) {
            AudioFileClose(_audioUnitFile);
            _audioUnitFile = NULL;
        }
    }
    
    _audioController = audioController;
    

    if ( _audioController ) {
        // Create the first loop player
     [AEMemoryBufferPlayer beginLoadingAudioFileAtURL:[[NSBundle mainBundle] URLForResource:@"男声" withExtension:@"mp3"] audioDescription:_audioController.audioDescription completionBlock:^(AEMemoryBufferPlayer *play, NSError *error) {
         _loop1 = play;
         [_loop1 playAtTime:0];
//         _loop1.loop = YES;
//         [_audioController addChannels:@[_loop1] ];
         
        }];
        
  
//        _loop1.volume = 1.0;
//        
//        _loop1.channelIsMuted = YES;
//        _loop1.loop = YES;
//        
        
        // Create the second loop player
        self.loop2 = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:@"Southern Rock Organ" withExtension:@"m4a"] error:NULL];
        _loop2.volume = 1.0;
        _loop2.channelIsMuted = YES;
        _loop2.loop = YES;
        
        // Create a block-based channel, with an implementation of an oscillator
        __block float oscillatorPosition = 0;
        __block float oscillatorRate = 622.0/44100.0;
        self.oscillator = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp  *time,
                                                             UInt32           frames,
                                                             AudioBufferList *audio) {
            for ( int i=0; i<frames; i++ ) {
                // Quick sin-esque oscillator
                float x = oscillatorPosition;
                x *= x; x -= 1.0; x *= x;       // x now in the range 0...1
                x *= INT16_MAX;
                x -= INT16_MAX / 2;
                oscillatorPosition += oscillatorRate;
                if ( oscillatorPosition > 1.0 ) oscillatorPosition -= 2.0;
                
                ((SInt16*)audio->mBuffers[0].mData)[i] = x;
                ((SInt16*)audio->mBuffers[1].mData)[i] = x;
            }
        }];
        _oscillator.audioDescription = AEAudioStreamBasicDescriptionNonInterleaved16BitStereo;
        _oscillator.channelIsMuted = YES;
        
        // Create an audio unit channel (a file player)
        self.audioUnitPlayer = [[AEAudioUnitChannel alloc] initWithComponentDescription:AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer)];
        
        // Create a group for loop1, loop2 and oscillator
        _group = [_audioController createChannelGroup];
        [_audioController addChannels:@[ _loop2, _oscillator] toChannelGroup:_group];
        
        // Finally, add the audio unit player
        [_audioController addChannels:@[_audioUnitPlayer]];
        
        [_audioController addObserver:self forKeyPath:@"numberOfInputChannels" options:0 context:(void*)&kInputChannelsChangedContext];
    }
}

-(void)dealloc {
    self.audioController = nil;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 80)];
    self.recordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [_recordButton setTitle:@"Stop" forState:UIControlStateSelected];
    [_recordButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    _recordButton.frame = CGRectMake(20, 10, ((footerView.bounds.size.width-50) / 2), footerView.bounds.size.height - 20);
    _recordButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    self.playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    [_playButton setTitle:@"Stop" forState:UIControlStateSelected];
    [_playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    _playButton.frame = CGRectMake(CGRectGetMaxX(_recordButton.frame)+10, 10, ((footerView.bounds.size.width-50) / 2), footerView.bounds.size.height - 20);
    _playButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [footerView addSubview:_recordButton];
    [footerView addSubview:_playButton];
    self.tableView.tableFooterView = footerView;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

-(void)viewDidLayoutSubviews {
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch ( section ) {
        case 0:
            return 4;
            
        case 1:
            return 2;
            
        case 2:
            return 2;
        default:
            return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch ( indexPath.section ) {
        case 0: {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
            
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectZero];
            slider.translatesAutoresizingMaskIntoConstraints = NO;
            slider.maximumValue = 1.0;
            slider.minimumValue = 0.0;
            
            UISwitch * onSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            onSwitch.translatesAutoresizingMaskIntoConstraints = NO;
//            onSwitch.on = _expander != nil;
            [view addSubview:slider];
            [view addSubview:onSwitch];
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[slider]-20-[onSwitch]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(slider, onSwitch)]];
            [view addConstraint:[NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
            [view addConstraint:[NSLayoutConstraint constraintWithItem:onSwitch attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
            
            cell.accessoryView = view;
            
            switch ( indexPath.row ) {
                case 0: {
                    cell.textLabel.text = @"Drums";
                    onSwitch.on = !_loop1.channelIsMuted;
                    slider.value = _loop1.volume;
                    [onSwitch addTarget:self action:@selector(loop1SwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    [slider addTarget:self action:@selector(loop1VolumeChanged:) forControlEvents:UIControlEventValueChanged];
                    break;
                }
                case 1: {
                    cell.textLabel.text = @"Organ";
                    onSwitch.on = !_loop2.channelIsMuted;
                    slider.value = _loop2.volume;
                    [onSwitch addTarget:self action:@selector(loop2SwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    [slider addTarget:self action:@selector(loop2VolumeChanged:) forControlEvents:UIControlEventValueChanged];
                    break;
                }
                case 2: {
                    cell.textLabel.text = @"Oscillator";
                    onSwitch.on = !_oscillator.channelIsMuted;
                    slider.value = _oscillator.volume;
                    [onSwitch addTarget:self action:@selector(oscillatorSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    [slider addTarget:self action:@selector(oscillatorVolumeChanged:) forControlEvents:UIControlEventValueChanged];
                    break;
                }
                case 3: {
                    cell.textLabel.text = @"Group";
                    onSwitch.on = ![_audioController channelGroupIsMuted:_group];
                    slider.value = [_audioController volumeForChannelGroup:_group];
                    [onSwitch addTarget:self action:@selector(channelGroupSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    [slider addTarget:self action:@selector(channelGroupVolumeChanged:) forControlEvents:UIControlEventValueChanged];
                    break;
                }
            }
            break;
        } 
        case 1: {
            switch ( indexPath.row ) {
                case 0: {
                    cell.accessoryView = self.oneshotButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [_oneshotButton setTitle:@"Play" forState:UIControlStateNormal];
                    [_oneshotButton setTitle:@"Stop" forState:UIControlStateSelected];
                    [_oneshotButton sizeToFit];
                    [_oneshotButton setSelected:_oneshot != nil];
                    [_oneshotButton addTarget:self action:@selector(oneshotPlayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                    cell.textLabel.text = @"One Shot";
                    break;
                }
                case 1: {
                    cell.accessoryView = self.oneshotAudioUnitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [_oneshotAudioUnitButton setTitle:@"Play" forState:UIControlStateNormal];
                    [_oneshotAudioUnitButton setTitle:@"Stop" forState:UIControlStateSelected];
                    [_oneshotAudioUnitButton sizeToFit];
                    [_oneshotAudioUnitButton setSelected:_oneshot != nil];
                    [_oneshotAudioUnitButton addTarget:self action:@selector(oneshotAudioUnitPlayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                    cell.textLabel.text = @"One Shot (Audio Unit)";
                    break;
                }
            }
            break;
        }
        case 2: {
            cell.accessoryView = [[UISwitch alloc] initWithFrame:CGRectZero];
            
            switch ( indexPath.row ) {
                case 0: {
                    cell.textLabel.text = @"Reverb";
                    ((UISwitch*)cell.accessoryView).on = _reverb != nil;
                    [((UISwitch*)cell.accessoryView) addTarget:self action:@selector(reverbSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    break;
                }
                case 1 :
                    {     UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
                    
                    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectZero];
                    slider.translatesAutoresizingMaskIntoConstraints = NO;
                    slider.maximumValue = 1000;
                    slider.minimumValue = -1000;
//                    -2400 cents to 2400
                    UISwitch * onSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                    onSwitch.translatesAutoresizingMaskIntoConstraints = NO;
                    [view addSubview:slider];
                    [view addSubview:onSwitch];
                    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[slider]-20-[onSwitch]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(slider, onSwitch)]];
                    [view addConstraint:[NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
                    [view addConstraint:[NSLayoutConstraint constraintWithItem:onSwitch attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
                    
                    cell.accessoryView = view;
                    
                            cell.textLabel.text = @"pitch 变调";
                     
                            [onSwitch addTarget:self action:@selector(pitchSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                            [slider addTarget:self action:@selector(pitchVolumeChanged:) forControlEvents:UIControlEventValueChanged];
                               break;
                    }

     
            }
                    break;
        }
    }
    
    return cell;
}

- (void)loop1SwitchChanged:(UISwitch*)sender {
    _loop1.channelIsMuted = !sender.isOn;
}

- (void)loop1VolumeChanged:(UISlider*)sender {
    _loop1.volume = sender.value;
}

- (void)loop2SwitchChanged:(UISwitch*)sender {
    _loop2.channelIsMuted = !sender.isOn;
}

- (void)loop2VolumeChanged:(UISlider*)sender {
    _loop2.volume = sender.value;
}

- (void)channelGroupSwitchChanged:(UISwitch*)sender {
    [_audioController setMuted:!sender.isOn forChannelGroup:_group];
}

- (void)channelGroupVolumeChanged:(UISlider*)sender {
    [_audioController setVolume:sender.value forChannelGroup:_group];
}

- (void)oneshotPlayButtonPressed:(UIButton*)sender {
    if ( _oneshot ) {
        [_audioController removeChannels:@[_oneshot]];
        self.oneshot = nil;
        _oneshotButton.selected = NO;
    } else {
        self.oneshot = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:@"Organ Run" withExtension:@"m4a"] error:NULL];
        _oneshot.removeUponFinish = YES;
        __weak ViewController *weakSelf = self;
        _oneshot.completionBlock = ^{
            ViewController *strongSelf = weakSelf;
            strongSelf.oneshot = nil;
            strongSelf->_oneshotButton.selected = NO;
        };
        [_audioController addChannels:@[_oneshot]];
        _oneshotButton.selected = YES;
    }
}

- (void)oneshotAudioUnitPlayButtonPressed:(UIButton*)sender {
    if ( !_audioUnitFile ) {
        NSURL *playerFile = [[NSBundle mainBundle] URLForResource:@"Organ Run" withExtension:@"m4a"];
        AECheckOSStatus(AudioFileOpenURL((__bridge CFURLRef)playerFile, kAudioFileReadPermission, 0, &_audioUnitFile), "AudioFileOpenURL");
    }
    
    // Set the file to play
    AECheckOSStatus(AudioUnitSetProperty(_audioUnitPlayer.audioUnit, kAudioUnitProperty_ScheduledFileIDs, kAudioUnitScope_Global, 0, &_audioUnitFile, sizeof(_audioUnitFile)),
                "AudioUnitSetProperty(kAudioUnitProperty_ScheduledFileIDs)");

    // Determine file properties
    UInt64 packetCount;
	UInt32 size = sizeof(packetCount);
	AECheckOSStatus(AudioFileGetProperty(_audioUnitFile, kAudioFilePropertyAudioDataPacketCount, &size, &packetCount),
                "AudioFileGetProperty(kAudioFilePropertyAudioDataPacketCount)");
	
	AudioStreamBasicDescription dataFormat;
	size = sizeof(dataFormat);
	AECheckOSStatus(AudioFileGetProperty(_audioUnitFile, kAudioFilePropertyDataFormat, &size, &dataFormat),
                "AudioFileGetProperty(kAudioFilePropertyDataFormat)");
    
	// Assign the region to play
	ScheduledAudioFileRegion region;
	memset (&region.mTimeStamp, 0, sizeof(region.mTimeStamp));
	region.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
	region.mTimeStamp.mSampleTime = 0;
	region.mCompletionProc = NULL;
	region.mCompletionProcUserData = NULL;
	region.mAudioFile = _audioUnitFile;
	region.mLoopCount = 0;
	region.mStartFrame = 0;
	region.mFramesToPlay = (UInt32)packetCount * dataFormat.mFramesPerPacket;
	AECheckOSStatus(AudioUnitSetProperty(_audioUnitPlayer.audioUnit, kAudioUnitProperty_ScheduledFileRegion, kAudioUnitScope_Global, 0, &region, sizeof(region)),
                "AudioUnitSetProperty(kAudioUnitProperty_ScheduledFileRegion)");
	
	// Prime the player by reading some frames from disk
	UInt32 defaultNumberOfFrames = 0;
	AECheckOSStatus(AudioUnitSetProperty(_audioUnitPlayer.audioUnit, kAudioUnitProperty_ScheduledFilePrime, kAudioUnitScope_Global, 0, &defaultNumberOfFrames, sizeof(defaultNumberOfFrames)),
                "AudioUnitSetProperty(kAudioUnitProperty_ScheduledFilePrime)");
    
    // Set the start time (now = -1)
    AudioTimeStamp startTime;
	memset (&startTime, 0, sizeof(startTime));
	startTime.mFlags = kAudioTimeStampSampleTimeValid;
	startTime.mSampleTime = -1;
	AECheckOSStatus(AudioUnitSetProperty(_audioUnitPlayer.audioUnit, kAudioUnitProperty_ScheduleStartTimeStamp, kAudioUnitScope_Global, 0, &startTime, sizeof(startTime)),
			   "AudioUnitSetProperty(kAudioUnitProperty_ScheduleStartTimeStamp)");

}



- (void)measurementModeSwitchChanged:(UISwitch*)sender {
    _audioController.useMeasurementMode = sender.on;
}

- (void)sampleRateSwitchChanged:(UISwitch*)sender {
    AudioStreamBasicDescription audioDescription = _audioController.audioDescription;
    audioDescription.mSampleRate = sender.on ? 48000 : 44100;
    NSError * error;
    if ( ![_audioController setAudioDescription:audioDescription error:&error] ) {
        [[[UIAlertView alloc] initWithTitle:@"Sample rate change failed"
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
    }
}

-(void)inputGainSliderChanged:(UISlider*)slider {
    _audioController.inputGain = slider.value;
}






#warning  增强器 这里都是采用默认属性

- (void)reverbSwitchChanged:(UISwitch*)sender {
    if ( sender.isOn ) {
        self.reverb = [[AEReverbFilter alloc] init];
        _reverb.dryWetMix = 100;
    
        
//        // range is from 0.0001 to 1.0 seconds. Default is 0.008 seconds.
//        @property (nonatomic) double minDelayTime;              //   最小的延迟时间
//        
//        // range is from 0.0001 to 1.0 seconds. Default is 0.050 seconds.
//        @property (nonatomic) double maxDelayTime;              //   最大的延迟时间
//        
//        // range is from 0.001 to 20.0 seconds. Default is 1.0 seconds.
//        @property (nonatomic) double decayTimeAt0Hz;            //   在 0 Hz 时的衰减时间
//        
//        // range is from 0.001 to 20.0 seconds. Default is 0.5 seconds.
//        @property (nonatomic) double decayTimeAtNyquist;        //   在最大hz的时候的衰减时间
//        
//        // range is from 1 to 1000 (unitless). Default is 1.
//        @property (nonatomic) double randomizeReflections;      //   随机反射
//        _reverb.maxDelayTime = 1;
//        _reverb.minDelayTime = 1;
        _reverb.decayTimeAt0Hz = 5;
        _reverb.decayTimeAtNyquist = 1;
//        [_reverb setGain:20];
//        _reverb.randomizeReflections = 1000;
        
        
        
        [_audioController addFilter:_reverb];
        self.recorder = [[AERecorder alloc] initWithAudioController:_audioController];
        NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [documentsFolders[0] stringByAppendingPathComponent:@"RecordingTest.m4a"];
        NSError *error = nil;
        if ( ![_recorder beginRecordingToFileAtPath:path fileType:kAudioFileM4AType error:&error] ) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:[NSString stringWithFormat:@"Couldn't start recording: %@", [error localizedDescription]]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
            self.recorder = nil;
            return;
        }
    
        [_audioController addOutputReceiver:_recorder];
    
    } else {
        [_audioController removeFilter:_reverb];
        self.reverb = nil;
        [_recorder finishRecording];
        [_audioController removeOutputReceiver:_recorder];
        self.recorder = nil;

    }
}





- (void) pitchSwitchChanged:(UISwitch *)sender
{
    if (sender.isOn) {
        self.pitch = [[AENewTimePitchFilter alloc] init];
        [_audioController addFilter:self.pitch];
        
//        self.recorder = [[AERecorder alloc] initWithAudioController:_audioController];
//        NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *path = [documentsFolders[0] stringByAppendingPathComponent:@"RecordingTest.m4a"];
//        NSError *error = nil;
//        if ( ![_recorder beginRecordingToFileAtPath:path fileType:kAudioFileM4AType error:&error] ) {
//            [[[UIAlertView alloc] initWithTitle:@"Error"
//                                        message:[NSString stringWithFormat:@"Couldn't start recording: %@", [error localizedDescription]]
//                                       delegate:nil
//                              cancelButtonTitle:nil
//                              otherButtonTitles:@"OK", nil] show];
//            self.recorder = nil;
//            return;
//        }
        
//        [_audioController addOutputReceiver:_recorder];
     

        
    }else{
             [_audioController removeFilter:_pitch];
            self.pitch = nil;

//
//            [_recorder finishRecording];
//            [_audioController removeOutputReceiver:_recorder];
//            self.recorder = nil;

    }
}

- (void)pitchVolumeChanged:(UISlider *)slider
{
    if (self.pitch) {
        self.pitch.pitch = slider.value;
    }
}

- (void)channelButtonPressed:(UIButton*)sender {
    BOOL selected = [_audioController.inputChannelSelection containsObject:@(sender.tag)];
    selected = !selected;
    if ( selected ) {
        _audioController.inputChannelSelection = [[_audioController.inputChannelSelection arrayByAddingObject:@(sender.tag)] sortedArrayUsingSelector:@selector(compare:)];
        [self performSelector:@selector(highlightButtonDelayed:) withObject:sender afterDelay:0.01];
    } else {
        NSMutableArray *channels = [_audioController.inputChannelSelection mutableCopy];
        [channels removeObject:@(sender.tag)];
        _audioController.inputChannelSelection = channels;
        sender.highlighted = NO;
    }
}

- (void)highlightButtonDelayed:(UIButton*)button {
    button.highlighted = YES;
}

- (void)record:(id)sender {
    if ( _recorder ) {
        [_recorder finishRecording];
        [_audioController removeOutputReceiver:_recorder];
        [_audioController removeInputReceiver:_recorder];
        self.recorder = nil;
        _recordButton.selected = NO;
    } else {
        self.recorder = [[AERecorder alloc] initWithAudioController:_audioController];
        NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [documentsFolders[0] stringByAppendingPathComponent:@"RecordingTest.m4a"];
        NSError *error = nil;
        
//         编码处理
//        passing in the path to the file you'd like to record to, and the file type to use. Common file types include
//        `kAudioFileAIFFType`, `kAudioFileWAVEType`, `kAudioFileM4AType` (using AAC audio encoding), and `kAudioFileCAFType`.

        
        if ( ![_recorder beginRecordingToFileAtPath:path fileType:kAudioFileM4AType error:&error] ) {
            [[[UIAlertView alloc] initWithTitle:@"Error" 
                                         message:[NSString stringWithFormat:@"Couldn't start recording: %@", [error localizedDescription]]
                                        delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:@"OK", nil] show];
            self.recorder = nil;
            return;
        }
        
        _recordButton.selected = YES;
//
//          添加系统播放器的音频
        [_audioController addOutputReceiver:_recorder];
        
        //   添加外部输入源的音频文件
        [_audioController addInputReceiver:_recorder];
        
           }
}

- (void)play:(id)sender {
    if ( _player ) {
        [_audioController removeChannels:@[_player]];
        self.player = nil;
        _playButton.selected = NO;
    } else {
        NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [documentsFolders[0] stringByAppendingPathComponent:@"RecordingTest.m4a"];
        
        if ( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) return;
        
        NSError *error = nil;
        self.player = [AEAudioFilePlayer audioFilePlayerWithURL:[NSURL fileURLWithPath:path] error:&error];
        
        if ( !_player ) {
            [[[UIAlertView alloc] initWithTitle:@"Error" 
                                         message:[NSString stringWithFormat:@"Couldn't start playback: %@", [error localizedDescription]]
                                        delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:@"OK", nil] show];
            return;
        }
        
        _player.removeUponFinish = YES;
        __weak ViewController *weakSelf = self;
        _player.completionBlock = ^{
            ViewController *strongSelf = weakSelf;
            strongSelf->_playButton.selected = NO;
            weakSelf.player = nil;
        };
        [_audioController addChannels:@[_player]];
        
        _playButton.selected = YES;
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ( context == &kInputChannelsChangedContext ) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end

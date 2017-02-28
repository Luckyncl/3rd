//
//  ViewController.m
//  audioEngineTest
//
//  Created by luckyncl on 17/2/13.
//  Copyright © 2017年 luckyncl. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) AEAudioFilePlayerModule *player;

@property (weak, nonatomic) IBOutlet UISlider *reverbSlider;

@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;

@property (weak, nonatomic) IBOutlet UISlider *delaySlider;
@property (weak, nonatomic) IBOutlet UISlider *roomSlider;

@end

@implementation ViewController
static const NSTimeInterval kTestFileLength = 4;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.audio = [[AEAudioController alloc] init];
    
    [self.audio start:nil];
    self.view.backgroundColor = [UIColor redColor];
    
    
    self.reverbSlider.maximumValue = 100;
    self.reverbSlider.minimumValue = 0;
    
    self.pitchSlider.minimumValue = -2400;
    self.pitchSlider.maximumValue = 2400;
    
    self.delaySlider.minimumValue = 0;
    self.delaySlider.maximumValue = 2;
    
    self.roomSlider.minimumValue = 1;
    self.roomSlider.maximumValue = 1000;
}



- (IBAction)record:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
       [self.audio setInputEnabled:YES];
        [self.audio beginRecordingAtTime: 0 error:nil];
    }else{
        [self.audio stopRecordingAtTime:0 completionBlock:^{
            NSLog(@"-=-=--=---=-停止录音-==-=-=-==--=-=-==-=-=-==-=-=--==--==-=-==----=-=-");
        }];
        [self.audio setInputEnabled:NO];
    }
}


- (IBAction)play:(UIButton *)sender {
    

    sender.selected = !sender.selected;
    if (sender.selected) {
        
//        [self.audio.sample1 playAtTime:AETimeStampNone];
        [self.audio playRecordingWithCompletionBlock:^{
//            NSLog(@"播放录音文件结束");
            sender.selected = NO;
        }];
    }else{
        [self.audio stopPlayingRecording];
//        [self.audio.sample1 stop];
    }
}

- (IBAction)reverb:(UISlider *)sender {
    [self.audio setReverbValue:sender.value];
}

- (IBAction)pitch:(UISlider *)sender {
    [self.audio setPitchValue:sender.value];
}

- (IBAction)delay:(UISlider *)sender {
    [self.audio setDelayValue:sender.value];
}

- (IBAction)room:(UISlider *)sender {
    [self.audio setReverbRoom:sender.value];
}

- (IBAction)export:(UIButton *)sender {
}

- (IBAction)playExport:(UIButton *)sender {
    
    [self createTestFile];
}




- (NSURL *)fileURL {
    
    return  [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"sample1.m4a"]];
//    return [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"AEAudioFileReaderTests.aiff"]];
}

- (NSError *)createTestFile {
    AERenderer * renderer = [AERenderer new];
    
    __block NSError * error = nil;
    
    

//    player setParameterValue:<#(double)#> forId:(AudioUnitParameterID)
    AEAudioFileOutput * output = [[AEAudioFileOutput alloc] initWithRenderer:self.audio.sample1.renderer URL:self.fileURL type:AEAudioFileTypeM4A sampleRate:44100.0 channelCount:2 error:&error];
    
    [self.audio.sample1 playAtTime:AETimeStampNone];
    if ( !output ) {
        return error;
    }

    
    __block BOOL done = NO;
    [output runForDuration:40 completionBlock:^(NSError * e){
        done = YES;
//        [self.audio.piano stop];
        NSLog(@" 已经完成了");
        error = e;
    }];
    
    while ( !done ) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    [output finishWriting];

    
    return error;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

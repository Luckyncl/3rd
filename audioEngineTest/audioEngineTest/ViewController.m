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

@end

@implementation ViewController
static const NSTimeInterval kTestFileLength = 4;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.audio = [[AEAudioController alloc] init];
    
    [self.audio start:nil];
    self.view.backgroundColor = [UIColor redColor];
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
        [self.audio playRecordingWithCompletionBlock:^{
            NSLog(@"播放完成");
        }];
    }else{
//        [self.audio playRecordingWithCompletionBlock:^{
//            NSLog(@"停止播放");
//        }];
        [self.audio stopPlayingRecording];
    }
}












- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    

//    [self.audio.sample1 playAtTime:AETimeStampNone beginBlock:^{
//        NSLog(@"     开始播放了     ");
//    }];
////
//    [self createTestFile];
    
    
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
//    AEMixerModule * mixer = [[AEMixerModule alloc] initWithRenderer:renderer];
//    
//
//    AEDelayModule * micDelay = [[AEDelayModule alloc] initWithRenderer:renderer];
//    micDelay.delayTime = 0.5;
//    renderer.block = ^(const AERenderContext * context) {
//        AEModuleProcess(micDelay, context);
////        AEModuleProcess(mixer, context);
//        AERenderContextOutput(context, 1);
//    };
//
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

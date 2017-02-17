//
//  ViewController.m
//  SRT Parser
//
//  Created by Nicolaos Steinhauer on 9/16/14.
//  Copyright (c) 2014 Nicolaos Steinhauer. All rights reserved.
//

#import "ViewController.h"
#import "SRTSubtitle.h"
@interface ViewController ()

@end

@implementation ViewController
{
    SRTParser *_srtParser;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *srtPath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"srt"];
    SRTParser *srt = [[SRTParser alloc] initWithSRTFile:srtPath];
    srt.delegate = self;
    [srt parse];
}

- (void)parsingFinishedWithSubs:(NSArray *)subs
{
    SRTSubtitle *srt = [subs firstObject];
    NSLog(@"%@",srt.text);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

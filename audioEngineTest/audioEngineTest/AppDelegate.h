//
//  AppDelegate.h
//  audioEngineTest
//
//  Created by luckyncl on 17/2/13.
//  Copyright © 2017年 luckyncl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AEAudioController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) AEAudioController *audio;

@end


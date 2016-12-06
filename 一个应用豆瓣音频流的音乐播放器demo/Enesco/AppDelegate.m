//
//  AppDelegate.m
//  Enesco
//
//  Created by Aufree on 11/30/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//

#import "AppDelegate.h"

//   音乐列表player
#import "MusicListViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MusicViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) MusicListViewController *musicListVC;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Showing the App
    [self makeWindowVisible:launchOptions];
    
    // Basic setup
    [self basicSetup];
    
    return YES;
}

- (void)makeWindowVisible:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 设置导航栏 的颜色
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    if (!_musicListVC){
        _musicListVC = [[UIStoryboard storyboardWithName:@"MusicList" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    }
    self.window.rootViewController = _musicListVC;
    
    [self.window makeKeyAndVisible];
}


- (void)basicSetup {
    // Remote control
    
    // 开始接受推送的通知 称为第一响应者
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

# pragma mark - Remote control


//在iOS中事件分为三类：
//
//触摸事件：通过触摸、手势进行触发（例如手指点击、缩放）
//运动事件：通过加速器进行触发（例如手机晃动）
//远程控制事件：通过其他远程设备触发（例如耳机控制按钮）

// 设置远程控制时间
// http://www.cnblogs.com/kenshincui/p/3950646.html
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPause:
                [[MusicViewController sharedInstance].streamer pause];
                break;
            case UIEventSubtypeRemoteControlStop:
                break;
            case UIEventSubtypeRemoteControlPlay:
                [[MusicViewController sharedInstance].streamer play];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [[MusicViewController sharedInstance] playNextMusic:nil];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [[MusicViewController sharedInstance] playPreviousMusic:nil];
                break;
            default:
                break;
        }
    }
}


@end

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
//#import <MediaPlayer/MediaPlayer.h>
#import "MusicViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) MusicListViewController *musicListVC;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Showing the App
    [self makeWindowVisible:launchOptions];
    
    
//    //设置播放会话，在后台可以继续播放（还需要设置程序允许后台运行模式）
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//    if(![[AVAudioSession sharedInstance] setActive:YES error:nil])
//    {
//        NSLog(@"Failed to set up a session.");
//    }
    
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
    
    
//    [self becomeFirstResponder];  // 这里是不需要的
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

//
//启用远程事件接收（使用[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];方法）。
//对于UI控件同样要求必须是第一响应者（对于视图控制器UIViewController或者应用程序UIApplication对象监听无此要求）。
//应用程序必须是当前音频的控制者，也就是在iOS 7中通知栏中当前音频播放程序必须是我们自己开发程序。

# pragma mark - Remote control



//
//typedef NS_ENUM(NSInteger, UIEventSubtype) {
//    // 不包含任何子事件类型
//    UIEventSubtypeNone                              = 0,
//    
//    // 摇晃事件（从iOS3.0开始支持此事件）
//    UIEventSubtypeMotionShake                       = 1,
//    
//    //远程控制子事件类型（从iOS4.0开始支持远程控制事件）
//    //播放事件【操作：停止状态下，按耳机线控中间按钮一下】
//    UIEventSubtypeRemoteControlPlay                 = 100,
//    //暂停事件
//    UIEventSubtypeRemoteControlPause                = 101,
//    //停止事件
//    UIEventSubtypeRemoteControlStop                 = 102,
//    //播放或暂停切换【操作：播放或暂停状态下，按耳机线控中间按钮一下】
//    UIEventSubtypeRemoteControlTogglePlayPause      = 103,
//    //下一曲【操作：按耳机线控中间按钮两下】
//    UIEventSubtypeRemoteControlNextTrack            = 104,
//    //上一曲【操作：按耳机线控中间按钮三下】
//    UIEventSubtypeRemoteControlPreviousTrack        = 105,
//    //快退开始【操作：按耳机线控中间按钮三下不要松开】
//    UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
//    //快退停止【操作：按耳机线控中间按钮三下到了快退的位置松开】
//    UIEventSubtypeRemoteControlEndSeekingBackward   = 107,
//    //快进开始【操作：按耳机线控中间按钮两下不要松开】
//    UIEventSubtypeRemoteControlBeginSeekingForward  = 108,
//    //快进停止【操作：按耳机线控中间按钮两下到了快进的位置松开】
//    UIEventSubtypeRemoteControlEndSeekingForward    = 109,
//};


//为了模拟一个真实的播放器，程序中我们启用了后台运行模式，配置方法：在info.plist中添加UIBackgroundModes并且添加一个元素值为audio。 

//在iOS中事件分为三类：
//
//触摸事件：通过触摸、手势进行触发（例如手指点击、缩放）
//运动事件：通过加速器进行触发（例如手机晃动）
//远程控制事件：通过其他远程设备触发（例如耳机控制按钮）

// 设置远程控制事件     方便使用耳机进行控制
// http://www.cnblogs.com/kenshincui/p/3950646.html
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
                //
            case UIEventSubtypeRemoteControlPause:
                [[MusicViewController sharedInstance].streamer pause];
                break;
                
                //暂停事件
            case UIEventSubtypeRemoteControlStop:
                break;
                
                //停止事件
            case UIEventSubtypeRemoteControlPlay:
                [[MusicViewController sharedInstance].streamer play];
                break;
                
                
                // 播放或暂停切换 【播放或暂停状态下，按耳机线控中间按钮一下】
            case UIEventSubtypeRemoteControlTogglePlayPause:
                break;
                
                ////下一曲【操作：按耳机线控中间按钮两下】 下一曲
            case UIEventSubtypeRemoteControlNextTrack:
                [[MusicViewController sharedInstance] playNextMusic:nil];
                break;
                //上一曲【操作：按耳机线控中间按钮三下】
            case UIEventSubtypeRemoteControlPreviousTrack:
                [[MusicViewController sharedInstance] playPreviousMusic:nil];
                break;
            default:
                break;
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 允许后天任务
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
}


@end

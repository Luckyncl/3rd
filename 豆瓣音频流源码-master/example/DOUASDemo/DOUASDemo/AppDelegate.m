/* vim: set ft=objc fenc=utf-8 sw=2 ts=2 et: */
/*
 *  DOUAudioStreamer - A Core Audio based streaming audio player for iOS/Mac:
 *
 *      https://github.com/douban/DOUAudioStreamer
 *
 *  Copyright 2013-2016 Douban Inc.  All rights reserved.
 *
 *  Use and distribution licensed under the BSD license.  See
 *  the LICENSE file for full text.
 *
 *  Authors:
 *      Chongyu Zhu <i@lembacon.com>
 *
 */

#import "AppDelegate.h"
#import "MainViewController.h"
#import "DOUAudioStreamer.h"
#import "DOUAudioStreamer+Options.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

  
    // 设置 了所有的选项
    //  DOUAudioStreamerKeepPersistentVolume = 1 << 0,   设置的音量
    //    DOUAudioStreamerRemoveCacheOnDeallocation = 1 << 1,  当有缓存的时候清楚缓存
    //    DOUAudioStreamerRequireSHA256 = 1 << 2,
  [DOUAudioStreamer setOptions:[DOUAudioStreamer options] | DOUAudioStreamerRequireSHA256];
    
    
    
  [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];

  MainViewController *mainViewController = [[MainViewController alloc] initWithStyle:UITableViewStylePlain];
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    // setRootViewController  设置跟控制器
  [[self window] setRootViewController:navigationController];

  [[self window] makeKeyAndVisible];

  return YES;
}

@end

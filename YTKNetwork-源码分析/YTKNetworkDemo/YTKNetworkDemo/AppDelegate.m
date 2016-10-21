//
//  AppDelegate.m
//  YTKNetworkDemo
//
//  Created by Chenyu Lan on 10/28/14.
//  Copyright (c) 2014 yuantiku.com. All rights reserved.
//

#import "AppDelegate.h"
#import "YTKNetworkConfig.h"
#import "YTKUrlArgumentsFilter.h"

@interface AppDelegate ()

@end

@implementation AppDelegate




- (void)setupRequestFilters {
//    配置
    YTKNetworkConfig *config = [YTKNetworkConfig sharedInstance];
    config.baseUrl = @"http://www.tianshengdiyi.com";
//    config.cdnUrl = @"";
//   http://www.tianshengdiyi.com/app/index.php?action=carousel
    
////  添加版本号  给每一个请求  eg：http://www.tianshengdiyi.com/app/index.php?action=carousel&version=value
//    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    YTKUrlArgumentsFilter *urlFilter = [YTKUrlArgumentsFilter filterWithArguments:@{@"version": appVersion}];
//    [config addUrlFilter:urlFilter];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupRequestFilters];
    return YES;
}


@end

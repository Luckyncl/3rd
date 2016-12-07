/* vim: set ft=objc fenc=utf-8 sw=2 ts=2 et: */
/*
 *  DOUAudioStreamer - A Core Audio based streaming audio player for iOS/Mac:
 *
 *      https://github.com/douban/DOUAudioStreamer
 *
 *  Copyright 2013-2014 Douban Inc.  All rights reserved.
 *
 *  Use and distribution licensed under the BSD license.  See
 *  the LICENSE file for full text.
 *
 *  Authors:
 *      Chongyu Zhu <i@lembacon.com>
 *
 */

#import <Foundation/Foundation.h>
#import "DOUAudioFile.h"

@interface Track : NSObject <DOUAudioFile>
@property (nonatomic, strong) NSURL *audioFileURL;  // 音乐播放地址
@property (nonatomic, strong) NSURL *tempFileURL;   // 临时文件地址
@property (nonatomic, strong) NSURL *cacheFileURL;  // 缓存文件地址


@end

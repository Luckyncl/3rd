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

#import "PlayerViewController.h"
#import "Track.h"
#import "DOUAudioStreamer.h"
#import "DOUAudioVisualizer.h"


// 这样应该是 值绑定 的机智
static void *kStatusKVOKey = &kStatusKVOKey;      // 状态
static void *kDurationKVOKey = &kDurationKVOKey;    // 总时间
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;    // 音频帧的频率

@interface PlayerViewController () {
@private
  UILabel *_titleLabel;
  UILabel *_statusLabel;
  UILabel *_miscLabel;

  UIButton *_buttonPlayPause;
  UIButton *_buttonNext;
  UIButton *_buttonStop;

  UISlider *_progressSlider;

  UILabel *_volumeLabel;
  UISlider *_volumeSlider;

  NSUInteger _currentTrackIndex;
  NSTimer *_timer;

  DOUAudioStreamer *_streamer;
  DOUAudioVisualizer *_audioVisualizer;
}
@end

@implementation PlayerViewController

// 加载视图
- (void)loadView
{
  UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [view setBackgroundColor:[UIColor whiteColor]];
    
    // 标题
  _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 64.0, CGRectGetWidth([view bounds]), 30.0)];
  [_titleLabel setFont:[UIFont systemFontOfSize:20.0]];
  [_titleLabel setTextColor:[UIColor blackColor]];
  [_titleLabel setTextAlignment:NSTextAlignmentCenter];
  [_titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
  [view addSubview:_titleLabel];

    // 歌曲频道的状态
  _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([_titleLabel frame]) + 10.0, CGRectGetWidth([view bounds]), 30.0)];
  [_statusLabel setFont:[UIFont systemFontOfSize:16.0]];
  [_statusLabel setTextColor:[UIColor colorWithWhite:0.4 alpha:1.0]];
  [_statusLabel setTextAlignment:NSTextAlignmentCenter];
  [_statusLabel setLineBreakMode:NSLineBreakByTruncatingTail];
  [view addSubview:_statusLabel];

  _miscLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([_statusLabel frame]) + 10.0, CGRectGetWidth([view bounds]), 20.0)];
  [_miscLabel setFont:[UIFont systemFontOfSize:10.0]];
  [_miscLabel setTextColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
  [_miscLabel setTextAlignment:NSTextAlignmentCenter];
  [_miscLabel setLineBreakMode:NSLineBreakByTruncatingTail];
  [view addSubview:_miscLabel];

  _buttonPlayPause = [UIButton buttonWithType:UIButtonTypeSystem];
  [_buttonPlayPause setFrame:CGRectMake(80.0, CGRectGetMaxY([_miscLabel frame]) + 20.0, 60.0, 20.0)];
  [_buttonPlayPause setTitle:@"Play" forState:UIControlStateNormal];
  [_buttonPlayPause addTarget:self action:@selector(_actionPlayPause:) forControlEvents:UIControlEventTouchDown];
  [view addSubview:_buttonPlayPause];

  _buttonNext = [UIButton buttonWithType:UIButtonTypeSystem];
  [_buttonNext setFrame:CGRectMake(CGRectGetWidth([view bounds]) - 80.0 - 60.0, CGRectGetMinY([_buttonPlayPause frame]), 60.0, 20.0)];
  [_buttonNext setTitle:@"Next" forState:UIControlStateNormal];
  [_buttonNext addTarget:self action:@selector(_actionNext:) forControlEvents:UIControlEventTouchDown];
  [view addSubview:_buttonNext];

  _buttonStop = [UIButton buttonWithType:UIButtonTypeSystem];
  [_buttonStop setFrame:CGRectMake(round((CGRectGetWidth([view bounds]) - 60.0) / 2.0), CGRectGetMaxY([_buttonNext frame]) + 20.0, 60.0, 20.0)];
  [_buttonStop setTitle:@"Stop" forState:UIControlStateNormal];
  [_buttonStop addTarget:self action:@selector(_actionStop:) forControlEvents:UIControlEventTouchDown];
  [view addSubview:_buttonStop];

  _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_buttonStop frame]) + 20.0, CGRectGetWidth([view bounds]) - 20.0 * 2.0, 40.0)];
  [_progressSlider addTarget:self action:@selector(_actionSliderProgress:) forControlEvents:UIControlEventValueChanged];
  [view addSubview:_progressSlider];

  _volumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_progressSlider frame]) + 20.0, 80.0, 40.0)];
  [_volumeLabel setText:@"Volume:"];
  [view addSubview:_volumeLabel];

  _volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX([_volumeLabel frame]) + 10.0, CGRectGetMinY([_volumeLabel frame]), CGRectGetWidth([view bounds]) - CGRectGetMaxX([_volumeLabel frame]) - 10.0 - 20.0, 40.0)];
  [_volumeSlider addTarget:self action:@selector(_actionSliderVolume:) forControlEvents:UIControlEventValueChanged];
  [view addSubview:_volumeSlider];

  _audioVisualizer = [[DOUAudioVisualizer alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([_volumeSlider frame]), CGRectGetWidth([view bounds]), CGRectGetHeight([view bounds]) - CGRectGetMaxY([_volumeSlider frame]))];
//  [_audioVisualizer setBackgroundColor:[UIColor colorWithRed:239.0 / 255.0 green:244.0 / 255.0 blue:240.0 / 255.0 alpha:1.0]];
  [_audioVisualizer setBackgroundColor: [UIColor redColor]];
  [view addSubview:_audioVisualizer];

    
  // 替换控制器 view
  [self setView:view];
}

/* 首先设置UI ->   然后重启数据流         */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self _resetStreamer];
    
    // 开启定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
    
    // 设置 slider的声音
    [_volumeSlider setValue:[DOUAudioStreamer volume]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // 首先关闭定时器 -> 然后关闭音频流 -> 最后
    [_timer invalidate];
    
    [_streamer stop];
    [self _cancelStreamer];
    
    [super viewWillDisappear:animated];
}


// 首先停止
- (void)_cancelStreamer
{
  if (_streamer != nil) {
    [_streamer pause];
    [_streamer removeObserver:self forKeyPath:@"status"];
    [_streamer removeObserver:self forKeyPath:@"duration"];
    [_streamer removeObserver:self forKeyPath:@"bufferingRatio"];
      // 首先暂停播放， 然后清除输入流
    _streamer = nil;
  }
}

/*  重置音频流   */
- (void)_resetStreamer
{
  [self _cancelStreamer];

    if (0 == [_tracks count])
    {
        [_miscLabel setText:@"(没有音乐可获得)"];
    }
    else
    {
        // 获取需要播放的音乐，能播放的类 需要遵循  DOUAudioFile 协议即可
        Track *track = [_tracks objectAtIndex:_currentTrackIndex];
        NSString *title = [NSString stringWithFormat:@"%@ - %@", track.artist, track.title];
        [_titleLabel setText:title];
        
        track.audioFileURL =  [NSURL URLWithString:@"http://mr1.doubanio.com/8786589e1f2266aedcf94d042fcda296/0/fm/song/p563_128k.mp4"];
        // 使用核心音频流进行播放
        _streamer = [DOUAudioStreamer streamerWithAudioFile:track];
        
        // 监听 核心音频流的状态
        [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
        // 监听 时间
        [_streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
        // 监听 buffer 的 频率
        [_streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
        
        // 播放
        [_streamer play];
        
        
        
        // 更新缓存状态
        [self _updateBufferingStatus];
        
        // 确定播放源
        [self _setupHintForStreamer];
    }
}

// 启动播放源  包装了 播放下一曲
- (void)_setupHintForStreamer
{
    
  NSUInteger nextIndex = _currentTrackIndex + 1;
  if (nextIndex >= [_tracks count]) {
    nextIndex = 0;
  }

    // 切换 音乐源
  [DOUAudioStreamer setHintWithAudioFile:[_tracks objectAtIndex:nextIndex]];
}

// 定时器任务
- (void)_timerAction:(id)timer
{
   
  // 在没有获得总时间的时候， 需要一直置零
  if ([_streamer duration] == 0.0) {
    [_progressSlider setValue:0.0f animated:NO];
  }
  else {
    [_progressSlider setValue:[_streamer currentTime] / [_streamer duration] animated:YES];
  }
    
    
}


/**
    跟新音频流的状态
 */
- (void)_updateStatus
{
  switch ([_streamer status]) {
  case DOUAudioStreamerPlaying:
    [_statusLabel setText:@"playing"];
    [_buttonPlayPause setTitle:@"Pause" forState:UIControlStateNormal];
    break;

  case DOUAudioStreamerPaused:
    [_statusLabel setText:@"paused"];
    [_buttonPlayPause setTitle:@"Play" forState:UIControlStateNormal];
    break;

  case DOUAudioStreamerIdle:
    [_statusLabel setText:@"idle"];
    [_buttonPlayPause setTitle:@"Play" forState:UIControlStateNormal];
    break;

  case DOUAudioStreamerFinished:
    [_statusLabel setText:@"finished"];
    [self _actionNext:nil];
    break;

  case DOUAudioStreamerBuffering:
    [_statusLabel setText:@"buffering"];
    break;

  case DOUAudioStreamerError:
    [_statusLabel setText:@"error"];
    break;
  }
}


/*  下载进度的问题   */
- (void)_updateBufferingStatus
{
    // 文件长度 M    下载的速度
  [_miscLabel setText:[NSString stringWithFormat:@"Received %.2f/%.2f MB (%.2f %%), Speed %.2f MB/s", (double)[_streamer receivedLength] / 1024 / 1024, (double)[_streamer expectedLength] / 1024 / 1024, [_streamer bufferingRatio] * 100.0, (double)[_streamer downloadSpeed] / 1024 / 1024]];

  if ([_streamer bufferingRatio] >= 1.0) {
      
      // 哈希值加密
    NSLog(@"sha256: %@", [_streamer sha256]);
  }
}

// 通过kvo 来监听  当dealloc的时候 还需要移除 这里是通过kvo 来监听的  这样感觉并不是很好 （若果没有复用的话，难道每个player页面都要写一遍么）
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 这里很溜了  不是通过keyPath 来判断 而是通过context 来当做key 来判断  这样容易阅读
        // static void *kStatusKVOKey = &kStatusKVOKey;      // 状态
  if (context == kStatusKVOKey) {
      
      // 调到主线程来刷新UI
    [self performSelector:@selector(_updateStatus)
                 onThread:[NSThread mainThread]
               withObject:nil
            waitUntilDone:NO];
  }
    
  else if (context == kDurationKVOKey) {
    [self performSelector:@selector(_timerAction:)
                 onThread:[NSThread mainThread]
               withObject:nil
            waitUntilDone:NO];
  }
  else if (context == kBufferingRatioKVOKey) {
    [self performSelector:@selector(_updateBufferingStatus)
                 onThread:[NSThread mainThread]
               withObject:nil
            waitUntilDone:NO];
  }
  else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}



/*       播放器暂停     这里是根据播放器的状态来使用的   */
- (void)_actionPlayPause:(id)sender
{
    // 如果是暂停状态 和 空闲状态的话  就开始播放
  if ([_streamer status] == DOUAudioStreamerPaused ||
      [_streamer status] == DOUAudioStreamerIdle) {
    [_streamer play];
  }
  else {
      // 否则就暂停
    [_streamer pause];
  }
}


// 播放下一句   需要重新 设置音频流
- (void)_actionNext:(id)sender
{
  if (++_currentTrackIndex >= [_tracks count]) {
    _currentTrackIndex = 0;
  }

  [self _resetStreamer];
}


// 停止播放音频
- (void)_actionStop:(id)sender
{
  [_streamer stop];
}

// 设置 当前的时间
- (void)_actionSliderProgress:(id)sender
{
  [_streamer setCurrentTime:[_streamer duration] * [_progressSlider value]];
}

// 设置 声音slider
- (void)_actionSliderVolume:(id)sender
{
  [DOUAudioStreamer setVolume:[_volumeSlider value]];
}

@end

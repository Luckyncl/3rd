//
//  MusicViewController.h
//  Enesco
//
//  Created by Aufree on 11/30/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOUAudioStreamer.h"
#import "GVUserDefaults+Properties.h"
#import "MusicEntity.h"

@protocol MusicViewControllerDelegate <NSObject>
@optional

// 更新可见的cell的 播放 标识cell
- (void)updatePlaybackIndicatorOfVisisbleCells;
@end

@interface MusicViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *musicEntities;
@property (nonatomic, copy) NSString *musicTitle;
@property (nonatomic, strong) DOUAudioStreamer *streamer;
@property (nonatomic, assign) BOOL dontReloadMusic;                     // 是否重新刷新音乐
@property (nonatomic, assign) NSInteger specialIndex;                   // 特定那个 index
@property (nonatomic, copy) NSNumber *parentId;
@property (nonatomic, weak) id<MusicViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isNotPresenting;
@property (nonatomic, assign) MusicCycleType musicCycleType;            // 音乐循环的类型
+ (instancetype)sharedInstance;
- (IBAction)playPreviousMusic:(id)sender;
- (IBAction)playNextMusic:(id)sender;

// 获取当前的音乐
- (MusicEntity *)currentPlayingMusic;
@end

//

//    离线渲染


//  参考于  https://github.com/TheAmazingAudioEngine/TheAmazingAudioEngine
//

@interface AKOfflineRenderer: NSObject

//   核心引擎
@property(strong, nonatomic) AVAudioEngine *engine;

// 使用核心引擎初始化
- (instancetype)initWithEngine:(AVAudioEngine *)injun;


// 开始渲染
- (void)render:(int)samples;
@end

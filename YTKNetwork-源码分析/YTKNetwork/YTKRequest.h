

#import "YTKBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface YTKRequest : YTKBaseRequest

    // 是否忽略缓存
@property (nonatomic) BOOL ignoreCache;

/// 返回当前缓存的对象    （返回当前缓存的对象）
- (nullable id)cacheJson;

/// 当前的数据是否从缓存中获得
- (BOOL)isDataFromCache;

/// 返回是否当前缓存需要更新
- (BOOL)isCacheVersionExpired;

/// 强制更新缓存 （实际上就是删除缓存呗）
- (void)startWithoutCache;

/// 手动将其他请求的JsonResponse写入该请求的缓存
- (void)saveJsonResponseToCacheFile:(id)jsonResponse;


/*
 下面的方法需要去重写
 */

/// For subclass to overwrite
- (NSInteger)cacheTimeInSeconds;    // 按时间缓存
- (long long)cacheVersion;          // 按版本缓存
- (nullable id)cacheSensitiveData; 

@end

NS_ASSUME_NONNULL_END

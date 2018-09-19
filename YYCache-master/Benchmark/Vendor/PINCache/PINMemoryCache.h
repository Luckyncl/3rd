//  PINCache is a modified version of TMCache
//  Modifications by Garrett Moon
//  Copyright (c) 2015 Pinterest. All rights reserved.

#import <Foundation/Foundation.h>

#import <PINCache/PINCacheMacros.h>
#import <PINCache/PINCaching.h>
#import <PINCache/PINCacheObjectSubscripting.h>

NS_ASSUME_NONNULL_BEGIN

@class PINMemoryCache;
@class PINOperationQueue;


/**
 `PINMemoryCache` is a fast, thread safe key/value store similar to `NSCache`. On iOS it will clear itself
 automatically to reduce memory usage when the app receives a memory warning or goes into the background.
 
 Access is natively synchronous. Asynchronous variations are provided. Every asynchronous method accepts a
 callback block that runs on a concurrent <concurrentQueue>, with cache reads and writes protected by a lock.
 
 All access to the cache is dated so the that the least-used objects can be trimmed first. Setting an
 optional <ageLimit> will trigger a GCD timer to periodically to trim the cache to that age.
 
 Objects can optionally be set with a "cost", which could be a byte count or any other meaningful integer.
 Setting a <costLimit> will automatically keep the cache below that value with <trimToCostByDate:>.
 
 Values will not persist after application relaunch or returning from the background. See <PINCache> for
 a memory cache backed by a disk cache.
 */

PIN_SUBCLASSING_RESTRICTED
@interface PINMemoryCache : NSObject <PINCaching, PINCacheObjectSubscripting>

#pragma mark - Properties
/// @name Core

/**
 The total accumulated cost.
 */
@property (readonly) NSUInteger totalCost;

/**
 The maximum cost allowed to accumulate before objects begin to be removed with <trimToCostByDate:>.
 */
@property (assign) NSUInteger costLimit;

/**
 The maximum number of seconds an object is allowed to exist in the cache. Setting this to a value
 greater than `0.0` will start a recurring GCD timer with the same period that calls <trimToDate:>.
 Setting it back to `0.0` will stop the timer. Defaults to `0.0`.
 */
@property (assign) NSTimeInterval ageLimit;

/**
 If ttlCache is YES, the cache behaves like a ttlCache. This means that once an object enters the
 cache, it only lives as long as self.ageLimit. This has the following implications:
    如果ttlCache为YES，则缓存的行为类似于ttlCache。 这意味着一旦一个物体进入
     缓存，它只与self.ageLimit一样长。 这具有以下含义：
 
 - Accessing an object in the cache does not extend that object's lifetime in the cache
    访问缓存中的对象不会将该对象的生存期延长到缓存中
 - When attempting to access an object in the cache that has lived longer than self.ageLimit,
 the cache will behave as if the object does not exist
    尝试访问缓存中长度超过self.ageLimit的对象时，
        缓存的行为就像对象不存在一样
 
 @note If an object-level age limit is set via one of the @c -setObject:forKey:withAgeLimit methods,
       that age limit overrides self.ageLimit. The overridden object age limit could be greater or
       less than self.agelimit but must be greater than zero.
 
    如果通过@c -setObject：forKey：withAgeLimit方法之一设置了对象级年龄限制，
         该年龄限制会覆盖self.ageLimit。 被覆盖的对象年龄限制可能更大或
         小于self.agelimit但必须大于零
 */
@property (nonatomic, readonly, getter=isTTLCache) BOOL ttlCache;

/**
 When `YES` on iOS the cache will remove all objects when the app receives a memory warning.
 Defaults to `YES`.
 */
@property (assign) BOOL removeAllObjectsOnMemoryWarning;

/**
 When `YES` on iOS the cache will remove all objects when the app enters the background.
 Defaults to `YES`.
 */
@property (assign) BOOL removeAllObjectsOnEnteringBackground;

#pragma mark - Event Blocks
/// @name Event Blocks

/**
 A block to be executed just before an object is added to the cache. This block will be excuted within
 a lock, i.e. all reads and writes are suspended for the duration of the block.
 Calling synchronous methods on the cache within this callback will likely cause a deadlock.
    在将对象添加到缓存之前执行的块。 该块将在内部执行
        锁定，即所有读取和写入在块的持续时间内暂停。
        在此回调中调用缓存上的同步方法可能会导致死锁。
 */
@property (nullable, copy) PINCacheObjectBlock willAddObjectBlock;

/**
 A block to be executed just before an object is removed from the cache. This block will be excuted
 within a lock, i.e. all reads and writes are suspended for the duration of the block.
 Calling synchronous methods on the cache within this callback will likely cause a deadlock.
 */
@property (nullable, copy) PINCacheObjectBlock willRemoveObjectBlock;

/**
 A block to be executed just before all objects are removed from the cache as a result of <removeAllObjects:>.
 This block will be excuted within a lock, i.e. all reads and writes are suspended for the duration of the block.
 Calling synchronous methods on the cache within this callback will likely cause a deadlock.
 */
@property (nullable, copy) PINCacheBlock willRemoveAllObjectsBlock;

/**
 A block to be executed just after an object is added to the cache. This block will be excuted within
 a lock, i.e. all reads and writes are suspended for the duration of the block.
 Calling synchronous methods on the cache within this callback will likely cause a deadlock.
 */
@property (nullable, copy) PINCacheObjectBlock didAddObjectBlock;

/**
 A block to be executed just after an object is removed from the cache. This block will be excuted
 within a lock, i.e. all reads and writes are suspended for the duration of the block.
 Calling synchronous methods on the cache within this callback will likely cause a deadlock.
 */
@property (nullable, copy) PINCacheObjectBlock didRemoveObjectBlock;

/**
 A block to be executed just after all objects are removed from the cache as a result of <removeAllObjects:>.
 This block will be excuted within a lock, i.e. all reads and writes are suspended for the duration of the block.
 Calling synchronous methods on the cache within this callback will likely cause a deadlock.
 */
@property (nullable, copy) PINCacheBlock didRemoveAllObjectsBlock;

/**
 A block to be executed upon receiving a memory warning (iOS only) potentially in parallel with other blocks on the <queue>.
 This block will be executed regardless of the value of <removeAllObjectsOnMemoryWarning>. Defaults to `nil`.
 */
@property (nullable, copy) PINCacheBlock didReceiveMemoryWarningBlock;

/**
 A block to be executed when the app enters the background (iOS only) potentially in parallel with other blocks on the <concurrentQueue>.
 This block will be executed regardless of the value of <removeAllObjectsOnEnteringBackground>. Defaults to `nil`.
 */
@property (nullable, copy) PINCacheBlock didEnterBackgroundBlock;

#pragma mark - Lifecycle    生命周期
/// @name Shared Cache

/**
 A shared cache.
 
 @result The shared singleton cache instance.
 */
@property (class, strong, readonly) PINMemoryCache *sharedCache;

- (instancetype)initWithOperationQueue:(PINOperationQueue *)operationQueue;

- (instancetype)initWithName:(NSString *)name operationQueue:(PINOperationQueue *)operationQueue;

- (instancetype)initWithName:(NSString *)name operationQueue:(PINOperationQueue *)operationQueue ttlCache:(BOOL)ttlCache NS_DESIGNATED_INITIALIZER;

#pragma mark - Asynchronous Methods     异步的方法
/// @name Asynchronous Methods

/**
 Removes objects from the cache, costliest objects first, until the <totalCost> is below the specified
 value. This method returns immediately and executes the passed block after the cache has been trimmed,
 potentially in parallel with other blocks on the <concurrentQueue>.
    首先从高速缓存中删除对象，这是最昂贵的对象，直到<totalCost>低于指定的值
        值。 此方法立即返回并在修剪缓存后执行传递的块，
        可能与<concurrentQueue>上的其他块并行。
 @param cost The total accumulation allowed to remain after the cache has been trimmed.
 @param block A block to be executed concurrently after the cache has been trimmed, or nil.
 */
- (void)trimToCostAsync:(NSUInteger)cost completion:(nullable PINCacheBlock)block;

/**
 Removes objects from the cache, ordered by date (least recently used first), until the <totalCost> is below
 the specified value. This method returns immediately and executes the passed block after the cache has been
 trimmed, potentially in parallel with other blocks on the <concurrentQueue>.
 
 @param cost The total accumulation allowed to remain after the cache has been trimmed.
 @param block A block to be executed concurrently after the cache has been trimmed, or nil.
 */
- (void)trimToCostByDateAsync:(NSUInteger)cost completion:(nullable PINCacheBlock)block;

/**
 Loops through all objects in the cache with reads and writes suspended. Calling serial methods which
 write to the cache inside block may be unsafe and may result in a deadlock. This method returns immediately.
 
 @param block A block to be executed for every object in the cache.
 @param completionBlock An optional block to be executed concurrently when the enumeration is complete.
 */
- (void)enumerateObjectsWithBlockAsync:(PINCacheObjectEnumerationBlock)block completionBlock:(nullable PINCacheBlock)completionBlock;

#pragma mark - Synchronous Methods   同步的方法
/// @name Synchronous Methods

/**
 Removes objects from the cache, costliest objects first, until the <totalCost> is below the specified
 value. This method blocks the calling thread until the cache has been trimmed.
 
 @see trimToCostAsync:
 @param cost The total accumulation allowed to remain after the cache has been trimmed.
 */
- (void)trimToCost:(NSUInteger)cost;

/**
 Removes objects from the cache, ordered by date (least recently used first), until the <totalCost> is below
 the specified value. This method blocks the calling thread until the cache has been trimmed.
 
 @see trimToCostByDateAsync:
 @param cost The total accumulation allowed to remain after the cache has been trimmed.
 */
- (void)trimToCostByDate:(NSUInteger)cost;

/**
 Loops through all objects in the cache within a memory lock (reads and writes are suspended during the enumeration).
 This method blocks the calling thread until all objects have been enumerated.
 Calling synchronous methods on the cache within this callback will likely cause a deadlock.
 
 @see enumerateObjectsWithBlockAsync:completionBlock:
 @param block A block to be executed for every object in the cache.
 
 @warning Do not call this method within the event blocks (<didReceiveMemoryWarningBlock>, etc.)
 Instead use the asynchronous version, <enumerateObjectsWithBlock:completionBlock:>.
 
 */
- (void)enumerateObjectsWithBlock:(PIN_NOESCAPE PINCacheObjectEnumerationBlock)block;

@end



NS_ASSUME_NONNULL_END

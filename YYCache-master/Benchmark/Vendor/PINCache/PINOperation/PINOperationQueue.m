//
//  PINOperationQueue.m
//  Pods
//
//  Created by Garrett Moon on 8/23/16.
//
//

#import "PINOperationQueue.h"
#import <pthread.h>

@class PINOperation;

@interface NSNumber (PINOperationQueue) <PINOperationReference>

@end

@interface PINOperationQueue () {
  pthread_mutex_t _lock;
  //increments with every operation to allow cancelation
  //    每次操作都会增加以允许取消
  NSUInteger _operationReferenceCount;
  NSUInteger _maxConcurrentOperations;
  
  dispatch_group_t _group;                          // 一个线程组
  
  dispatch_queue_t _serialQueue;                    // 一个串行队列
  BOOL _serialQueueBusy;
  
  dispatch_semaphore_t _concurrentSemaphore;        //并发的信号量
  dispatch_queue_t _concurrentQueue;                // 并发队列
  dispatch_queue_t _semaphoreQueue;                 // 信号量串行队列，用于控制线程执行顺序的
  
  NSMutableOrderedSet<PINOperation *> *_queuedOperations;
  NSMutableOrderedSet<PINOperation *> *_lowPriorityOperations;
  NSMutableOrderedSet<PINOperation *> *_defaultPriorityOperations;
  NSMutableOrderedSet<PINOperation *> *_highPriorityOperations;
  
  NSMapTable<id<PINOperationReference>, PINOperation *> *_referenceToOperations;
  NSMapTable<NSString *, PINOperation *> *_identifierToOperations;
}

@end

@interface PINOperation : NSObject

@property (nonatomic, strong) PINOperationBlock block;
@property (nonatomic, strong) id <PINOperationReference> reference;
@property (nonatomic, assign) PINOperationQueuePriority priority;
@property (nonatomic, strong) NSMutableArray<dispatch_block_t> *completions;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) id data;

+ (instancetype)operationWithBlock:(PINOperationBlock)block reference:(id <PINOperationReference>)reference priority:(PINOperationQueuePriority)priority identifier:(nullable NSString *)identifier data:(nullable id)data completion:(nullable dispatch_block_t)completion;

- (void)addCompletion:(nullable dispatch_block_t)completion;

@end

@implementation PINOperation

+ (instancetype)operationWithBlock:(PINOperationBlock)block reference:(id<PINOperationReference>)reference priority:(PINOperationQueuePriority)priority identifier:(NSString *)identifier data:(id)data completion:(dispatch_block_t)completion
{
  PINOperation *operation = [[self alloc] init];
  operation.block = block;
  operation.reference = reference;
  operation.priority = priority;
  operation.identifier = identifier;
  operation.data = data;
  [operation addCompletion:completion];
  
  return operation;
}

- (void)addCompletion:(dispatch_block_t)completion
{
  if (completion == nil) {
    return;
  }
  if (_completions == nil) {
    _completions = [NSMutableArray array];
  }
  [_completions addObject:completion];
}

@end

@implementation PINOperationQueue

- (instancetype)initWithMaxConcurrentOperations:(NSUInteger)maxConcurrentOperations
{
  return [self initWithMaxConcurrentOperations:maxConcurrentOperations concurrentQueue:dispatch_queue_create("PINOperationQueue Concurrent Queue", DISPATCH_QUEUE_CONCURRENT)];
}

- (instancetype)initWithMaxConcurrentOperations:(NSUInteger)maxConcurrentOperations concurrentQueue:(dispatch_queue_t)concurrentQueue
{
  if (self = [super init]) {
    NSAssert(maxConcurrentOperations > 0, @"Max concurrent operations must be greater than 0.");
    _maxConcurrentOperations = maxConcurrentOperations;
    _operationReferenceCount = 0;
    
    // 设置锁的 属性
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    //mutex must be recursive to allow scheduling of operations from within operations
    // 互斥必须是递归的，以允许从操作中调度操作
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&_lock, &attr);
    
    // 创建一个线程组
    _group = dispatch_group_create();
    
    // 创建一个串行队列
    _serialQueue = dispatch_queue_create("PINOperationQueue Serial Queue", DISPATCH_QUEUE_SERIAL);
    
    // 传入的并发队列
    _concurrentQueue = concurrentQueue;
    
    //Create a queue with max - 1 because this plus the serial queue add up to max.
    //      使用max - 1创建一个队列，因为这加上串行队列加起来最大值。
    _concurrentSemaphore = dispatch_semaphore_create(_maxConcurrentOperations - 1);
   // 信号量串行队列
    _semaphoreQueue = dispatch_queue_create("PINOperationQueue Serial Semaphore Queue", DISPATCH_QUEUE_SERIAL);
    
    _queuedOperations = [[NSMutableOrderedSet alloc] init];
    _lowPriorityOperations = [[NSMutableOrderedSet alloc] init];
    _defaultPriorityOperations = [[NSMutableOrderedSet alloc] init];
    _highPriorityOperations = [[NSMutableOrderedSet alloc] init];
    
    _referenceToOperations = [NSMapTable weakToWeakObjectsMapTable];
    _identifierToOperations = [NSMapTable weakToWeakObjectsMapTable];
  }
  return self;
}

- (void)dealloc
{
  pthread_mutex_destroy(&_lock);
}

+ (instancetype)sharedOperationQueue
{
    static PINOperationQueue *sharedOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //        NSProcessInfo 用于获取当前进程信息的类
        //       [NSProcessInfo processInfo] activeProcessorCount] ---> 计算机上可用的活动处理核心数。
        sharedOperationQueue = [[PINOperationQueue alloc] initWithMaxConcurrentOperations:MAX([[NSProcessInfo processInfo] activeProcessorCount], 2)];
    });
    return sharedOperationQueue;
}

- (id <PINOperationReference>)nextOperationReference
{
  [self lock];
    id <PINOperationReference> reference = [NSNumber numberWithUnsignedInteger:++_operationReferenceCount];
  [self unlock];
  return reference;
}


- (id <PINOperationReference>)scheduleOperation:(dispatch_block_t)block
{
  // 默认的优先级是default优先级
  return [self scheduleOperation:block withPriority:PINOperationQueuePriorityDefault];
}



// 处理高优先级
- (id <PINOperationReference>)scheduleOperation:(dispatch_block_t)block withPriority:(PINOperationQueuePriority)priority
{
  PINOperation *operation = [PINOperation operationWithBlock:^(id data) { block(); }
                                                   reference:[self nextOperationReference]
                                                    priority:priority
                                                  identifier:nil
                                                        data:nil
                                                  completion:nil];
    
// 添加操作
  [self lock];
    [self locked_addOperation:operation];
  [self unlock];
  
    // 执行操作
  [self scheduleNextOperations:NO];
  
  return operation.reference;
}



- (id<PINOperationReference>)scheduleOperation:(PINOperationBlock)block
                                  withPriority:(PINOperationQueuePriority)priority
                                    identifier:(NSString *)identifier
                                coalescingData:(id)coalescingData
                           dataCoalescingBlock:(PINOperationDataCoalescingBlock)dataCoalescingBlock
                                    completion:(dispatch_block_t)completion
{
  id<PINOperationReference> reference = nil;
  BOOL isNewOperation = NO;
  
  [self lock];
    PINOperation *operation = nil;
    if (identifier != nil && (operation = [_identifierToOperations objectForKey:identifier]) != nil) {
      // There is an exisiting operation with the provided identifier, let's coalesce these operations
     // 使用提供的标识符存在现有操作，让我们合并这些操作
      if (dataCoalescingBlock != nil) {
        operation.data = dataCoalescingBlock(operation.data, coalescingData);
      }
      
      [operation addCompletion:completion];
    } else {
      isNewOperation = YES;
      operation = [PINOperation operationWithBlock:block
                                         reference:[self nextOperationReference]
                                          priority:priority
                                        identifier:identifier
                                              data:coalescingData
                                        completion:completion];
      [self locked_addOperation:operation];
    }
    reference = operation.reference;
  [self unlock];
  
  if (isNewOperation) {
    [self scheduleNextOperations:NO];
  }
  
  return reference;
}

// MARK: 把操作添加进数组 以及
- (void)locked_addOperation:(PINOperation *)operation
{
  NSMutableOrderedSet *queue = [self operationQueueWithPriority:operation.priority];
  
  dispatch_group_enter(_group);
    
    // 这里优先级 orderSet 和 _queuedOperations 都添加了这个操作呀
  [queue addObject:operation];
  [_queuedOperations addObject:operation];
  [_referenceToOperations setObject:operation forKey:operation.reference];
  if (operation.identifier != nil) {
    [_identifierToOperations setObject:operation forKey:operation.identifier];
  }
}

- (void)cancelAllOperations
{
  [self lock];
    for (PINOperation *operation in [[_referenceToOperations copy] objectEnumerator]) {
      [self locked_cancelOperation:operation.reference];
    }
  [self unlock];
}


- (BOOL)cancelOperation:(id <PINOperationReference>)operationReference
{
  [self lock];
    BOOL success = [self locked_cancelOperation:operationReference];
  [self unlock];
  return success;
}

- (NSUInteger)maxConcurrentOperations
{
  [self lock];
    NSUInteger maxConcurrentOperations = _maxConcurrentOperations;
  [self unlock];
  return maxConcurrentOperations;
}


/**
    设置最大并发数
 */
- (void)setMaxConcurrentOperations:(NSUInteger)maxConcurrentOperations
{
  NSAssert(maxConcurrentOperations > 0, @"Max concurrent operations must be greater than 0.");
  [self lock];
    __block NSInteger difference = maxConcurrentOperations - _maxConcurrentOperations;
    _maxConcurrentOperations = maxConcurrentOperations;
  [self unlock];
  
  if (difference == 0) {
    return;
  }
  
  dispatch_async(_semaphoreQueue, ^{
    while (difference != 0) {
      if (difference > 0) {
          // 如果设置的并发数大于原并发数的话就 将信号加1
        dispatch_semaphore_signal(_concurrentSemaphore);
        difference--;
      } else {
          // 如果设置的并发数小于原并发数的话就 将信号减一
        dispatch_semaphore_wait(_concurrentSemaphore, DISPATCH_TIME_FOREVER);
        difference++;
      }
    }
  });
}

#pragma mark - private methods

// 取消操作
- (BOOL)locked_cancelOperation:(id <PINOperationReference>)operationReference
{
  BOOL success = NO;
  PINOperation *operation = [_referenceToOperations objectForKey:operationReference];
  if (operation) {
    NSMutableOrderedSet *queue = [self operationQueueWithPriority:operation.priority];
    if ([queue containsObject:operation]) {
      success = YES;
      [queue removeObject:operation];
      [_queuedOperations removeObject:operation];
      dispatch_group_leave(_group);
    }
  }
  return success;
}

- (void)setOperationPriority:(PINOperationQueuePriority)priority withReference:(id <PINOperationReference>)operationReference
{
  [self lock];
    PINOperation *operation = [_referenceToOperations objectForKey:operationReference];
    if (operation && operation.priority != priority) {
        
      // 由于 优先级不一样了，所以  在原优先级的set里面删除然后在新优先级里面添加
      NSMutableOrderedSet *oldQueue = [self operationQueueWithPriority:operation.priority];
      [oldQueue removeObject:operation];
      operation.priority = priority;
        
        
      NSMutableOrderedSet *queue = [self operationQueueWithPriority:priority];
      [queue addObject:operation];
    }
  [self unlock];
}


#pragma mark: - 处理任务的核心方法
/**
 Schedule next operations schedules the next operation by queue order onto the serial queue if
 it's available and one operation by priority order onto the concurrent queue.
    调度下一个操作按队列顺序将下一个操作调度到串行队列如果
        它可用，并按优先级顺序对并发队列进行一次操作。
 
        头部删除操作，
 */
- (void)scheduleNextOperations:(BOOL)onlyCheckSerial
{
  [self lock];
    //get next available operation in order, ignoring priority and run it on the serial queue
    //     按顺序获取下一个可用操作，忽略优先级并在串行队列上运行它
    if (_serialQueueBusy == NO) {
        // 拿到任务，并从数组中删除
      PINOperation *operation = [self locked_nextOperationByQueue];
      if (operation) {
        _serialQueueBusy = YES;
        dispatch_async(_serialQueue, ^{
            
            // 执行操作
          operation.block(operation.data);
            
            // 执行所有的完成操作
          for (dispatch_block_t completion in operation.completions) {
            completion();
          }
          dispatch_group_leave(_group);
          
          [self lock];
            _serialQueueBusy = NO;
          [self unlock];
            NSLog(@"_serialQueue");
          //see if there are any other operations
          // 看看是否还有其他操作
          [self scheduleNextOperations:YES];
        });
      }
    }
  
    // 最大的并发数量
  NSInteger maxConcurrentOperations = _maxConcurrentOperations;
  
  [self unlock];
  
  if (onlyCheckSerial) {
    return;
  }

  //if only one concurrent operation is set, let's just use the serial queue for executing it
  //     如果只设置了一个并发操作，那么让我们只使用串行队列来执行它
  if (maxConcurrentOperations < 2) {
    return;
  }
  
  dispatch_async(_semaphoreQueue, ^{
    // 并行队列
    dispatch_semaphore_wait(_concurrentSemaphore, DISPATCH_TIME_FOREVER);
    [self lock];
      PINOperation *operation = [self locked_nextOperationByPriority];
    [self unlock];
  
    if (operation) {
      dispatch_async(_concurrentQueue, ^{
          NSLog(@"_concurrentQueue");

        operation.block(operation.data);
        for (dispatch_block_t completion in operation.completions) {
          completion();
        }
        dispatch_group_leave(_group);
        dispatch_semaphore_signal(_concurrentSemaphore);
      });
    } else {
      dispatch_semaphore_signal(_concurrentSemaphore);
    }
  });
}


/**
     获取不同的队列数组
 */
- (NSMutableOrderedSet *)operationQueueWithPriority:(PINOperationQueuePriority)priority
{
  switch (priority) {
    case PINOperationQueuePriorityLow:
      return _lowPriorityOperations;
      
    case PINOperationQueuePriorityDefault:
      return _defaultPriorityOperations;
      
    case PINOperationQueuePriorityHigh:
      return _highPriorityOperations;
          
    default:
      NSAssert(NO, @"Invalid priority set");
      return _defaultPriorityOperations;
  }
}

//Call with lock held
- (PINOperation *)locked_nextOperationByPriority
{
  PINOperation *operation = [_highPriorityOperations firstObject];
  if (operation == nil) {
    operation = [_defaultPriorityOperations firstObject];
  }
  if (operation == nil) {
    operation = [_lowPriorityOperations firstObject];
  }
  if (operation) {
    [self locked_removeOperation:operation];
  }
  return operation;
}

//Call with lock held
- (PINOperation *)locked_nextOperationByQueue
{
  PINOperation *operation = [_queuedOperations firstObject];
  [self locked_removeOperation:operation];
  return operation;
}


/**
   等待一直到所有的操作都执行完成
 */
- (void)waitUntilAllOperationsAreFinished
{
  [self scheduleNextOperations:NO];
    // 这个会阻塞线程
  dispatch_group_wait(_group, DISPATCH_TIME_FOREVER);
}

//Call with lock held
- (void)locked_removeOperation:(PINOperation *)operation
{
  if (operation) {
    NSMutableOrderedSet *priorityQueue = [self operationQueueWithPriority:operation.priority];
    [priorityQueue removeObject:operation];
    [_queuedOperations removeObject:operation];
  }
}

- (void)lock
{
  pthread_mutex_lock(&_lock);
}

- (void)unlock
{
  pthread_mutex_unlock(&_lock);
}

@end

//
//  YTKChainRequestAgent.m
//
//
//
//


#import "YTKChainRequestAgent.h"

@interface YTKChainRequestAgent()

@property (strong, nonatomic) NSMutableArray<YTKChainRequest *> *requestArray;  // 用于管理 记录 网络请求的类

@end

@implementation YTKChainRequestAgent

+ (YTKChainRequestAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
    }
    return self;
}


// 注意  加锁
- (void)addChainRequest:(YTKChainRequest *)request {
    @synchronized(self) {
        [_requestArray addObject:request];
    }
}

- (void)removeChainRequest:(YTKChainRequest *)request {
    @synchronized(self) {
        [_requestArray removeObject:request];
    }
}

@end

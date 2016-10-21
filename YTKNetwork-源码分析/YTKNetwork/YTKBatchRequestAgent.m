//
//  YTKBatchRequestAgent.m
//
//

#import "YTKBatchRequestAgent.h"

@interface YTKBatchRequestAgent()

@property (strong, nonatomic) NSMutableArray<YTKBatchRequest *> *requestArray;

@end

@implementation YTKBatchRequestAgent



+ (YTKBatchRequestAgent *)sharedInstance {
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

- (void)addBatchRequest:(YTKBatchRequest *)request {
    @synchronized(self) {
        [_requestArray addObject:request];
    }
}

- (void)removeBatchRequest:(YTKBatchRequest *)request {
    @synchronized(self) {
        [_requestArray removeObject:request];
    }
}

@end

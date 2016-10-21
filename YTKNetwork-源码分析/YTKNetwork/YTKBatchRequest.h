//
//  YTKBatchRequest.h
//
//


//    批量 发送网络请求的类



#import <Foundation/Foundation.h>
#import "YTKRequest.h"

NS_ASSUME_NONNULL_BEGIN

@class YTKBatchRequest;

    //  由于是批量发送请求 常常会意味着 发送完成以后，有响应的操作，所以用一个代理去处理 请求完成后的操作
@protocol YTKBatchRequestDelegate <NSObject>

@optional  // 设计成可选的  不用担心 没有实现而导致的崩溃问题

// 完成
- (void)batchRequestFinished:(YTKBatchRequest *)batchRequest;

- (void)batchRequestFailed:(YTKBatchRequest *)batchRequest;

@end


/**
 *  用于发送批量的网络请求
 */

@interface YTKBatchRequest : NSObject

@property (strong, nonatomic, readonly) NSArray<YTKRequest *> *requestArray;

@property (weak, nonatomic, nullable) id<YTKBatchRequestDelegate> delegate;

@property (nonatomic, copy, nullable) void (^successCompletionBlock)(YTKBatchRequest *);

@property (nonatomic, copy, nullable) void (^failureCompletionBlock)(YTKBatchRequest *);

@property (nonatomic) NSInteger tag;

@property (nonatomic, strong, nullable) NSMutableArray<id<YTKRequestAccessory>> *requestAccessories;

@property (nonatomic, strong, readonly, nullable) YTKRequest *failedRequest;

- (instancetype)initWithRequestArray:(NSArray<YTKRequest *> *)requestArray;

- (void)start;

- (void)stop;

/// block回调
- (void)startWithCompletionBlockWithSuccess:(nullable void (^)(YTKBatchRequest *batchRequest))success
                                    failure:(nullable void (^)(YTKBatchRequest *batchRequest))failure;

- (void)setCompletionBlockWithSuccess:(nullable void (^)(YTKBatchRequest *batchRequest))success
                              failure:(nullable void (^)(YTKBatchRequest *batchRequest))failure;

/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;

/// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<YTKRequestAccessory>)accessory;

/// 是否当前的数据从缓存获得
- (BOOL)isDataFromCache;

@end

NS_ASSUME_NONNULL_END

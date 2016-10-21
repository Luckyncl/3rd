
#import <Foundation/Foundation.h>
#import "YTKBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN




/**
 
    用于管理 request 的 发送、取消等操作的类
 
        用于处理 网络逻辑的类，，  
             网络逻辑 统一到这个类，统一处理
 
 
 */



@interface YTKNetworkAgent : NSObject

+ (YTKNetworkAgent *)sharedInstance;

- (void)addRequest:(YTKBaseRequest *)request;

- (void)cancelRequest:(YTKBaseRequest *)request;

- (void)cancelAllRequests;

/// 根据request和networkConfig构建url
- (NSString *)buildRequestUrl:(YTKBaseRequest *)request;

@end

NS_ASSUME_NONNULL_END

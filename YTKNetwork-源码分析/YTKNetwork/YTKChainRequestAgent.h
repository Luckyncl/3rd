//
//  YTKChainRequestAgent.h
//


#import <Foundation/Foundation.h>
#import "YTKChainRequest.h"

/**
    
    管理有依赖的 网络请求
        提供 增删 记录功能
 
 */

NS_ASSUME_NONNULL_BEGIN



/// ChainRequestAgent is used for caching & keeping current request.
@interface YTKChainRequestAgent : NSObject

+ (YTKChainRequestAgent *)sharedInstance;

- (void)addChainRequest:(YTKChainRequest *)request;

- (void)removeChainRequest:(YTKChainRequest *)request;

@end

NS_ASSUME_NONNULL_END



#import <Foundation/Foundation.h>
#import "YTKBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@class AFSecurityPolicy;

@protocol YTKUrlFilterProtocol <NSObject>
- (NSString *)filterUrl:(NSString *)originUrl withRequest:(YTKBaseRequest *)request;
@end


// 缓存协议
@protocol YTKCacheDirPathFilterProtocol <NSObject>
- (NSString *)filterCacheDirPath:(NSString *)originPath withRequest:(YTKBaseRequest *)request;
@end



//    网络请求的配置。
@interface YTKNetworkConfig : NSObject

+ (YTKNetworkConfig *)sharedInstance;

@property (strong, nonatomic) NSString *baseUrl;
@property (strong, nonatomic) NSString *cdnUrl;
@property (strong, nonatomic, readonly) NSArray<id<YTKUrlFilterProtocol>> *urlFilters;
@property (strong, nonatomic, readonly) NSArray<id<YTKCacheDirPathFilterProtocol>> *cacheDirPathFilters;
@property (strong, nonatomic) AFSecurityPolicy *securityPolicy;  // 安全策略

- (void)addUrlFilter:(id<YTKUrlFilterProtocol>)filter;
- (void)addCacheDirPathFilter:(id<YTKCacheDirPathFilterProtocol>)filter;

@end

NS_ASSUME_NONNULL_END

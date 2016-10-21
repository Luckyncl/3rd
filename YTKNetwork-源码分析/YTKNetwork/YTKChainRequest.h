//
//  YTKChainRequest.h

  /*
   
   有依赖关系 的 网络请求 类
   
   */


#import <Foundation/Foundation.h>
#import "YTKBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@class YTKChainRequest;
@protocol YTKRequestAccessory;

@protocol YTKChainRequestDelegate <NSObject>

@optional

- (void)chainRequestFinished:(YTKChainRequest *)chainRequest;

- (void)chainRequestFailed:(YTKChainRequest *)chainRequest failedBaseRequest:(YTKBaseRequest*)request;

@end


    //  有依赖关系的网络请求blcok 回调

typedef void (^ChainCallback)(YTKChainRequest *chainRequest, YTKBaseRequest *baseRequest);



/**
 *  用于处理网络请求有依赖的情况
 */

@interface YTKChainRequest : NSObject

@property (weak, nonatomic, nullable) id<YTKChainRequestDelegate> delegate;

// 因为有先后顺序，， 所以 这里是指示器数组
@property (nonatomic, strong, nullable) NSMutableArray<id<YTKRequestAccessory>> *requestAccessories;



/// start chain request
- (void)start;

/// stop chain request
- (void)stop;

// 添加 请求 并且设置 回调
- (void)addRequest:(YTKBaseRequest *)request callback:(nullable ChainCallback)callback;

// 记录 请求的字典
- (NSArray<YTKBaseRequest *> *)requestArray;

/// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<YTKRequestAccessory>)accessory;

@end

NS_ASSUME_NONNULL_END

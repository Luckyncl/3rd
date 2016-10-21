
/**
 
      批量网络请求管理的类
 
 
    》》 本质上 这个类的作用 是 就是用一个字典  记录 需要批量发送请求的那些请求
 
 
 */




#import <Foundation/Foundation.h>
#import "YTKBatchRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface YTKBatchRequestAgent : NSObject





+ (YTKBatchRequestAgent *)sharedInstance; // 单例话

// 添加请求
- (void)addBatchRequest:(YTKBatchRequest *)request;

// 删除请求
- (void)removeBatchRequest:(YTKBatchRequest *)request;

@end

NS_ASSUME_NONNULL_END

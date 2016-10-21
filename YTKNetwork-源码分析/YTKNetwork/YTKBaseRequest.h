#import <Foundation/Foundation.h>
#import <AFNetworking/AFURLRequestSerialization.h>

NS_ASSUME_NONNULL_BEGIN

@class AFHTTPRequestOperation;
@class AFDownloadRequestOperation;

// 常用的网络请求的种类，默认为get请求
typedef NS_ENUM(NSInteger , YTKRequestMethod) {
    YTKRequestMethodGet = 0,
    YTKRequestMethodPost,
    YTKRequestMethodHead,
    YTKRequestMethodPut,
    YTKRequestMethodDelete,
    YTKRequestMethodPatch,
};


typedef NS_ENUM(NSInteger , YTKRequestSerializerType) {
    YTKRequestSerializerTypeHTTP = 0,
    YTKRequestSerializerTypeJSON,
};

// 网络请求的策略 <<---->> 优先级
typedef NS_ENUM(NSInteger , YTKRequestPriority) {
    YTKRequestPriorityLow = -4L,
    YTKRequestPriorityDefault = 0,
    YTKRequestPriorityHigh = 4,
};


// 上传和下载的block
typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^AFDownloadProgressBlock)(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile);

@class YTKBaseRequest;


/**
 *  请求完成的block
 */
typedef void(^YTKRequestCompletionBlock)(__kindof YTKBaseRequest *request);


// 网络请求的协议
@protocol YTKRequestDelegate <NSObject>

@optional
/**
 请求成功，失败，取消请求
 */
- (void)requestFinished:(YTKBaseRequest *)request;
- (void)requestFailed:(YTKBaseRequest *)request;
- (void)clearRequest;

@end

    /**
        用于指示器的插件机制  （*****）
     */
@protocol YTKRequestAccessory <NSObject>

@optional
- (void)requestWillStart:(id)request;
- (void)requestWillStop:(id)request;
- (void)requestDidStop:(id)request;
@end



@interface YTKBaseRequest : NSObject

/// Tag
@property (nonatomic) NSInteger tag;

/// User info
@property (nonatomic, strong, nullable) NSDictionary *userInfo;

// 一个请求对应一个操作
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

/// request delegate object
@property (nonatomic, weak, nullable) id<YTKRequestDelegate> delegate;

/**
 *  网络请求下来的基本上都是只读的
 */
@property (nonatomic, strong, readonly, nullable) NSDictionary *responseHeaders;

@property (nonatomic, strong, readonly, nullable) NSData *responseData;

@property (nonatomic, strong, readonly, nullable) NSString *responseString;

@property (nonatomic, strong, readonly, nullable) id responseJSONObject;

@property (nonatomic, readonly) NSInteger responseStatusCode;  // 网络返回的状态码

@property (nonatomic, strong, readonly, nullable) NSError *requestOperationError; // 请求错误

@property (nonatomic, copy, nullable) YTKRequestCompletionBlock successCompletionBlock; // 成功block

@property (nonatomic, copy, nullable) YTKRequestCompletionBlock failureCompletionBlock;  // 失败block

@property (nonatomic, strong, nullable) NSMutableArray<id<YTKRequestAccessory>> *requestAccessories;  // 用于指示器的插件机制， 每一个网络请求，对应一个指示器的插件机制

/// 请求的优先级, 优先级高的请求会从请求队列中优先出列
@property (nonatomic) YTKRequestPriority requestPriority;

/// Return cancelled state of request operation
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled; // 是否取消请求

/// append self to request queue
- (void)start;

/// remove self from request queue
- (void)stop;

- (BOOL)isExecuting; // 暂停

/// block回调
- (void)startWithCompletionBlockWithSuccess:(nullable YTKRequestCompletionBlock)success
                                    failure:(nullable YTKRequestCompletionBlock)failure;

- (void)setCompletionBlockWithSuccess:(nullable YTKRequestCompletionBlock)success
                              failure:(nullable YTKRequestCompletionBlock)failure;


/// 把block置nil来打破循环引用  （这里有点666）
- (void)clearCompletionBlock;

/// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<YTKRequestAccessory>)accessory;

/// 以下方法由子类继承来覆盖默认值


/// 请求成功的回调 （过滤请求成功的数据）
- (void)requestCompleteFilter;

/// 请求失败的回调
- (void)requestFailedFilter;

/// 请求的URL
- (NSString *)requestUrl;

/// 请求的CdnURL
- (NSString *)cdnUrl;

/// 请求的BaseURL
- (NSString *)baseUrl;

/// 请求的连接超时时间，默认为60秒
- (NSTimeInterval)requestTimeoutInterval;

/// 请求的参数列表
- (nullable id)requestArgument;

/// 用于在cache结果，计算cache文件名时，忽略掉一些指定的参数
- (id)cacheFileNameFilterForRequestArgument:(id)argument;

/// Http请求的方法
- (YTKRequestMethod)requestMethod;

/// 请求的SerializerType
- (YTKRequestSerializerType)requestSerializerType;

/// 请求的Server用户名和密码
- (nullable NSArray *)requestAuthorizationHeaderFieldArray;

/// 在HTTP报头添加的自定义参数
- (nullable NSDictionary *)requestHeaderFieldValueDictionary;




/// 构建自定义的UrlRequest，，  注意这里  如果使用自定义request 很多方法不能使用
/// 若这个方法返回非nil对象，会忽略requestUrl, requestArgument, requestMethod, requestSerializerType
- (nullable NSURLRequest *)buildCustomUrlRequest;

/// 是否使用CDN的host地址
- (BOOL)useCDN;

/// 用于检查JSON是否合法的对象
- (nullable id)jsonValidator;

/// 用于检查Status Code是否正常的方法
- (BOOL)statusCodeValidator;

/// 当POST的内容带有文件等富文本时使用
- (nullable AFConstructingBlock)constructingBodyBlock;

/// 当需要断点续传时，指定续传的地址
- (nullable NSString *)resumableDownloadPath;

/// 当需要断点续传时，获得下载进度的回调
- (nullable AFDownloadProgressBlock)resumableDownloadProgressBlock;

@end

NS_ASSUME_NONNULL_END

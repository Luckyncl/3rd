#import <Foundation/Foundation.h>
#import "SDWebImageCompat.h"
#import "SDWebImageOperation.h"

//图片下载选项
typedef NS_OPTIONS(NSUInteger, SDWebImageDownloaderOptions) {

    //低优先级
    SDWebImageDownloaderLowPriority = 1 << 0,
    //渐进式下载
    SDWebImageDownloaderProgressiveDownload = 1 << 1,


    /*
     默认情况下，请求不使用 NSURLCache。使用此标记，会使用 NSURLCache 和默认缓存策略
     */
    SDWebImageDownloaderUseNSURLCache = 1 << 2,

    /**
     * Call completion block with nil image/imageData if the image was read from NSURLCache
     * (to be combined with `SDWebImageDownloaderUseNSURLCache`).
     */

    /*
     * 如果图像是从 NSURLCache 读取的，则调用 completion block 时，image/imageData 传入 nil
     * (此标记要和 `SDWebImageDownloaderUseNSURLCache` 组合使用)
     */
    SDWebImageDownloaderIgnoreCachedResponse = 1 << 3,
    /*
     * 在 iOS 4+，当 App 进入后台后仍然会继续下载图像。这是向系统请求额外的后台时间以保证下载请求完成的
     * 如果后台任务过期，请求将会被取消
     */
    SDWebImageDownloaderContinueInBackground = 1 << 4,

    /*
     *  处理保存在 NSHTTPCookieStore 中的 cookies
     */
    SDWebImageDownloaderHandleCookies = 1 << 5,

    /*
     * 允许不信任的 SSL 证书
     * 可以出于测试目的使用，在正式产品中慎用
     */
    SDWebImageDownloaderAllowInvalidSSLCertificates = 1 << 6,

    /*
     *  将图像放入高优先级队列
     */
    SDWebImageDownloaderHighPriority = 1 << 7,
};

//下载操作的执行方式

/**
 *   队列是先进先出，， 堆栈是后进先出
 */
typedef NS_ENUM(NSInteger, SDWebImageDownloaderExecutionOrder) {

    /* *  默认值，所有下载操作将按照队列的先进先出方式执行 */
    SDWebImageDownloaderFIFOExecutionOrder,

    /* *  所有下载操作将按照堆栈的后进先出方式执行 */
    SDWebImageDownloaderLIFOExecutionOrder
};

//供其他文件使用的的全局变量
extern NSString *const SDWebImageDownloadStartNotification; //开始下载通知
extern NSString *const SDWebImageDownloadStopNotification;  //停止下载通知

//定义下载进度回调， 收到的数据大小 ， 期望的数据大小
typedef void(^SDWebImageDownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

//定义下载完成回调，  下载完成 可以拿到转化完成的 image，以及二进制文件， 是否发生错误， 以及是否完成
//   ******  注意： 下载完成的回调，并不一定是下载成功了，他对应的是一个下载完成的状态
typedef void(^SDWebImageDownloaderCompletedBlock)(UIImage *image, NSData *data, NSError *error, BOOL finished);


//定义'头部过滤'回调，有返回值（字典）, 截取url的地址，并返回
typedef NSDictionary *(^SDWebImageDownloaderHeadersFilterBlock)(NSURL *url, NSDictionary *headers);




//专为加载图像设计并优化的异步下载器
@interface SDWebImageDownloader : NSObject

/**
 * 是否解码，如果设置为YES，那么下载和缓存的图像可以提高性能，但会消耗大量的内存。
 * 默认值为YES。如果你需要考虑内存问题，那么请设置为NO
 * SDWebImage框架通过这种方式 以牺牲内存存储空间来换取性能
 */
@property (assign, nonatomic) BOOL shouldDecompressImages;

//设置并发下载数，默认为6
@property (assign, nonatomic) NSInteger maxConcurrentDownloads;


//显示当前仍需要下载的数量
@property (readonly, nonatomic) NSUInteger currentDownloadCount;


//下载操作的超时时长(秒)，默认：15秒
@property (assign, nonatomic) NSTimeInterval downloadTimeout;



/**/
//通过该属性，可以修改下载操作执行顺序，默认值是 `SDWebImageDownloaderFIFOExecutionOrder`，即先进先出
@property (assign, nonatomic) SDWebImageDownloaderExecutionOrder executionOrder;


//单例方法，返回一个全局共享的下载器
+ (SDWebImageDownloader *)sharedDownloader;


//设置默认的URL身份认证信息
@property (strong, nonatomic) NSURLCredential *urlCredential;


//设置用户名
@property (strong, nonatomic) NSString *username;


//设置密码
@property (strong, nonatomic) NSString *password;


/*
 * 设置下载图像 HTTP 请求头过滤器
 * 此 block 将被每一个下载图像的请求调用，返回的 NSDictionary 将被作为相应的 HTTP 请求头
 */
@property (nonatomic, copy) SDWebImageDownloaderHeadersFilterBlock headersFilter;


/*
 * 为 HTTP 请求头设置一个值
 * value 请求头字段的值，使用 `nil` 删除该字段
 * field 要设置的请求头字段名
 */
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;


/*
 * 返回指定 HTTP 请求头字段的值
 * 返回值为请求头字段的值，如果没有返回 `nil`
 */
- (NSString *)valueForHTTPHeaderField:(NSString *)field;


/*
 * 设置 SDWebImage 每次构造下载图像请求操作的 `SDWebImageDownloaderOperation` 的子类
 * 默认操作的 `SDWebImageDownloaderOperation` 的子类，传入 `nil` 将恢复为
 */
- (void)setOperationClass:(Class)operationClass;


/*
 * 使用给定的 URL 创建 SDWebImageDownloader 异步下载器实例
 * 图像下载完成或者出现错误时会通知代理
 * url:要下载的图像 URL
 * SDWebImageDownloaderOptions：下载选项|策略
 * progressBlock：图像下载过程中被重复调用的 block，用来报告下载进度
 * completedBlock：图像下载完成后被调用一次的 block
 *      image:如果下载成功，image 参数会被设置
 *      error:如果出现错误，error 参数会被设置
 *      finished:
 
   如果没有使用 SDWebImageDownloaderProgressiveDownload（渐进式下载)，最后一个参数一直是 YES
 *          如果使用了 SDWebImageDownloaderProgressiveDownload 选项，此 block 会被重复调用
 *              1)下载完成前，image 参数是部分图像，finished 参数是 NO
 *              2)最后一次被调用时，image 参数是完整图像，而 finished 参数是 YES
 *              3)如果出现错误，那么finished 参数也是 YES
 *  返回值：可被取消的 SDWebImageOperation
 */
- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url
                                         options:(SDWebImageDownloaderOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(SDWebImageDownloaderCompletedBlock)completedBlock;

/*
 * 设置下载队列挂起状态
 */
- (void)setSuspended:(BOOL)suspended;

/**
 * 取消队列中所有的下载任务
 */
- (void)cancelAllDownloads;

@end

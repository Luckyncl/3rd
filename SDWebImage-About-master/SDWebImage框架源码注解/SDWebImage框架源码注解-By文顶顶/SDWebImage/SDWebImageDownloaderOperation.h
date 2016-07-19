/*
    下载线程
 */

#import <Foundation/Foundation.h>
#import "SDWebImageDownloader.h"
#import "SDWebImageOperation.h"

//使用extern关键字标识 使用SDWebImageDownloadStartNotification等全局变量
extern NSString *const SDWebImageDownloadStartNotification;               // 下载开始的通知
extern NSString *const SDWebImageDownloadReceiveResponseNotification;     // 下载收到内容的通知
extern NSString *const SDWebImageDownloadStopNotification;                // 下载停止的通知
extern NSString *const SDWebImageDownloadFinishNotification;              // 下载完成的通知



//SDWebImageDownloaderOperation   遵循SDWebImageOperation 协议  编写取消线程的方法
@interface SDWebImageDownloaderOperation : NSOperation <SDWebImageOperation, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>


/**
 * 请求对象
 */
@property (strong, nonatomic, readonly) NSURLRequest *request;

/**
 * 请求任务
 */
@property (strong, nonatomic, readonly) NSURLSessionTask *dataTask;


//图片是否需要进行解码操作
@property (assign, nonatomic) BOOL shouldDecompressImages;

/**
     请求认证
 */
@property (nonatomic, assign) BOOL shouldUseCredentialStorage __deprecated_msg("Property deprecated. Does nothing. Kept only for backwards compatibility");

/**
 * 方法中身份验证使用的凭据
 * 如果存在请求 URL 的用户名或密码的共享凭据，此凭据会被覆盖
 */
@property (nonatomic, strong) NSURLCredential *credential;

/**
 * 下载时的选项枚举
 */
@property (assign, nonatomic, readonly) SDWebImageDownloaderOptions options;

/**
 *
 * 请求数据的期望大小（图片的大小）
 */
@property (assign, nonatomic) NSInteger expectedSize;

/**
 * 网络请求的响应头信息
 */
@property (strong, nonatomic) NSURLResponse *response;

/**
 *  初始化一个 `SDWebImageDownloaderOperation` 对象
 *
 *  @param request        请求对象
 *  @param session           会话对象
 *  @param options             下载选项
 *  @param progressBlock          下载进度回调
 *  @param completedBlock            完成的回调
 *   1）下载结束后执行的 block
 *   2）注意：如果下载成功，completion block 在主队列执行。如果出现错误，block 可能会在后台队列执行
 *
 *  @param cancelBlock                    如果下载(操作)被取消，执行的 block
 */
- (id)initWithRequest:(NSURLRequest *)request
            inSession:(NSURLSession *)session
              options:(SDWebImageDownloaderOptions)options
             progress:(SDWebImageDownloaderProgressBlock)progressBlock
            completed:(SDWebImageDownloaderCompletedBlock)completedBlock
            cancelled:(SDWebImageNoParamsBlock)cancelBlock;

@end

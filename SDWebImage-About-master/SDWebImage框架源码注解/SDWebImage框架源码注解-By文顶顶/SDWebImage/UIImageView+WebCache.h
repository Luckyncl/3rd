#import "SDWebImageCompat.h"
#import "SDWebImageManager.h"

@interface UIImageView (WebCache)

/**
 * Get the current image URL.
 *
 * Note that because of the limitations of categories this property can get out of sync
 * if you use sd_setImage: directly.
 *
 * 获得当前图片的URL
 */
- (NSURL *)sd_imageURL;

/**
 *
 * 根据图片的url下载图片并设置到ImageView上面去
 * 异步下载并缓存。
 * @param url 图片的URL
 */
- (void)sd_setImageWithURL:(NSURL *)url;

/**
 * Set the imageView `image` with an `url` and a placeholder.
 *
 * The download is asynchronous and cached.
 *
 * @param url         The url for the image.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @see sd_setImageWithURL:placeholderImage:options:
 *
 * 根据图片的url下载图片并设置到ImageView上面去,并设置占位图片
 * @param url 图片的URL
 * @param placeholder 显示在UIImageView上面的占位图片，直到图片下载完成
 * @see 参考sd_setImageWithURL:placeholderImage:options:方法
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

/**
 * Set the imageView `image` with an `url`, placeholder and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url         The url for the image.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @param options     The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 *
 * 根据图片的url下载图片并设置到ImageView上面去,并设置占位图片，自定义下载选项
 * @param url           图片的URL
 * @param placeholder   显示在UIImageView上面的占位图片，直到图片下载完成
 * @param options       下载图片的选项。参考SDWebImageOptions的枚举值
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;

/**
  *
 * 根据图片的url下载图片并设置到ImageView上面去
 * 异步下载并缓存
 *
 * @param url            图片的URL
 * @param completedBlock 当操作执行完毕之后的回调。该回调没有返回值
 *      第一个参数为请求的图片
 *      第二个参数是NSError类型的，如果图片下载成功则error为nil,否则error有值
 *      第三个参数是图片缓存的使用情况（内存缓存|沙盒缓存|直接下载）
 *      第四个参数是图片的URL地址
 */
- (void)sd_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `image` with an `url`, placeholder.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 *
 * 根据图片的url下载图片并设置到ImageView上面去，占位图片
 * 异步下载并缓存
 *
 * @param url            图片的URL
 * @param placeholder   显示在UIImageView上面的占位图片，直到图片下载完成
 * @param completedBlock 当操作执行完毕之后的回调。该回调没有返回值
 *      第一个参数为请求的图片
 *      第二个参数是NSError类型的，如果图片下载成功则error为nil,否则error有值
 *      第三个参数是图片缓存的使用情况（内存缓存|沙盒缓存|直接下载）
 *      第四个参数是图片的URL地址
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `image` with an `url`, placeholder and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param options        The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 *
 * 根据图片的url下载图片并设置到ImageView上面去，占位图片
 * 异步下载并缓存
 *
 * @param url            图片的URL
 * @param placeholder   显示在UIImageView上面的占位图片，直到图片下载完成
 * @param options       下载图片的选项。参考SDWebImageOptions的枚举值
 * @param completedBlock 当操作执行完毕之后的回调。该回调没有返回值
 *      第一个参数为请求的图片
 *      第二个参数是NSError类型的，如果图片下载成功则error为nil,否则error有值
 *      第三个参数是图片缓存的使用情况（内存缓存|沙盒缓存|直接下载）
 *      第四个参数是图片的URL地址
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `image` with an `url`, placeholder and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param options        The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 * @param progressBlock  A block called while image is downloading
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 *
 * 根据图片的url下载图片并设置到ImageView上面去，占位图片
 * 异步下载并缓存
 *
 * @param url            图片的URL
 * @param placeholder    显示在UIImageView上面的占位图片，直到图片下载完成
 * @param options        下载图片的选项。参考SDWebImageOptions的枚举值
 * @param progressBlock  下载的进度回调
 * @param completedBlock 当操作执行完毕之后的回调。该回调没有返回值
 *      第一个参数为请求的图片
 *      第二个参数是NSError类型的，如果图片下载成功则error为nil,否则error有值
 *      第三个参数是图片缓存的使用情况（内存缓存|沙盒缓存|直接下载）
 *      第四个参数是图片的URL地址
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `image` with an `url` and optionally a placeholder image.
 *
 * 异步下载，并且缓存
 *
 * @param url            图片地址
 * @param placeholder    占位图
 * @param options        图片下载选项
 * @param progressBlock  下载进度block
 * @param completedBlock  下载完成的block，没有返回值
 */
- (void)sd_setImageWithPreviousCachedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;


/**
 *   下载链接的地址
 *
 * @param arrayOfURLs An array of NSURL
 */
- (void)sd_setAnimationImagesWithURLs:(NSArray *)arrayOfURLs;

/**
 *  取消当前的下载任务
 */
- (void)sd_cancelCurrentImageLoad;

// 取消
- (void)sd_cancelCurrentAnimationImagesLoad;

/**
 *  是否显示指示器
 */
- (void)setShowActivityIndicatorView:(BOOL)show;

/**
 * 设置指示器的风格
 */
- (void)setIndicatorStyle:(UIActivityIndicatorViewStyle)style;

@end




#import <Foundation/Foundation.h>
#import "SDWebImageCompat.h"

/**
 *  图片解压缩分类
 */
@interface UIImage (ForceDecode)

//图片解压缩处理通用思路：是在子线程，将原始的图片渲染成一张的新的可以字节显示的图片，来获取一个解压缩过的图片。

//图片的解压缩以前（会导致内存暴增？还未验证）
+ (UIImage *)decodedImageWithImage:(UIImage *)image;

@end

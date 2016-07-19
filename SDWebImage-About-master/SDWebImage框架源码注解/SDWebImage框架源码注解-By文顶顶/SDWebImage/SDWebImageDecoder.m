
#import "SDWebImageDecoder.h"

@implementation UIImage (ForceDecode)


// 图片解码
/**
 *  解压缩图片

 
        其实就是用了  图片转换
 */
+ (UIImage *)decodedImageWithImage:(UIImage *)image {

    // 在iOS7中，别忘了调用[[SDImageCache sharedImageCache] clearMemory]方法

    //如果image 为nil,则直接返回nil
    if (image == nil) { // Prevent "CGBitmapContextCreateImage: invalid context 0x0" error
        return nil;
    }
    
    @autoreleasepool{
        // do not decode animated images
         //不要解码动画图像,直接返回 （动画图像）
        if (image.images != nil) {
            return image;
        }

        //CGImageRef是定义在QuartzCore框架中的一个结构体指针，用C语言编写。其定义在CGImage.h
        //这个结构用来创建像素位图，可以通过操作存储的像素位来编辑图片
        CGImageRef imageRef = image.CGImage;

         //获得图片的透明度信息
        CGImageAlphaInfo alpha = CGImageGetAlphaInfo(imageRef);
        BOOL anyAlpha = (alpha == kCGImageAlphaFirst ||
                         alpha == kCGImageAlphaLast ||
                         alpha == kCGImageAlphaPremultipliedFirst ||
                         alpha == kCGImageAlphaPremultipliedLast);

        //如果anyAlpha有值，则直接返回image
        if (anyAlpha) {
            return image;
        }
        
        // current
        //获得颜色的RGB数值
        CGColorSpaceModel imageColorSpaceModel = CGColorSpaceGetModel(CGImageGetColorSpace(imageRef));
        CGColorSpaceRef colorspaceRef = CGImageGetColorSpace(imageRef);  // 位图
        
        BOOL unsupportedColorSpace = (imageColorSpaceModel == kCGColorSpaceModelUnknown ||
                                      imageColorSpaceModel == kCGColorSpaceModelMonochrome ||
                                      imageColorSpaceModel == kCGColorSpaceModelCMYK ||
                                      imageColorSpaceModel == kCGColorSpaceModelIndexed);
        if (unsupportedColorSpace) {
            colorspaceRef = CGColorSpaceCreateDeviceRGB();
        }

        //获取宽度像素
        size_t width = CGImageGetWidth(imageRef);
         //获取高度像素
        size_t height = CGImageGetHeight(imageRef);
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * width; //以前的版本中该值直接设置为0
        NSUInteger bitsPerComponent = 8; //以前使用 CGImageGetBitsPerComponent(imageRef)方法获取


        //创建位图上下文
        /*
         第一个参数data：指向要渲染的绘制内存的地址。这个内存块的大小至少是（bytesPerRow*height）个字节
         第二个参数width：bitmap的宽度,单位为像素
         第三个参数height：bitmap的高度,单位为像素
         第四个参数bitsPerComponent：内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8
         第五个参数bytesPerRow：bitmap的每一行在内存所占的比特数
         第六个参数space：bitmap上下文使用的颜色空间
         第七个参数bitmapInfo：指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串
         */
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     width,
                                                     height,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorspaceRef,
                                                     kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipLast);
        
        // Draw the image into the context and retrieve the new bitmap image without alpha
        //绘图（上下文，rect和imageRef）
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGImageRef imageRefWithoutAlpha = CGBitmapContextCreateImage(context);

        
        //该方法使用一个CGImageRef创建UIImage,指定缩放的倍数和旋转的方向
        //当scale为1的时候，表示新创建的图像将和原图像尺寸一摸一样
        //orientation指定图像的绘制方向
        UIImage *imageWithoutAlpha = [UIImage imageWithCGImage:imageRefWithoutAlpha
                                                         scale:image.scale
                                                   orientation:image.imageOrientation];
         //release对象
        if (unsupportedColorSpace) {
            CGColorSpaceRelease(colorspaceRef);
        }
        
        CGContextRelease(context);
        CGImageRelease(imageRefWithoutAlpha);
        
        return imageWithoutAlpha;
    }
}

@end

//
// Created by Fabrice Aneche on 06/01/14.
// Copyright (c) 2014 Dailymotion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (ImageContentType)

/**
 *
 * 根据图像的二进制数据判断图片的类型
 *
 * @param  data 传入的二进制数据
 * @return 图片类型的字符串（如：image/jpeg,image/gif）
 */
+ (NSString *)sd_contentTypeForImageData:(NSData *)data;

@end


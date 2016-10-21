//
//  UploadImageApi.h
//  Solar
//
//  Created by tangqiao on 8/7/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import "YTKRequest.h"
#import <UIKit/UIKit.h>

// 上传图片

@interface UploadImageApi : YTKRequest

- (id)initWithImage:(UIImage *)image;

- (NSString *)responseImageId;

@end

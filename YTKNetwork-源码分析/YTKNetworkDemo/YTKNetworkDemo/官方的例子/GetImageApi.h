//
//  GetImageApi.h
//  YTKNetworkDemo
//
//  Created by TangQiao on 11/8/14.
//  Copyright (c) 2014 yuantiku.com. All rights reserved.
//

#import "YTKRequest.h"

@interface GetImageApi : YTKRequest

- (id)initWithImageId:(NSString *)imageId;


// 如果需要使用cdn的话，只需要重写usecdn这个方法即可

@end

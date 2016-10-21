//
//  GetUserInfoApi.h
//  YTKNetworkDemo
//
//  Created by TangQiao on 11/8/14.
//  Copyright (c) 2014 yuantiku.com. All rights reserved.
//

#import "YTKRequest.h"


// 用来说明 1、验证服务器返回值得功能
//          2、使用缓存策略
@interface GetUserInfoApi : YTKRequest

- (id)initWithUserId:(NSString *)userId;

@end

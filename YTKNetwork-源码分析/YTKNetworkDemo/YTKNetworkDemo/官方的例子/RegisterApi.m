//
//  RegisterApi.m
//  Solar
//
//  Created by TangQiao on 11/8/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import "RegisterApi.h"

@implementation RegisterApi
{
    NSString *_username;
    NSString *_password;
}

- (id)initWithUsername:(NSString *)username password:(NSString *)password {
    self = [super init];
    if (self) {
        _username = username;
        _password = password;
    }
    return self;
}


// 注意这里是使用继承的关系来做的

/**
 *  重写父类方法
 */
- (NSString *)requestUrl {
    return @"/iphone/register";
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPost;
}

// 设置请求参数
- (id)requestArgument {
    return @{
        @"username": _username,
        @"password": _password
    };
}


//  用于检测json数据是否合法
- (id)jsonValidator {
    return @{
        @"userId": [NSNumber class],
        @"nick": [NSString class],
        @"level": [NSNumber class]
    };
}

// 从注册方法里面取得userid
- (NSString *)userId {
    return [[[self responseJSONObject] objectForKey:@"userId"] stringValue];
}

@end

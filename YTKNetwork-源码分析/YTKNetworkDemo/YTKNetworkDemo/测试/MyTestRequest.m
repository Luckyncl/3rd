//
//  MyTestRequest.m
//  YTKNetworkDemo
//
//  Created by Apple on 16/8/25.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import "MyTestRequest.h"

@implementation MyTestRequest

/**
 *  重写父类方法
 */
- (NSString *)requestUrl {
    return @"/app/index.php?action=carousel";
}
//
//- (YTKRequestMethod)requestMethod {
//    return YTKRequestMethodGet;
//}



////  用于检测json数据是否合法
//- (id)jsonValidator {
//    return @{
//             @"userId": [NSNumber class],
//             @"nick": [NSString class],
//             @"level": [NSNumber class]
//             };
//}



@end

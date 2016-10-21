

#import "GetUserInfoApi.h"

@implementation GetUserInfoApi
{
    NSString *_userId;
}

- (id)initWithUserId:(NSString *)userId {
    self = [super init];
    if (self) {
        _userId = userId;
    }
    return self;
}

- (NSString *)requestUrl {
    return @"/iphone/users";
}

- (id)requestArgument {
    return @{ @"id": _userId };
}


// 用于验证josn数据是否符合接口数据的格式要求
- (id)jsonValidator {
    return @{
        @"nick": [NSString class],
        @"level": [NSNumber class]
    };
}



//```
//- (id)jsonValidator {
//    return @[@{
//                 @"id": [NSNumber class],
//                 @"imageId": [NSString class],
//                 @"time": [NSNumber class],
//                 @"status": [NSNumber class],
//                 @"question": @{
//                         @"id": [NSNumber class],
//                         @"content": [NSString class],
//                         @"contentType": [NSNumber class]
//                         }
//                 }];
//} 
//```



- (NSInteger)cacheTimeInSeconds {
    return 60 * 3;
}

@end

//
//  MJPropertyType.m
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "MJPropertyType.h"
#import "MJExtension.h"
#import "MJFoundation.h"
#import "MJExtensionConst.h"

@implementation MJPropertyType

static NSMutableDictionary *types_;


+ (void)initialize
{
    types_ = [NSMutableDictionary dictionary];
}


    //  
+ (instancetype)cachedTypeWithCode:(NSString *)code
{
    MJExtensionAssertParamNotNil2(code, nil);
    @synchronized (self) {
        MJPropertyType *type = types_[code];
        if (type == nil) {
            type = [[self alloc] init];
            type.code = code;
            types_[code] = type;
        }
        return type;
    }
}




#pragma mark - 公共方法

//  重写 setter 方法 设置code
- (void)setCode:(NSString *)code
{
    _code = code;
    
    //    判断是不是为空 ，为空就直接返回
    MJExtensionAssertParamNotNil(code);  // 使用断言进行判断
    
    if ([code isEqualToString:MJPropertyTypeId]) {
        _idType = YES;
    } else if (code.length == 0) {
        _KVCDisabled = YES;                                // 类型标识符的长度 如果为0 的话， 就不支持 kvc
    } else if (code.length > 3 && [code hasPrefix:@"@\""]) {
        // 去掉@"和"，截取中间的类型名称
        _code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _typeClass = NSClassFromString(_code);
        _fromFoundation = [MJFoundation isClassFromFoundation:_typeClass];
        _numberType = [_typeClass isSubclassOfClass:[NSNumber class]];
        
    } else if ([code isEqualToString:MJPropertyTypeSEL] ||
               [code isEqualToString:MJPropertyTypeIvar] ||
               [code isEqualToString:MJPropertyTypeMethod]) {
        _KVCDisabled = YES;                                    //  如果不是foundation的类型的haunted，也不支持 kvc
    }
    
    
    
    // 是否为数字类型
    NSString *lowerCode = _code.lowercaseString;                // 转成小写字母
    NSArray *numberTypes = @[MJPropertyTypeInt, MJPropertyTypeShort, MJPropertyTypeBOOL1, MJPropertyTypeBOOL2, MJPropertyTypeFloat, MJPropertyTypeDouble, MJPropertyTypeLong, MJPropertyTypeLongLong, MJPropertyTypeChar];
    if ([numberTypes containsObject:lowerCode]) {
        _numberType = YES;
        
        if ([lowerCode isEqualToString:MJPropertyTypeBOOL1]
            || [lowerCode isEqualToString:MJPropertyTypeBOOL2]) {
            _boolType = YES;
        }
    }
}
@end

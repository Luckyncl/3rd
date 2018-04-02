
#ifndef __MJExtensionConst__H__
#define __MJExtensionConst__H__

#import <Foundation/Foundation.h>


// 各种宏定义


// 过期
#define MJExtensionDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

// 构建错误
#define MJExtensionBuildError(clazz, msg) \
NSError *error = [NSError errorWithDomain:msg code:250 userInfo:nil]; \
[clazz setMj_error:error];

// 日志输出
#ifdef DEBUG
#define MJExtensionLog(...) NSLog(__VA_ARGS__)
#else
#define MJExtensionLog(...)
#endif


/**
 * 断言  使用断言
 * @param condition   条件
 * @param returnValue 返回值
 */
#define MJExtensionAssertError(condition, returnValue, clazz, msg) \
[clazz setMj_error:nil]; \
if ((condition) == NO) { \
    MJExtensionBuildError(clazz, msg); \
    return returnValue;\
}

#define MJExtensionAssert2(condition, returnValue) \
if ((condition) == NO) return returnValue;

/**
 * 断言
 * @param condition   条件
 */
#define MJExtensionAssert(condition) MJExtensionAssert2(condition, )

/**
 * 断言
 * @param param         参数
 * @param returnValue   返回值
 */
#define MJExtensionAssertParamNotNil2(param, returnValue) \
MJExtensionAssert2((param) != nil, returnValue)

/**
 * 断言
 * @param param   参数   如果为空就返回
 */
#define MJExtensionAssertParamNotNil(param) MJExtensionAssertParamNotNil2(param, )



/**
 * 打印所有的属性  的宏定义
 */
#define MJLogAllIvars \
-(NSString *)description \
{ \
    return [self mj_keyValues].description; \
}
#define MJExtensionLogAllProperties MJLogAllIvars



/**
 *  类型（属性类型） 属性的各种类型
 */
extern NSString *const MJPropertyTypeInt;
extern NSString *const MJPropertyTypeShort;
extern NSString *const MJPropertyTypeFloat;
extern NSString *const MJPropertyTypeDouble;
extern NSString *const MJPropertyTypeLong;
extern NSString *const MJPropertyTypeLongLong;
extern NSString *const MJPropertyTypeChar;
extern NSString *const MJPropertyTypeBOOL1;
extern NSString *const MJPropertyTypeBOOL2;
extern NSString *const MJPropertyTypePointer;

extern NSString *const MJPropertyTypeIvar;     //  成员变量
extern NSString *const MJPropertyTypeMethod;   // 方法
extern NSString *const MJPropertyTypeBlock;    // block 属性
extern NSString *const MJPropertyTypeClass;    // 类
extern NSString *const MJPropertyTypeSEL;      // 方法
extern NSString *const MJPropertyTypeId;       // id 属性

#endif

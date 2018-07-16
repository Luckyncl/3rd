#ifndef __MJExtensionConst__M__
#define __MJExtensionConst__M__

#import <Foundation/Foundation.h>

/**
 *  成员变量类型（属性类型）
 */
NSString *const MJPropertyTypeInt = @"i";
NSString *const MJPropertyTypeShort = @"s";
NSString *const MJPropertyTypeFloat = @"f";
NSString *const MJPropertyTypeDouble = @"d";
NSString *const MJPropertyTypeLong = @"l";
NSString *const MJPropertyTypeLongLong = @"q";
NSString *const MJPropertyTypeChar = @"c";               // 字符类型
NSString *const MJPropertyTypeBOOL1 = @"c";              // 字符类型的bool
NSString *const MJPropertyTypeBOOL2 = @"b";              // 数字类型
NSString *const MJPropertyTypePointer = @"*";            // 指针类型属性






    //typedef struct objc_ivar *Ivar;
    //
    //struct objc_ivar {
    //    char *ivar_name                 OBJC2_UNAVAILABLE;  // 变量名
    //    char *ivar_type                 OBJC2_UNAVAILABLE;  // 变量类型
    //    int ivar_offset                 OBJC2_UNAVAILABLE;  // 基地址偏移字节
    //#ifdef __LP64__
    //    int space                       OBJC2_UNAVAILABLE;
    //#endif
    //}

NSString *const MJPropertyTypeIvar = @"^{objc_ivar=}";    // 实例变量


    //typedef struct objc_method *Method;
    //
    //struct objc_method {
    //    SEL method_name;        // 方法名称
    //    charchar *method_typesE;    // 参数和返回类型的描述字串
    //    IMP method_imp;         // 方法的具体的实现的指针
    //}
NSString *const MJPropertyTypeMethod = @"^{objc_method=}";


NSString *const MJPropertyTypeBlock = @"@?";
NSString *const MJPropertyTypeClass = @"#";
NSString *const MJPropertyTypeSEL = @":";
NSString *const MJPropertyTypeId = @"@";          // id 属性

#endif

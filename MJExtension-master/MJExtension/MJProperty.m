//
//  MJProperty.m
//  MJExtensionExample
//
//
//     
//

#import "MJProperty.h"
#import "MJFoundation.h"
#import "MJExtensionConst.h"
#import <objc/message.h>

@interface MJProperty()

@property (strong, nonatomic) NSMutableDictionary *propertyKeysDict;         //
@property (strong, nonatomic) NSMutableDictionary *objectClassInArrayDict;   //

@end

@implementation MJProperty

#pragma mark - 初始化
- (instancetype)init
{
    if (self = [super init]) {
        _propertyKeysDict = [NSMutableDictionary dictionary];
        _objectClassInArrayDict = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - 缓存  

// 注意这里，如果第一次没有设置关联的话，执行起来 就是设置关联。返回值 是 nil
+ (instancetype)cachedPropertyWithProperty:(objc_property_t)property
{
    
//    OBJC_EXPORT id objc_getAssociatedObject(id object, const void *key)
//    首先获取，然后 为空的话，再设置关联属性
    MJProperty *propertyObj = objc_getAssociatedObject(self, property);
    if (propertyObj == nil) {
        propertyObj = [[self alloc] init];
        propertyObj.property = property;
//  void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)
        objc_setAssociatedObject(self, property, propertyObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return propertyObj;
}

#pragma mark - 公共方法
- (void)setProperty:(objc_property_t)property
{
    _property = property;
    
    MJExtensionAssertParamNotNil(property);
    
    // 1.属性名
    _name = @(property_getName(property));
    
    // 2.成员类型
    /**
    
     当编译器遇到属性声明时，它会生成一些可描述的元数据（metadata），将其与相应的类、category和协议关联起来。存在一些函数可以通过名称在类或者协议中查找这些metadata，通过这些函数，我们可以获得编码后的属性类型（字符串），复制属性的attribute列表（C字符串数组）。因此，每个类和协议的属性列表我们都可以获得。
     
     与类型编码类似，属性类型也有相应的编码方案，比如readonly编码为R，copy编码为C，retain编码为&等。
     
     通过property_getAttributes函数可以后去编码后的字符串，该字符串以T开头，紧接@encode type和逗号，接着以V和变量名结尾。比如：
     
     @property char charDefault;
     
     描述为：Tc,VcharDefault
     
     而@property(retain)ididRetain;
     
     描述为：T@,&,VidRetain
     */

    NSString *attrs = @(property_getAttributes(property));
    //    property_getAttributes
    
    NSUInteger dotLoc = [attrs rangeOfString:@","].location;
    NSString *code = nil;
    NSUInteger loc = 1;
    if (dotLoc == NSNotFound) { // 没有,
        code = [attrs substringFromIndex:loc];
    } else {
        code = [attrs substringWithRange:NSMakeRange(loc, dotLoc - loc)];
    }
    
    //     得到 value 是什么类型的 数据
    _type = [MJPropertyType cachedTypeWithCode:code];
}

/**
 *  获得成员变量的值
 */
- (id)valueForObject:(id)object
{
    //   如果 kvc 不能使用的话， 返回nsnull
    if (self.type.KVCDisabled) return [NSNull null];
    //   否则，就获取响应的 value
    return [object valueForKey:self.name];
}

/**
 *  设置成员变量的值
 */
- (void)setValue:(id)value forObject:(id)object
{
    if (self.type.KVCDisabled || value == nil) return;
    [object setValue:value forKey:self.name];
}

/**
 *  通过字符串key创建对应的keys          **********
 */
- (NSArray *)propertyKeysWithStringKey:(NSString *)stringKey
{
    if (stringKey.length == 0) return nil;
    
    NSMutableArray *propertyKeys = [NSMutableArray array];
    // 如果有多级映射
    NSArray *oldKeys = [stringKey componentsSeparatedByString:@"."];  // 这里 是针对 多级映射的时候， eg： model.name
    
    for (NSString *oldKey in oldKeys) {
        NSUInteger start = [oldKey rangeOfString:@"["].location;
        if (start != NSNotFound) { // 有索引的key    也就是有  [  这个符号
            NSString *prefixKey = [oldKey substringToIndex:start];
            NSString *indexKey = prefixKey;
            if (prefixKey.length) {
                MJPropertyKey *propertyKey = [[MJPropertyKey alloc] init];
                propertyKey.name = prefixKey;
                [propertyKeys addObject:propertyKey];
                
                indexKey = [oldKey stringByReplacingOccurrencesOfString:prefixKey withString:@""];
            }
            
            /** 解析索引 **/
            // 元素
            NSArray *cmps = [[indexKey stringByReplacingOccurrencesOfString:@"[" withString:@""] componentsSeparatedByString:@"]"];
            for (NSInteger i = 0; i<cmps.count - 1; i++) {
                MJPropertyKey *subPropertyKey = [[MJPropertyKey alloc] init];
                subPropertyKey.type = MJPropertyKeyTypeArray;
                subPropertyKey.name = cmps[i];
                [propertyKeys addObject:subPropertyKey];
            }
        } else { // 没有索引的key
            MJPropertyKey *propertyKey = [[MJPropertyKey alloc] init];
            propertyKey.name = oldKey;
            [propertyKeys addObject:propertyKey];
        }
    }
    
    return propertyKeys;
}



/** 对应着字典中的key */
- (void)setOriginKey:(id)originKey forClass:(Class)c
{
    if ([originKey isKindOfClass:[NSString class]]) { // 字符串类型的key
        NSArray *propertyKeys = [self propertyKeysWithStringKey:originKey];
        if (propertyKeys.count) {
            [self setPorpertyKeys:@[propertyKeys] forClass:c];
        }
        
        
    } else if ([originKey isKindOfClass:[NSArray class]]) {   // 数组类型的key  这种情况是处理的是 json数据中 value对应的是 模型数组的情况
        NSMutableArray *keyses = [NSMutableArray array];
        
        //   这里  有点递归 的感觉了
        for (NSString *stringKey in originKey) {
            NSArray *propertyKeys = [self propertyKeysWithStringKey:stringKey];
            if (propertyKeys.count) {
                [keyses addObject:propertyKeys];
            }
        }
        if (keyses.count) {
            [self setPorpertyKeys:keyses forClass:c];
        }
    }
}

/** 对应着字典中的多级key */
- (void)setPorpertyKeys:(NSArray *)propertyKeys forClass:(Class)c
{
    if (propertyKeys.count == 0) return;
    
    //   在这里保存下来了
    self.propertyKeysDict[NSStringFromClass(c)] = propertyKeys;
}

// getter 方法  获取  某个类的 所有key
- (NSArray *)propertyKeysForClass:(Class)c
{
    return self.propertyKeysDict[NSStringFromClass(c)];
}





/** 模型数组中的模型类型 */
- (void)setObjectClassInArray:(Class)objectClass forClass:(Class)c
{
    if (!objectClass) return;
    self.objectClassInArrayDict[NSStringFromClass(c)] = objectClass;
}
- (Class)objectClassInArrayForClass:(Class)c
{
    return self.objectClassInArrayDict[NSStringFromClass(c)];
}
@end

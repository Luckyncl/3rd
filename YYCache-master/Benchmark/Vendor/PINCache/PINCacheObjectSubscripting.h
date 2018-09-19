//
//  PINCacheObjectSubscripting.h
//  PINCache
//
//  Created by Rocir Marcos Leite Santiago on 4/2/16.
//  Copyright © 2016 Pinterest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PINCacheObjectSubscripting <NSObject>

@required

/**
 This method enables using literals on the receiving object, such as `id object = cache[@"key"];`.
        此方法允许在接收对象上使用字面量，例如`id object = cache [@“key”];
 
 @param key The key associated with the object.
 @result The object for the specified key.
 
 */
- (nullable id)objectForKeyedSubscript:(NSString *)key;


/**
 This method enables using literals on the receiving object, such as `cache[@"key"] = object;`.
    像字典一样使用 字面量语法来 设置value的值
 @param object An object to be assigned for the key. Pass `nil` to remove the existing object for this key.
 @param key A key to associate with the object. This string will be copied.
 */
- (void)setObject:(nullable id)object forKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

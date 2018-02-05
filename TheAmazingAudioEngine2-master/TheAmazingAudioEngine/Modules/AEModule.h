//
//  AEModule.h
//  TheAmazingAudioEngine
//
//  Created by Michael Tyson on 23/03/2016.
//  Copyright © 2016 A Tasty Pixel. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#ifdef __cplusplus
extern "C" {
#endif

#import <Foundation/Foundation.h>
#import "AEBufferStack.h"
#import "AERenderer.h"

@class AEModule;
    
    // 这里首先设置了block的别名
/*!
 * Invoke processing for a module
 *             为模块调用处理
 * @param module The module subclass  这个模块的子类
 * @param context The rendering context   渲染的上下文
 */
void AEModuleProcess(__unsafe_unretained AEModule * _Nonnull module, const AERenderContext * _Nonnull context);

/*!
 * Determine whether module is active
 *    确定模块是否被激活
 *  If NO is returned by this method, processing may be skipped for this
 *  module, as it is idle.
 *
 * @param module The module subclass
 * @returns Whether the module is active
 */
BOOL AEModuleIsActive(__unsafe_unretained AEModule * _Nonnull module);
    
/*!
 * Processing function
 *       处理功能
 *  All modules must provide a function of this type, and assign it to the
 *  @link AEModule::processFunction processFunction @endlink property.
 *
 *  Within a processing a function, a module may add, modify or remove
 *  buffers within the stack.
         在这个处理函数中，模块可以在堆栈中添加、修改或删除缓冲区。
 *
 * @param self A pointer to the module     指向模块的指针
 * @param context The rendering context    渲染的上下文
 */
typedef void (*AEModuleProcessFunc)(__unsafe_unretained AEModule * _Nonnull self, const AERenderContext * _Nonnull context);

/*!
 * Active test function
 *
 *  Modules may set this property to the address of a function that
 *  returns whether or not the module is currently active. If it returns
 *  NO, the module is considered inactive and processing can be skipped
 *  by client code.
 *
 * @param self A pointer to the module
 * @returns YES if the module is active, NO otherwise
 */
typedef BOOL (*AEModuleIsActiveFunc)(__unsafe_unretained AEModule * _Nonnull self);
    
/*!
 * Module base class
 *    基础的模块类
 *  Modules are the basic processing unit, and all provide a function to perform processing.
 *  Processing is invoked by calling AEModuleProcess and passing in the module.
 
     模块是基本的处理单元，并且都提供执行处理的功能。
         处理是通过调用aemoduleprocess通过模块调用。
 */
@interface AEModule : NSObject

/*!
 * Initializer
 *
 * @param renderer The renderer.
 */
- (instancetype _Nullable)initWithRenderer:(AERenderer * _Nullable)renderer NS_DESIGNATED_INITIALIZER;

- (instancetype _Nonnull)init NS_UNAVAILABLE;

/*!
 * Notifies the module that the renderer's sample rate has changed
 *
 *  Subclasses may override this method to react to sample rate changes.
 */
- (void)rendererDidChangeSampleRate;

/*!
 * Notifies the module that the renderer's channel count has changed
 *
 *  Subclasses may override this method to react to channel count changes.
 */
- (void)rendererDidChangeNumberOfChannels;

/*!
 * Process function
 *    处理函数
 *  All subclasses must set this property to the address of their
 *  processing function to be able to process audio.
       所有子类必须将此属性设置为其处理函数的地址，以便能够处理音频。
 */
@property (nonatomic) AEModuleProcessFunc _Nonnull processFunction;

/*!
 * Active test function
 *
 *  Subclasses may set this property to the address of a function that 
 *  returns whether or not the module is currently active. If it returns
 *  NO, the module is considered inactive and processing can be skipped
 *  by client code.
 */
@property (nonatomic) AEModuleIsActiveFunc _Nullable isActiveFunction;

/*!
 * The renderer
 *
 *  This may be re-assigned after initialization; the module will begin
 *  tracking the parameters of the new renderer.
     这可能是重新分配后的初始化；模块将开始新的渲染器的参数跟踪
 
 */
@property (nonatomic, weak) AERenderer * _Nullable renderer;

@end

#ifdef __cplusplus
}
#endif

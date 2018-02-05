//
//  AEManagedValue.h
//  TheAmazingAudioEngine
//
//  Created by Michael Tyson on 30/03/2016.
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

//! Batch update block
// 批量更改 block
typedef void (^AEManagedValueUpdateBlock)();

/*!
 * Release block
 *  释放block
 * @param value Original value provided
 */
typedef void (^AEManagedValueReleaseBlock)(void * _Nonnull value);

//! Release notification block
// 释放通知block
typedef void (^AEManagedValueReleaseNotificationBlock)();

/*!
 * Managed value
 *
 *  This class manages a mutable reference to a memory buffer or Objective-C object which is both thread-safe
 *  and realtime safe. It manages the life-cycle of the buffer/object so that it can not be deallocated
 *  while being accessed on the main thread, and does so without locking the realtime thread.
 
     这类管理可变参考内存缓冲区或Objective-C的对象是线程安全的，实时的安全。
 
       它管理对象的生命周期的缓冲/使它不能被释放在主线程中访问，并没有锁定实时线程。
*
 
 *  You can use this utility to manage a single module instance, which can be swapped out for
 *  another at any time, for instance.
      您可以使用此实用程序来管理单个模块实例，它可以在任何时候为另一个实例进行交换，例如
 *
 *  Remember to use the __unsafe_unretained directive to avoid ARC-triggered retains on the
 *  audio thread if using this class to manage an Objective-C object, and only interact with such objects
 *  via C functions they provide, not via Objective-C methods.
 
     记得使用__unsafe_unretained修饰，避免ARC强引用音频线程，如果使用这个类来管理一个Objective-C的对象，只有对象通过C所提供的功能的相互作用，而不是通过Objective-C方法
 
 */
@interface AEManagedValue : NSObject

/*!
 * Update multiple AEManagedValue instances atomically
 *    自动跟新多个实例
 *  Any changes made within the block will be applied atomically with respect to the audio thread.
         在块中所做的任何更改将对音响线自动应用。

 *  Any value accesses made from the realtime thread while the block is executing will return the
 *  prior value, until the block has completed.
       当块执行时，来自实时线程的任何值访问都将返回先前的值，直到这个块完成为止。
 
 *  These may be nested safely.
         这些可以安全地嵌套。

 *  If you are not using AEAudioUnitOutput, then you must call the AEManagedValueCommitPendingUpdates
 *  function at the beginning of your main render loop, particularly if you use this method. This 
 *  ensures batched updates are all committed in sync with your render loop. Until this function is
 *  called, AEManagedValueGetValue returns old values, prior to those set in the given block.
 *

     如果你没有使用aeaudiounitoutput，那你必须在你的主开始渲染循环调用aemanagedvaluecommitpendingupdates功能，特别是如果你使用这个方法。这确保了批量更新所有与你的渲染循环同步的承诺。直到这个函数被调用时，aemanagedvaluegetvalue返回旧值，这些设置在给定的块之前。
 * @param block Atomic update block
 */
+ (void)performAtomicBatchUpdate:(AEManagedValueUpdateBlock _Nonnull)block;

/*!
 * Get access to the value on the realtime audio thread
 *            获取实时音频线程上的值

 *  The object or buffer returned is guaranteed to remain valid until the next call to this function.
 *    保证返回的对象或缓冲区在下一次调用此函数之前保持有效。
 *  Can also be called safely on the main thread (although the @link objectValue @endlink and
 *  @link pointerValue @endlink properties are easier).
 *
 * @param managedValue The instance
 * @return The value
 */
void * _Nullable AEManagedValueGetValue(__unsafe_unretained AEManagedValue * _Nonnull managedValue);

/*!
 * Commit pending updates on the realtime thread
 *        在实时线程上提交挂起的更新
 *  If you are not using AEAudioUnitOutput, then you should call this function at the start of 
 *  your top-level render loop in order to apply updates in sync. If you are using AEAudioUnitOutput, 
 *  then this function is already called for you within that class, so you don't need to do so yourself.
 *
 *  After this function is called, any updates made within the block passed to performAtomicBatchUpdate:
 *  become available on the render thread, and any old values are scheduled for release on the main thread.
 *
 *  Important: Only call this function on the audio thread. If you call this on the main thread, you
 *  will see sporadic crashes on the audio thread.
 */
void AEManagedValueCommitPendingUpdates();

/*!
 * An object. You can set this property from the main thread. Note that you can use this property, 
 * or pointerValue, but not both.
 
     一个对象。可以从主线程设置此属性。请注意，您可以使用此属性，或pointervalue，但不能同时
 
 */
@property (nonatomic, strong) id _Nullable objectValue;

/*!
 * A pointer to an allocated memory buffer. Old values will be automatically freed when the value 
 * changes. You can set this property from the main thread. Note that you can use this property, 
 * or objectValue, but not both.
     向分配内存缓冲区的指针。旧值将在值更改时自动释放。可以从主线程设置此属性。请注意，您可以使用此属性，或objectvalue，但不能同时
 */
@property (nonatomic) void * _Nullable pointerValue;

/*!
 * Block to perform when deleting old items, on main thread. If not specified, will simply use 
 * free() to dispose values set via pointerValue, or CFBridgingRelease() to dispose values set via objectValue.
 
 
   在主线程上删除旧项时执行的块。如果没有指定，将使用free()配置设置的值通过pointervalue，或cfbridgingrelease()配置设置的值通过objectvalue
 */
@property (nonatomic, copy) AEManagedValueReleaseBlock _Nullable releaseBlock;

/*!
 * Block for release notifications. Use this to be informed when an old value has been released.
    用于发布通知的块。当旧值被释放时使用这个通知。
 
 */
@property (nonatomic, copy) AEManagedValueReleaseNotificationBlock _Nullable releaseNotificationBlock;

@end

#ifdef __cplusplus
}
#endif

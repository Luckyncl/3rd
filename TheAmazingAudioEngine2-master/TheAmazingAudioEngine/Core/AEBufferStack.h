//
//  AEBufferStack.h
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
#import <AudioToolbox/AudioToolbox.h>
#import "AETypes.h"

extern const UInt32 AEBufferStackMaxFramesPerSlice;

typedef struct AEBufferStack AEBufferStack;

/*!
 * Initialize a new buffer stack
 *      初始化一个新的缓冲区堆栈
 * @param poolSize The number of audio buffer lists to make room for in the buffer pool, or 0 for default value
         为缓冲池腾出空间的音频缓冲列表的数量，或默认值的0。
 * @return The new buffer stack
 */
AEBufferStack * AEBufferStackNew(int poolSize);

/*!
 * Initialize a new buffer stack, supplying additional options
 *          初始化一个新的缓冲区堆栈，提供其他选项
 * @param poolSize The number of audio buffer lists to make room for in the buffer pool, or 0 for default value
 
 
 * @param maxChannelsPerBuffer The maximum number of audio channels for each buffer (default 2)
         maxchannelsperbuffer最大数量的音频通道，每个缓冲（默认为2）
 
 * @param numberOfSingleChannelBuffers Number of mono float buffers to allocate (or 0 for default: poolSize*maxChannelsPerBuffer)
 * @return The new buffer stack
 */
AEBufferStack * AEBufferStackNewWithOptions(int poolSize, int maxChannelsPerBuffer, int numberOfSingleChannelBuffers);

/*!
 * Clean up a buffer stack
 *        释放堆栈
 * @param stack The stack
 */
void AEBufferStackFree(AEBufferStack * stack);

/*!
 * Set current frame count per buffer
 *
 * @param stack The stack
 * @param frameCount The number of frames for newly-pushed buffers
         新推缓冲区的帧数
 */
void AEBufferStackSetFrameCount(AEBufferStack * stack, UInt32 frameCount);

/*!
 * Get the current frame count per buffer
 *
 * @param stack The stack
 * @return The current frame count for newly-pushed buffers
 */
UInt32 AEBufferStackGetFrameCount(const AEBufferStack * stack);

/*!
 * Set timestamp for the current interval
 *         设置当前间隔的时间戳
 * @param stack The stack
 * @param timestamp The current timestamp
 */
void AEBufferStackSetTimeStamp(AEBufferStack * stack, const AudioTimeStamp * timestamp);

/*!
 * Get the timestamp for the current interval
 *
 * @param stack The stack
 * @return The current timestamp
 */
const AudioTimeStamp * AEBufferStackGetTimeStamp(const AEBufferStack * stack);

/*!
 * Get the pool size
 *
 * @param stack The stack
 * @return The current pool size
 */
int AEBufferStackGetPoolSize(const AEBufferStack * stack);

/*!
 * Get the maximum number of channels per buffer
 *     获得最大的通道数
 * @param stack The stack
 * @return The maximum number of channels per buffer
 */
int AEBufferStackGetMaximumChannelsPerBuffer(const AEBufferStack * stack);

/*!
 * Get the current stack count
 *         获得当前堆栈的缓冲区数量
 * @param stack The stack
 * @return Number of buffers currently on stack
 */
int AEBufferStackCount(const AEBufferStack * stack);

/*!
 * Get a buffer
 *
 * @param stack The stack
 * @param index The buffer index
 * @return The buffer at the given index (0 is the top of the stack: the most recently pushed buffer)
 */
const AudioBufferList * AEBufferStackGet(const AEBufferStack * stack, int index);

/*!
 * Push one or more new buffers onto the stack
 *
 *  Note that a buffer that has been pushed immediately after a pop points to the same data -
 *  essentially, this is a no-op. If a buffer is pushed immediately after a pop with more
 *  channels, then the first channels up to the prior channel count point to the same data,
 *  and later channels point to new buffers.
 
      注意，堆栈在压入一个缓冲区以后，会弹出相同的数据，这是一个空操作？？。在弹出多个通道立即压入一个缓冲区的时候，然后第一个通道到现有信道指向先前的通道的相同的数据，和后来的渠道指向新的缓冲区
 *
 * @param stack The stack
 * @param count Number of buffers to push
 * @return The first new buffer
 */
const AudioBufferList * AEBufferStackPush(AEBufferStack * stack, int count);

/*!
 * Push one or more new buffers onto the stack
 *        压入一个或更多的缓冲区到堆栈
 *  Note that a buffer that has been pushed immediately after a pop points to the same data -
 *  essentially, this is a no-op. If a buffer is pushed immediately after a pop with more
 *  channels, then the first channels up to the prior channel count point to the same data,
 *  and later channels point to new buffers.
 *
 * @param stack The stack
 * @param count Number of buffers to push
 * @param channelCount Number of channels of audio for each buffer
 * @return The first new buffer
 */
const AudioBufferList * AEBufferStackPushWithChannels(AEBufferStack * stack, int count, int channelCount);

/*!
 * Push an external audio buffer
 *          推一个外部音频缓冲器
 *  This function allows you to push a buffer that was allocated elsewhere. Note while the
 *  mData pointers within the pushed buffer will remain the same, and thus will point to the
 *  same audio data memory, the AudioBufferList structure itself will be copied; later changes
 *  to the original structure will not be reflected in the copy on the stack.
        此函数允许您推送在其他地方分配的缓冲区。注意
        MDATA指针在推入缓冲区的时候将保持不变，指向的是相同的音频数据内存，从而将指向
        相同的音频数据存储器的audiobufferlist结构本身将被复制；对原结构后的更改不会反映在复制堆栈上
 *
 *  It is the responsibility of the caller to ensure that it does not modify the audio data until
 *  the end of the current render cycle. Note that successive audio modules may modify the contents.
          调用者负责确保它不修改音频数据直到
 当前呈现周期的结束。注意，连续的音频模块可以修改内容。
 * @param stack The stack
 * @param buffer The buffer list to copy onto the stack
 * @return The new buffer
 */
const AudioBufferList * AEBufferStackPushExternal(AEBufferStack * stack, const AudioBufferList * buffer);
    
/*!
 * Duplicate the top buffer on the stack
 *
 *  Pushes a new buffer onto the stack which is a copy of the prior buffer.
 *    将一个新的缓冲区推到堆栈上，该堆栈是先前缓冲区的副本
 * @param stack The stack
 * @return The duplicated buffer
 */
const AudioBufferList * AEBufferStackDuplicate(AEBufferStack * stack);

/*!
 * Swap the top two stack items
 *   交换前两个堆栈项目
 * @param stack The stack
 */
void AEBufferStackSwap(AEBufferStack * stack);

/*!
 * Pop one or more buffers from the stack
 *
 *  The popped buffer remains valid until another buffer is pushed. A newly pushed buffer
 *  will use the same memory regions as the old one, and thus a pop followed by a push is
 *  essentially a no-op, given the same number of channels in each.
 *
 * @param stack The stack
 * @param count Number of buffers to pop, or 0 for all
 */
void AEBufferStackPop(AEBufferStack * stack, int count);

/*!
 * Remove a buffer from the stack
 *
 *  Remove an indexed buffer from within the stack. This has the same behaviour as AEBufferStackPop,
 *  in that a removal followed by a push results in a buffer pointing to the same memory.
 *
 * @param stack The stack
 * @param index The buffer index
 */
void AEBufferStackRemove(AEBufferStack * stack, int index);

/*!
 * Mix two or more buffers together
 *
 *  Pops the given number of buffers from the stack, and pushes a buffer with these mixed together.
 *     从堆栈中弹出给定数量的缓冲区，并将这些混合的缓冲区推到一起。
 *  When mixing a mono buffer and a stereo buffer, the mono buffer's channels will be duplicated.
 *      当混合单声道缓冲区和立体声缓冲区时，单声道缓冲区的频道将被复制
 * @param stack The stack
 * @param count Number of buffers to mix
 * @return The resulting buffer
 */
const AudioBufferList * AEBufferStackMix(AEBufferStack * stack, int count);

/*!
 * Mix two or more buffers together, with individual mix factors by which to scale each buffer
 *     将两个或多个缓冲区混合在一起，并使用单独的混合因子对每个缓冲区进行缩放
 * @param stack The stack
 * @param count Number of buffers to mix
 * @param gains The gain factors (power ratio) for each buffer. You must provide 'count' values
 
      每个缓冲器的增益因数（功率比）。必须提供“计数”值
 * @return The resulting buffer
 */
const AudioBufferList * AEBufferStackMixWithGain(AEBufferStack * stack, int count, const float * gains);

/*!
 * Apply volume and balance controls to the top buffer
 *    将音量和平衡控件应用于顶部缓冲区
 *  This function applies gains to the given buffer to affect volume and balance, with a smoothing ramp
 *  applied to avoid discontinuities. If the buffer is mono, and the balance is non-zero, the buffer will
 *  be made stereo instead.
 
       此函数应用给定缓冲区的增益，以影响音量和平衡，并使用平滑斜坡来避免不连续性
 如果缓冲区是单声道的，并且平衡是非零的，则缓冲区将被制成立体声。
 
 
 * @param stack The stack
 * @param targetVolume The target volume (power ratio)
 * @param currentVolume On input, the current volume; on output, the new volume. Store this and pass it
 *  back to this function on successive calls for a smooth ramp. If NULL, no smoothing will be applied.
 * @param targetBalance The target balance
 * @param currentBalance On input, the current balance; on output, the new balance. Store this and pass it
 *  back to this function on successive calls for a smooth ramp. If NULL, no smoothing will be applied.
 */
void AEBufferStackApplyFaders(AEBufferStack * stack,
                              float targetVolume, float * currentVolume,
                              float targetBalance, float * currentBalance);

/*!
 * Silence the top buffer
 *
 *  This function zereos out all samples in the topmost buffer.
       这个功能zereos在上面的缓冲区的所有样品
 * @param stack The stack
 */
void AEBufferStackSilence(AEBufferStack * stack);

/*!
 * Mix stack items onto an AudioBufferList
      混合堆放物品到audiobufferlist
 *  The given number of stack items will mixed into the buffer list.
 *
 * @param stack The stack
 * @param bufferCount Number of buffers to process, or 0 for all
 * @param output The output buffer list
 */
void AEBufferStackMixToBufferList(AEBufferStack * stack, int bufferCount, const AudioBufferList * output);

/*!
 * Mix stack items onto an AudioBufferList, with specific channel configuration
 *
 *  The given number of stack items will mixed into the buffer list.
 *
 * @param stack The stack
 * @param bufferCount Number of buffers to process, or 0 for all
 * @param channels The set of channels to output to. If stereo, any mono inputs will be doubled to stereo.
 *      If mono, any stereo inputs will be mixed down.
 * @param output The output buffer list
 */
void AEBufferStackMixToBufferListChannels(AEBufferStack * stack,
                                          int bufferCount,
                                          AEChannelSet channels,
                                          const AudioBufferList * output);

/*!
 * Get the timestamp for the given buffer index
 *
 *  Modules can use this method to access and manipulate the timestamp that corresponds
 *  to a piece of audio. For example, AEAudioUnitInputModule replaces the timestamp with
 *  one that corresponds to the input audio.
 *
 * @param stack The stack
 * @param index The buffer index
 * @return The timestamp that corresponds to the buffer at the given index
 */
AudioTimeStamp * AEBufferStackGetTimeStampForBuffer(AEBufferStack * stack, int index);

/*!
 * Reset the stack
 *
 *  This pops all items until the stack is empty
 *        重置堆栈
 * @param stack The stack
 */
void AEBufferStackReset(AEBufferStack * stack);
#ifdef __cplusplus
}
#endif

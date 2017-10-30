//
//  AERenderer.h
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
#import "AERenderContext.h"

/*!
 * Render loop block
 *
 *  Use the render loop block to provide top-level audio processing.
 *       使用这个循环的block 去提供高水平的音频处理
 *  Generate and process audio by interacting with the buffer stack, generally through the use of
 *  AEModule objects, which can perform a mix of pushing new buffers onto the stack, manipulating
 *  existing buffers, and popping buffers off the stack.
 

         通过与缓冲区堆栈交互产生和处理音频，通常通过使用
         aemodule对象，可进行组合推新的缓冲栈，操纵
         现有缓冲区，并从堆栈中弹出缓冲区
 
 
 
      At the end of the render block, use @link AERenderContextOutput @endlink to output buffers on the
 *  stack to the context's output bufferList.
 
        在渲染结束的时候可以使用 AERenderContextOutput 来输出在上下文 输出缓冲区列表上的 缓冲区
 * @param context The rendering context  渲染的上下文
 */
typedef void (^AERenderLoopBlock)(const AERenderContext * _Nonnull context);
    
/*!
 * Sample rate change notification
      采样率改变的通知
 */
extern NSString * const _Nonnull AERendererDidChangeSampleRateNotification;

/*!
 * Channel count change notification
     通道数改变的通知
 */
extern NSString * const _Nonnull AERendererDidChangeNumberOfOutputChannelsNotification;


/*!
 * Base renderer class
 *      基础的渲染类
 *  A renderer is responsible for driving the main processing loop, which is the central point
 *  for audio generation and processing. A sub-renderer may also be used, which can drive an
 *  intermediate render loop, such as for a variable-speed module.
         渲染器是负责主处理循环，这是中心点
         音频生成和处理。一个子类渲染器也可以使用，它可以驱动
         中间呈现循环，例如用于变速模块
      

 *  Renderers can provide an interface with the system audio output, or offline rendering to
 *  file, offline analysis, conversion, etc.
 *       渲染器可以提供系统的音频输出接口，或离线渲染
             文件、离线分析、转换等
 
 *  Use this class by allocating an instance, then assigning a block to the 'block' property,
 *  which will be invoked during audio generation, usually on the audio render thread. You may
 *  assign new blocks to this property at any time, and assignment will be thread-safe.
 
         通过分配实例，然后将块分配给“块”属性来使用此类，
         它将在音频生成期间调用，通常在音频渲染线程中调用。你可能
         在任何时候为这个属性分配新的块，赋值将是线程安全的
 */
@interface AERenderer : NSObject

/*!
 * Perform one pass of the render loop   执行一个循环的渲染
 *
 * @param renderer The renderer instance
 * @param bufferList An AudioBufferList to write audio to. If mData pointers are NULL, will set these
 *      to the top buffer's mData pointers instead.
 * @param frames The number of frames to process     有多少音频帧需要处理
 * @param timestamp The timestamp of the current period  当前周期的时间戳
 */
void AERendererRun(__unsafe_unretained AERenderer * _Nonnull renderer,
                   const AudioBufferList * _Nonnull bufferList,
                   UInt32 frames,
                   const AudioTimeStamp * _Nonnull timestamp);

@property (nonatomic, copy) AERenderLoopBlock _Nonnull block; //!< The output loop block. Assignment is thread-safe.
@property (nonatomic) double sampleRate; //!< The sample rate
@property (nonatomic) int numberOfOutputChannels; //!< The number of output channels
@property (nonatomic) BOOL isOffline; //!< Whether rendering is offline (faster than realtime), default NO   是否是离线的

// 缓冲队列
@property (nonatomic, readonly) AEBufferStack * _Nonnull stack; //!< Buffer stack
@end

#ifdef __cplusplus
}
#endif

//
//  AERenderContext.h
//  TheAmazingAudioEngine
//
//  Created by Michael Tyson on 29/04/2016.
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
#import "AEBufferStack.h"

/*!
 * Render context
 *
 *  This structure is passed into the render loop block, and contains information about the
 *  current rendering environment, as well as providing access to the render's buffer stack.
 
    该结构被传递到呈现循环块中，包含当前渲染环境的信息，以及提供对渲染缓冲区堆栈的访问
 */
typedef struct {
    
//     输出缓冲区列表。你应该写信给这个生产音频
    //! The output buffer list. You should write to this to produce audio.
    const AudioBufferList * _Nonnull output;
    
    //  要呈现给输出的帧数
    //! The number of frames to render to the output
    UInt32 frames;
    
    //  当前采样速率，以赫兹为单位
    //! The current sample rate, in Hertz
    double sampleRate;
    
    // 当前的时间戳
    //! The current audio timestamp
    const AudioTimeStamp * _Nonnull timestamp;
    
    //  是否是离线
    //! Whether rendering is offline (faster than realtime)
    BOOL offlineRendering;
    
    //  缓冲堆栈。将此用作工作空间来生成和处理音频
    //! The buffer stack. Use this as a workspace for generating and processing audio.
    AEBufferStack * _Nonnull stack;
    
} AERenderContext;

/*!
 * Mix stack items onto the output
 *
 *  The given number of stack items will mixed into the context's output.
 *  This method is a convenience wrapper for AEBufferStackMixToBufferList.
 *
     给定数量的堆栈缓冲区混合以后输出。这种方法是一种方便的包装aebufferstackmixtobufferlist
 * @param context The context
 * @param bufferCount Number of buffers on the stack to process, or 0 for all
 */
void AERenderContextOutput(const AERenderContext * _Nonnull context, int bufferCount);

/*!
 * Mix stack items onto the output, with specific channel configuration
 *          将堆栈项混合到输出，并具有特定的通道配置
 *  The given number of stack items will mixed into the context's output.
 *  This method is a convenience wrapper for AEBufferStackMixToBufferListChannels.
 *
 * @param context The context
 * @param bufferCount Number of buffers on the stack to process, or 0 for all
 * @param channels The set of channels to output to. If stereo, any mono inputs will be doubled to stereo.
 *      If mono, any stereo inputs will be mixed down.
 */
void AERenderContextOutputToChannels(const AERenderContext * _Nonnull context, int bufferCount, AEChannelSet channels);

#ifdef __cplusplus
}
#endif

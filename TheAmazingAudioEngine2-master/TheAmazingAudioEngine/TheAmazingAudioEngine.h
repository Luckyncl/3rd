//
//  TheAmazingAudioEngine.h
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

#import <TheAmazingAudioEngine/AEBufferStack.h>
#import <TheAmazingAudioEngine/AETypes.h>

#import <TheAmazingAudioEngine/AEModule.h>
#import <TheAmazingAudioEngine/AESubrendererModule.h>
#import <TheAmazingAudioEngine/AEAudioUnitModule.h>
#import <TheAmazingAudioEngine/AEAudioUnitInputModule.h>
#import <TheAmazingAudioEngine/AEAudioFilePlayerModule.h>
#import <TheAmazingAudioEngine/AEOscillatorModule.h>
#import <TheAmazingAudioEngine/AEMixerModule.h>
#import <TheAmazingAudioEngine/AESplitterModule.h>
#import <TheAmazingAudioEngine/AEBandpassModule.h>
#import <TheAmazingAudioEngine/AEDelayModule.h>
#import <TheAmazingAudioEngine/AEDistortionModule.h>
#import <TheAmazingAudioEngine/AEDynamicsProcessorModule.h>
#import <TheAmazingAudioEngine/AEHighPassModule.h>
#import <TheAmazingAudioEngine/AEHighShelfModule.h>
#import <TheAmazingAudioEngine/AELowPassModule.h>
#import <TheAmazingAudioEngine/AELowShelfModule.h>
#import <TheAmazingAudioEngine/AENewTimePitchModule.h>
#import <TheAmazingAudioEngine/AEParametricEqModule.h>
#import <TheAmazingAudioEngine/AEPeakLimiterModule.h>
#import <TheAmazingAudioEngine/AEVarispeedModule.h>
#import <TheAmazingAudioEngine/AEAudioFileRecorderModule.h>
#if TARGET_OS_IPHONE
#import <TheAmazingAudioEngine/AEReverbModule.h>
#import <TheAmazingAudioEngine/AEAudioPasteboard.h>
#endif

#import <TheAmazingAudioEngine/AERenderer.h>
#import <TheAmazingAudioEngine/AERenderContext.h>
#import <TheAmazingAudioEngine/AEAudioUnitOutput.h>
#import <TheAmazingAudioEngine/AEAudioFileOutput.h>

#import <TheAmazingAudioEngine/AEUtilities.h>
#import <TheAmazingAudioEngine/AEAudioBufferListUtilities.h>
#import <TheAmazingAudioEngine/TPCircularBuffer.h>
#import <TheAmazingAudioEngine/AECircularBuffer.h>
#import <TheAmazingAudioEngine/AEDSPUtilities.h>
#import <TheAmazingAudioEngine/AEMainThreadEndpoint.h>
#import <TheAmazingAudioEngine/AEAudioThreadEndpoint.h>
#import <TheAmazingAudioEngine/AEMessageQueue.h>
#import <TheAmazingAudioEngine/AETime.h>
#import <TheAmazingAudioEngine/AEArray.h>
#import <TheAmazingAudioEngine/AEManagedValue.h>
#import <TheAmazingAudioEngine/AEIOAudioUnit.h>
#import <TheAmazingAudioEngine/AEAudioFileReader.h>
#import <TheAmazingAudioEngine/AEWeakRetainingProxy.h>


/*!
 @mainpage
 
 The Amazing Audio Engine (or TAAE) is a framework for making audio apps.
 
 @section What-TAAE-Is What TAAE Is, And Who It's For
 
 TAAE comprises an infrastructure and a variety of utilities that make it easier to focus on the core
 tasks of generating and working with audio, without spending time writing boilerplate code and
 reinventing the wheel. Most of the common tasks are taken care of, so you can get straight to the good stuff:
 no friction.
     taae包括基础设施和各种公用设施，使它更容易专注于核心
     任务的生成和音频工作，没有花时间写的样板代码和
     重新发明轮子。大多数常见的任务都要处理，这样你就可以直接找到好东西。
 
 
 If you're writing code that directly generates or processes audio on the audio thread - and you know what the 
 audio thread is, and what it does - TAAE may be for you.
 
 @section What-TAAE-Isnt What TAAE Isn't
 
 TAAE *is not* a comprehensive audio processing library where all the work is already done for you, and it's not
 necessarily a suitable choice for those just starting out with audio, or for those with very simple needs.
 
 对于刚接触音频的人来说这个库并不是一个好的选择
 
 
 
 With TAAE, you're going to write code that runs on the audio thread; it gives you great power, but that comes 
 with [certain important responsibilities](http://atastypixel.com/blog/four-common-mistakes-in-audio-development/).
 
 If you don't know or aren't keen on finding out what the audio thread is, what 'realtime' means, what an 
 `AudioBufferList` is or how to handle lock-free concurrency, or if you want a library that consists
 of pre-built pieces you can just fit together, then I strongly recommend checking out
 [AudioKit](http://audiokit.io/), a powerful audio synthesis, processing, and analysis library without the 
 steep learning curve.
         如果你不知道或不热衷于寻找音频线是什么，什么‘实时’的意思，是一个` audiobufferlist `是如何无锁的并发处理，或者如果你想有一个图书馆，包括你可以组装在一起的预制件，然后我强烈建议退房。[ audiokit ]（HTTP：/ / audiokit。IO /），一个强大的音频合成、加工、分析图书馆没有陡峭学习曲线。
 
 
 @section Design TAAE's Design
 
 
 TAAE 2's design philosophy leans towards the simple and modular: to provide a set of small and simple
 building blocks that you can use together, or alone.
     taae 2的设计理念倾向于简单化提供了一套简单的小
     可以一起使用或单独使用的构建块
 TAAE 2 is made up of:
 
 <img src="Block Diagram.png" width="570" height="272" alt="Block Diagram">
 
 <table class="definition-list">
 <tr>
    <th>@link AEBufferStack AEBufferStack @endlink</th>
    <td>The pool of buffers used for storing and manipulating audio. This is the main component you'll be working
        with, as it forms the backbone of the audio pipeline. You'll push buffers to generate audio; get existing
        buffers to apply effects, analysis and to record; mix buffers to combine multpile sources; output buffers
        to the renderer, and pop buffers when you're done with them.
             用于存储和操作音频的缓冲池。这是您将要工作的主要组件。
             随着它形成音频管道的主干。您将推动缓冲区生成音频；获得现有的
             缓冲区的应用效果，分析和记录；混合缓冲区将multpile源；输出缓冲器
             到渲染器，和流行的缓冲区，当你完成他们
 
 </td>
 </tr>
  <tr>
    <th>AERenderer</th>
    <td>The main driver of audio processing, via the @link AERenderLoopBlock AERenderLoopBlock @endlink.</td>
 </tr>
  <tr>
    <th>AEAudioUnitOutput</th>
    <td>The system output interface, for playing generated audio
 
         系统输出接口，用于播放生成的音频
 .</td>
 </tr>
 <tr>
    <th>AEAudioFileOutput</th>  离线渲染
    <td>An offline render target, for rendering out to an audio file 脱机呈现目标，用于呈现到音频文件中.</td>
 </tr>
 <tr>
    <th>AEModule</th>     // 处理模块
    <td>A unit of processing, which interact with the buffer stack to generate audio, filter it, monitor or
        analyze, etc. Modules are driven by calling AEModuleProcess(). Some important modules:
 
 
 
         A unit of processing, which interact with the buffer stack to generate audio, filter it, monitor or
         analyze, etc. Modules are driven by calling AEModuleProcess(). Some important modules
         一种处理单元，它与缓冲区堆栈交互以生成音频、过滤、监视或
         分析等模块，通过调用aemoduleprocess()驱动。一些重要的模块
 - AEAudioFilePlayerModule: Play files.     // 播放文件
 - AEAudioUnitInputModule: Get system input.    // 获得系统的输入
 - AEAudioFileRecorderModule: Record files.  // 录音模块
 - AESubrendererModule: Drive a sub-renderer.  //
 - AEMixerModule: Drive multiple generators.  // 混音模块
    </td>
 </tr>
 <tr>
    <th>AEManagedValue</th>
    <td>Manage a reference to an object or pointer in a thread-safe way. Use this to hold references to modules
        that can be swapped out, removed or inserted at any time, for example.
     以线程安全的方式管理对对象或指针的引用。使用这个来保存对模块的引用
     可以在任何时候交换、删除或插入，例如
 </td>
 </tr>
 <tr>
    <th>AEArray</th>
    <td>Manage a list of objects or pointers in a thread-safe way. Use this to manage lists of modules that can
        be manipulated at any time, or use it to map between model objects in your app and C structures that you use
        for rendering or analysis tasks.
 
         以线程安全的方式管理对象或指针的列表。使用这个来管理可以使用的模块列表
         在任何时候都可以被操纵，或者用它来映射应用程序中的模型对象和您使用的C结构。
         用于呈现或分析任务
 </td>
 </tr>
  <tr>
    <th>[AEAudioBufferListUtilities](@ref AEAudioBufferListUtilities.h)</th>
    <td>Utilities for working with AudioBufferLists: create mutable copies on the stack, offset, copy, silence,
        and isolate certain channel combinations.
 
     工作audiobufferlists工具：创建可变的份上叠加、偏移，复制，沉默，
     隔离某些频道组合
    </td>
 </tr>
 <tr>
    <th>[AEDSPUtilties](@ref AEDSPUtilities.h)</th>
    <td>Digital signal processing utilities: apply gain adjustments, linear and equal-power ramps, apply gain or
        volume and balance adjustments with automatic smoothing; mix buffers together, and generate oscillators.
 

         数字信号处理实用程序：应用增益调整，线性和相等功率坡道，应用增益或
         自动调整音量和平衡调整；混合缓冲区，产生振荡器
    </td>
 </tr>
 <tr>
    <th>AEMessageQueue</th>
    <td>A powerful cross-thread synchronization facility. Use it to safely send messages back and forth between
        the main thread and the audio thread, to update state, trigger notifications from the audio thread, exchange
        data and more. The message queue is built from:
 
 
     强大的跨线程同步机制。使用它来安全地来回发送消息。
     主线程和音频线程，要更新状态，从音频线程触发通知，交换
     数据和更多
 - AEMainThreadEndpoint: A simple facility for sending messages to the main thread from the audio thread.
 - AEAudioThreadEndpoint: A simple facility for sending messages to the audio thread from the main thread.
    </td>
 </tr>
 <tr>
    <th>AECircularBuffer</th>
    <td>Circular/ring buffer implementation that works with AudioBufferList types. Use this to buffer audio to work
        in blocks of a certain size, or use it to transport audio off to a secondary thread, or from a secondary
        thread to the audio thread. Fully realtime- and thread-safe.</td>
 </tr>
 </table>
 
 Read about [the Buffer Stack](@ref The-Buffer-Stack) and audio processing next.
 
 
 
 
 
 
 
 @page The-Buffer-Stack The Buffer Stack
 
 The central component of TAAE 2 is the [buffer stack](@ref AEBufferStack), a utility that manages a pool of
 AudioBufferList structures, which in turn store audio for the current render cycle.
 
     taae 2的中央部分是[缓冲栈]（@参考aebufferstack），一种实用工具，管理一个池
     audiobufferlist结构，从而存储音频当前渲染周期
 
 
 The buffer stack is a production line. At the beginning of each render cycle, the buffer stack starts 
 empty; at the end of the render cycle, the buffer stack is reset to this empty state. In between, your 
 code will manipulate the stack to produce, manipulate, analyse, record and ultimately output audio.
 
         缓冲堆栈是一条生产线。在每个呈现周期的开始时，缓冲区堆栈开始为空；在呈现周期结束时，缓冲区堆栈被重置为空状态。在中间，您的代码将操作堆栈来生成、操作、分析、记录并最终输出音频。
 
 Think of the stack as a stacked collection of buffers, one on top of the other, with the oldest at the
 bottom, and the newest at the top. You can push buffers on top of the stack, and pop them off, and you
 can inspect any buffer within the stack:
 
 
         把堆栈看作一堆缓冲区，一个放在另一个上面，最老的在
         底部，最新的顶部。您可以在栈顶上推缓冲区，并将它们弹出，您可以检查堆栈中的任何缓冲区
 <img src="Stack.png" width="570" height="272" alt="Stack">
 
 @section The-Buffer-Stack-Operations Operations
 
 Push buffers onto the stack to generate new audio. Get existing buffers from the stack and edit them to
 apply effects, analyse, or record audio. Mix buffers on the stack to combine multiple audio sources.
 Output buffers to the current output to play their audio out loud. Pop buffers off the stack when you're
 done with them.
     将缓冲区推到堆栈上生成新的音频。从堆栈中获取现有的缓冲区并将其编辑到
     应用效果、分析或记录音频。混合堆栈上的缓冲区组合多个音频源。
     输出缓冲区到当前输出播放他们的声音大声。弹出缓冲区堆栈时，你
     他们做
 Each buffer on the stack can be mono, stereo, or multi-channel audio, and every buffer has the same number
 of frames of audio: that is, the number of frames requested by the output for the current render cycle.
     将缓冲区推到堆栈上生成新的音频。g堆栈上的每个缓冲区可以是单声道、立体声或多声道音频，并且每个缓冲区都具有相同数量的音频帧：即当前呈现周期的输出请求的帧数。
 <table class="definition-list">
 <tr>
    <th>AEBufferStackPush()</th>
    <td>Push one or more stereo buffers onto the stack.  将一个或多个立体缓冲区推入堆栈
        - Use AEBufferStackPushWithChannels() to push a buffer with the given number of channels.
        - Use AEBufferStackPushExternal() to push your own pre-allocated buffer onto the stack.  使用aebufferstackpushexternal()推自己的预分配的缓冲区到堆栈
        - Use AEBufferStackDuplicate() to push a copy of the top stack item.
             使用aebufferstackduplicate()推复制栈顶元素。
    </td>
 </tr>
 <tr>
    <th>AEBufferStackPop()</th>
    <td>Remove one or more buffers from the top of the stack.
         从堆栈顶部移除一个或多个缓冲区。
        - Use AEBufferStackRemove() to remove a buffer from the middle of the stack.
         使用aebufferstackremove()从堆栈中删除缓冲区
    </td>
 </tr>
 <tr>
    <th>AEBufferStackMix()</th>
    <td>Push a buffer that consists of the mixed audio from the top two or more buffers, and pop the original buffers.
 
         从包含两个或多个缓冲区的混合音频中推送缓冲区，并弹出原始缓冲区
 
 
        - Use AEBufferStackMixWithGain() to use individual mix factors for each buffer.
        - Use AEBufferStackMixToBufferList() to mix two or more buffers to a target audio buffer list.
        - Use AEBufferStackMixToBufferListChannels() to mix two or more buffers to a subset of the target buffer 
          list's channels.
         使用aebufferstackmixtobufferlistchannels()混合两种或两种以上的缓冲区的目标缓冲区的通道列表的一个子集
    </td>
 </tr>
 <tr>
    <th>AEBufferStackApplyFaders()</th>
    <td>Apply volume and balance controls to the top buffer.</td>
 </tr>
 <tr>
    <th>AEBufferStackSilence()</th>
    <td>Fill the top buffer with silence (zero samples).</td>
 </tr>
 <tr>
    <th>AEBufferStackSwap()</th>
    <td>     Swap the top two stack items.
                 交换前两个堆栈项目
 </td>
 </tr>
 </table>
 
 When you're ready to output a stack item, use AERenderContextOutput() to send the buffer to the output;
 
         当你准备输出一堆项目，使用aerendercontextoutput()发送缓冲区的输出
 it will be mixed with whatever's already on the output. Then optionally use AEBufferStackPop() to throw
 the buffer away.
         它将与已经存在的输出相混合。然后选择使用aebufferstackpop()扔缓冲了
 
 Most interaction with the stack is done through [modules](@ref AEModule), individual units of processing
 which can do anything from processing audio (i.e. pushing new buffers on the stack), adding effects
 (getting stack items and modifying the audio within), analysing or recording audio (getting stack items
 and doing something with the contents), or mixing audio together (popping stack items off, and pushing
 new buffers). You create modules on the main thread when initialising your audio engine, or when changing
 state, and then process them from within your [render loop](@ref AERenderLoopBlock) using
 AEModuleProcess().
 The modules, in turn, interact with the stack; pushing, getting and popping buffers.
 
     你的主线程创建时初始化您的音频引擎模块，或者改变状态时，然后处理它们在你内在的[渲染]（@参考aerenderloopblock）循环使用
     aemoduleprocess()。
     这些模块依次与堆栈交互；推送、获取和弹出缓冲区
 
 @section The-Buffer-Stack-Example An Example
 
 The following example takes three audio files, mixes and applies effects (we apply one effect to one player, and
 a second effect to the other two), then records and outputs the result.
 
     下面的示例使用三个音频文件，混合并应用效果（我们对一个播放器应用一个效果，然后
     对第二个结果的第二个效果，然后记录并输出结果
 
 This perfoms the equivalent of the following graph:
 
 <img src="Graph Equivalent.png" width="570" height="192" alt="Graph Equivalent">
 
 First, some setup. We'll create an instance of AERenderer, which will drive our main render loop. Then
 we create an instance of AEAudioUnitOutput, which is our interface to the system audio output.
         首先，一些设置。我们创建了aerenderer实例，这将推动我们的主要渲染循环。然后我们创建aeaudiounitoutput实例，这是我们对系统的音频输出接口
 
 
 Finally,
 we'll create a number of modules that we shall use.
         最后，我们将创建一些我们将使用的模块
 
 Note that each module maintains a reference to its
 controlling renderer, so it can track important changes such as sample rate.
 
         请注意，每个模块都维护其引用。
         控制渲染器，所以它可以跟踪重要的变化，如采样率
 @code
 // Create our renderer and output
 AERenderer * renderer = [AERenderer new];
 self.output = [[AEAudioUnitOutput alloc] initWithRenderer:renderer];
 
 // Create the players
 AEAudioFilePlayerModule * file1 = [[AEAudioFilePlayerModule alloc] initWithRenderer:renderer URL:url1 error:NULL];
 AEAudioFilePlayerModule * file2 = [[AEAudioFilePlayerModule alloc] initWithRenderer:renderer URL:url2 error:NULL];
 AEAudioFilePlayerModule * file3 = [[AEAudioFilePlayerModule alloc] initWithRenderer:renderer URL:url3 error:NULL];
 
 // Create the filters
 AEBandpassModule * filter1 = [[AEBandpassModule alloc] initWithRenderer:renderer];
 AEDelayModule * filter2 = [[AEDelayModule alloc] initWithRenderer:renderer];
 
 // Create the recorder
 AEAudioFileRecorderModule * recorder = [[AEAudioFileRecorderModule alloc] initWithRenderer:renderer URL:outputUrl error:NULL];
 @endcode
 
 Now, we can provide a render block, which contains the implementation for the audio pipeline. We run each module
 in turn, in the order that will provide the desired result:
         现在，我们可以提供一个渲染块，它包含音频管道的实现。
 <img src="Rendering Example.png" width="570" height="251" alt="Rendering Example">
 
 @code
 renderer.block = ^(const AERenderContext * _Nonnull context) {
     AEModuleProcess(file1, context);     // Run player (pushes 1)
     AEModuleProcess(filter1, context);   // Run filter (edits top buffer)
 
     AEModuleProcess(file2, context);     // Run player (pushes 1)
     AEModuleProcess(file3, context);     // Run player (pushes 1)
     AEBufferStackMix(context->stack, 2); // Mix top 2 buffers
 
     AEModuleProcess(filter2, context);   // Run filter (edits top buffer)
 
     AERenderContextOutput(context, 1);   // Put top buffer onto output
     AEModuleProcess(recorder, context);  // Run recorder (uses top buffer)
 };
 @endcode
 
 Note that we interact with the rendering environment via the AERenderContext; this provides us with a variety
 of important state information for the current render, as well as access to the buffer stack.
         请注意，我们与环境渲染通过aerendercontext互动；这为我们提供了目前提供的各种重要的状态信息，以及访问缓冲栈
 
 Finally, when we're initialized, we start the output, and the players:
 
 
         最后，当我们初始化时，我们启动输出，然后播放。
 @code
 [self.output start:NULL];
 
 [file1 playAtTime:0];
 [file2 playAtTime:0];
 [file3 playAtTime:0];
 @endcode
 
 We should hear all three audio file players, with a bandpass effect on the first, and a delay effect on the
 other two. We'll also get a recorded file which contains what we heard.
         我们应该听到所有三个音频文件播放器，对第一个带通效应，并对延迟的影响。
             其他两。我们也会得到一个录音文件，里面包含我们听到的内容。
 For a more sophisticated example, take a look at the sample app that comes with TAAE 2.
 一个更复杂的例子，看看是taae 2示例应用程序一看
 <hr>
 
 More documentation coming soon.

 
*/

#ifdef __cplusplus
}
#endif

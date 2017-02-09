#ifdef __cplusplus
extern "C" {
#endif

#import "AEAudioController.h"
#import "AEAudioController+Audiobus.h"
#import "AEAudioFileLoaderOperation.h"
#import "AEAudioFilePlayer.h"
#import "AEAudioFileWriter.h"
#import "AEMemoryBufferPlayer.h"
#import "AEBlockChannel.h"
#import "AEBlockFilter.h"
#import "AEBlockAudioReceiver.h"
#import "AEAudioUnitChannel.h"
#import "AEAudioUnitFilter.h"
#import "AEFloatConverter.h"
#import "AEBlockScheduler.h"
#import "AEUtilities.h"
#import "AEMessageQueue.h"
#import "AEAudioBufferManager.h"

/*!
@mainpage
 
@section Introduction
 
 TheAmazingAudioEngine is a framework you can use to build iOS audio apps.
 It's built to be very easy to use, but also offers an abundance of sophisticated functionality.
 
 The basic building-blocks of The Engine are:
 
  - [Channels](@ref Creating-Audio), which is how audio content is generated. These can be audio files, blocks, Objective-C objects, or Audio Units.
        音频通道
 
  - [Channel Groups](@ref Grouping-Channels), which let you group channels together in order to filter or record collections of channels.
        音频通道组
 
  - [Filters](@ref Filtering), which process audio. These can be blocks, Objective-C objects, or Audio Units.
        滤镜
  - [Audio Receivers](@ref Receiving-Audio), which give you access to audio from various sources.
        文件接收器
 
 
 <img src="blockdiagram.png" alt="Sample block diagram" />  // 一个 介绍的图片
 
 In addition to these basic components, The Amazing Audio Engine includes a number of other features and utilities:
    除了这些这些基本的组件  ，  还有以下特点  和 工具
 
  - Deep integration of [Audiobus](@ref Audiobus), the inter-app audio system for iOS.
  - A channel class for [playing and looping audio files]                                 用于通道播放  和  循环播放
  - An NSOperation class for [loading audio files into memory](@ref Reading-Audio).       一个操作类，用于将音频文件加载到内存
  - A class for [writing audio to an audio file](@ref Writing-Audio).                     一个写音频文件的 类
  -  [multi-channel input]                                                                  多路输入
  - [managing AudioBufferLists](@ref Audio-Buffers), the basic unit of audio.              一个用于管理 音频单元缓冲区的列表工具集  参考：--》 Audio-Buffers
 
 
    //
  - [Timing Receivers](@ref Timing-Receivers), which are used for sequencing and synchronization.  定时接收器，其用于测序和同步。
 
 
    # 一个使用了加速适量处理架构 的类 可以方便的进行浮点数格式的转化  参考： vector（向量） - processing
  - A class for managing easy conversion to and from [floating-point format](@ref Vector-Processing) for use with the Accelerate vector processing framework.
 
 
    # 一个没有加锁同步锁 的系统  （参考：Synchronization） 可以让在你的 app的主线程 和 核心音频线程之间你发送消息，不用担心 在管理访问共享变量方面引起的性能问题
  - A [lock-free synchronization](@ref Synchronization) system that lets you send messages between your app's main thread, and the Core Audio thread, without having to worry about managing access to shared variables in a way that doesn't cause performance problems.
 
    # 一套辅助 组件
  - A suite of auxiliary components, including:
 
    - A [recorder](@ref Recording) class, for recording and mixing one or more sources of audio  // 一个记录器类，用于记录一个或多个 音频源
 
        # 一个 通道 ， 方便进行 音频的监控
    - A [playthrough](@ref Playthrough) channel, for providing easy audio monitoring
        # 限制器 和 扩展器
    - Limiter and expander filters
 

 
    ************ 项目集成  ************
 First, you need to set up your project with The Amazing Audio Engine.
 
 
     # 使用 cocoapods 用于集成
 The easiest way to do so is using [CocoaPods](http://cocoapods.org):
 
 1. Add `pod 'TheAmazingAudioEngine'` to your Podfile, or, if you don't have one: at the top level of your project 
    folder, create a file called "Podfile" with the following content:
    @code
    pod 'TheAmazingAudioEngine'
    @endcode
 2. Then, in the terminal and in the same folder, type:
    @code
    pod install
    @endcode
 

 
  非ARC 情况 下  需要添加  编译命令：  -fobjc-arc
 
 @section Meet-AEAudioController Meet AEAudioController
 
 
  # 本框架 主要的枢纽是  AEAudioController；  这个类包含 主音频 引擎， 并管理您的音频会话为您服务。
 The main hub of The Amazing Audio Engine is AEAudioController. This class contains the main audio engine, and manages
 your audio session for you.
 
 To begin, create a new instance of AEAudioController in an appropriate location, such as within your app delegate:
 
 @code
 @property (nonatomic, strong) AEAudioController *audioController;
 
 ...
 
 self.audioController = [[AEAudioController alloc]
                            initWithAudioDescription:AEAudioStreamBasicDescriptionNonInterleaved16BitStereo
                                inputEnabled:YES]; // don't forget to autorelease if you don't use ARC!
 @endcode
 
 
  # 在这里，你在你希望你的应用程序中使用的音频格式传递。AEAudioController提供了一些易于使用预定义的格式，但你可以使用任何底层的核心音频系统支持。
 Here, you pass in the audio format you wish to use within your app. AEAudioController offers some easy-to-use predefined
 formats, but you can use anything that the underlying Core Audio system supports.
 
    # 你也可以启用音频输入
 You can also enable audio input, if you choose.
 
    # 启动 Controller 错误信息可以传递 一个 NSError 来捕获
 Now start the audio engine running. You can pass in an NSError pointer if you like, which will be filled in
 if an error occurs:
 
 @code
 NSError *error = NULL;
 BOOL result = [_audioController start:&error];
 
 if ( !result ) {
    // Report error
 }
 @endcode
 
 
   # 你可以 去设置  AEAudioController 的 各种属性， 比如 缓冲时间，音频输入模式，使用 音响类 会话的可用属性等。 你可以随时 设置这些。
 Take a look at the documentation for AEAudioController to see the available properties that can be set to modify
 behaviour, such as preferred buffer duration, audio input mode, audio category session to use. You can set these at any time.
 
 

    *********   创建音频内容   ************
 
    # 本框架  创建 音频 的各种方式
 There are a number of ways you can create audio with The Amazing Audio Engine:
 
 - You can play an audio file, with AEAudioFilePlayer.  // 播放音频文件 使用AEAudioFilePlayer
 - You can create a block to generate audio programmatically, using AEBlockChannel. # 创建一个音频组 生成音频编程，使用AEBlockChannel
 - You can create an Objective-C class that implements the AEAudioPlayable protocol. # 你可以创建一个 遵循 AEAudioPlayable 类的协议
 
 - You can even use an Audio Unit, using the AEAudioUnitChannel class.  // 你甚至可以使用 音频单元 利用 AEAudioUnitChannel 类


     *****     播放音频文件     *****
 
       ** AEAudioFilePlayer支持底层系统支持的任何音频格式，并拥有多项实用功能：
 AEAudioFilePlayer supports any audio format supported by the underlying system, and has a number of handy features:
 
 - Looping                                                    // 循环
 - Position seeking/scrubbing                                 // 位置寻求/擦洗
 - One-shot playback with a block to call upon completion     //单次播放与块结束时调用
 - Pan, volume, mute                                          //  声道 ???   volume 音量  mute 静音？？
 
 
    调用它的方式
 To use it, call @link AEAudioFilePlayer::audioFilePlayerWithURL:error: audioFilePlayerWithURL:error: @endlink,
 like so:
 
 @code
         NSURL *file = [[NSBundle mainBundle] URLForResource:@"Loop" withExtension:@"m4a"];
         self.loop = [AEAudioFilePlayer audioFilePlayerWithURL:file
                                                         error:NULL];
 @endcode
 
    // 如果想将 音频 循环播放  可以设置 loop 类播放  ，更多的设置 看文档
 If you'd like the audio to loop, you can set [loop](@ref AEAudioFilePlayer::loop) to `YES`. Take a look at the class
 documentation for more things you can do.
 
 
 
 
    **************  音频组   AEBlockChannel  *****************
 
    # AEBlockChannel是一个类，允许你创建一个组，生成音频编程。呼叫channelWithBlock： ，传递由定义的表格模块实现AEBlockChannelBlock
 AEBlockChannel is a class that allows you to create a block to generate audio programmatically. Call
 [channelWithBlock:](@ref AEBlockChannel::channelWithBlock:), passing in your block implementation in the form
 defined by @link AEBlockChannelBlock @endlink:
 
 @code
 self.channel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp  *time,
                                                   UInt32           frames,
                                                   AudioBufferList *audio) {
     // TODO: Generate audio in 'audio'
 }];
 @endcode
 
   该 block 有三个参数 来调用
 The block will be called with three parameters: 
 
   # 对应于时间的时间戳的音频将到达设备的音频输出。 如果 AEAudioController::automaticLatencyManagement automaticLatencyManagement 为yes 那么 时间戳 将自动进行 偏移
 - A timestamp that corresponds to the time the audio will reach the device audio output. Timestamp will be
   automatically offset to factor in system latency if AEAudioController's
   @link AEAudioController::automaticLatencyManagement automaticLatencyManagement @endlink property is YES
   (the default). If you disable this setting and latency compensation is important, this should be offset 
   by the value returned from
   @link  AEAudioController::AEAudioControllerOutputLatency AEAudioControllerOutputLatency @endlink.
 
 - the number of audio frames you are expected to produce, and        # 你期望音频所产生的 音频帧
 - an AudioBufferList in which to store the generated audio.          # 一个缓冲区 其中存储所产生的音频
 

 
    ****************    Objective-C的对象通道     ********************
 
    # 该AEAudioPlayable协议定义，你可以以创建可作为渠道作用Objective-C类遵循一个接口。
 The AEAudioPlayable protocol defines an interface that you can conform to in order to create Objective-C
 classes that can act as channels.
 
    # 该协议要求您定义返回一个指针，指向一个C函数，它被定义AEAudioRenderCallback形式的方法。是必需的音频时，这个C函数将被调用
 The protocol requires that you define a method that returns a pointer to a C function that takes the form
 defined by AEAudioRenderCallback. This C function will be called when audio is required.
 
 <blockquote class="tip">
 If you put this C function within the \@implementation block, you will be able to access instance
 variables via the C struct dereference operator, "->". Note that you should never make any Objective-C calls
 from within a Core Audio realtime thread, as this will cause performance problems and audio glitches. This
 includes accessing properties via the "." operator.
 </blockquote>
 
 @code
 @interface MyChannelClass <AEAudioPlayable>
 @end

 @implementation MyChannelClass

 ...
 
 static OSStatus renderCallback(__unsafe_unretained MyChannelClass *THIS,
                                __unsafe_unretained AEAudioController *audioController,
                                const AudioTimeStamp *time,
                                UInt32 frames,
                                AudioBufferList *audio) {
     // TODO: Generate audio in 'audio'
     **  注意： 这里面 访问变量的时候需要使用 c 结构的 -> 不能使用 “.” 来访问
     return noErr;
 }
 
 -(AEAudioRenderCallback)renderCallback {
     return &renderCallback;
 }
 
 @end

 ...
 
 self.channel = [[MyChannelClass alloc] init];
 @endcode
 
 
    //  渲染回调 将有 5 个 参数来调用：
 The render callback will be called with five parameters:
 
 - A reference to your class, 一个本类的引用
 - A reference to the AEAudioController instance, 一个AEAudioController 的实例
 - A timestamp that corresponds to the time the audio will reach the device audio output. Timestamp will be
   automatically offset to factor in system latency if AEAudioController's
   @link AEAudioController::automaticLatencyManagement automaticLatencyManagement @endlink property is YES
   (the default). If you disable this setting and latency compensation is important, this should be offset
   by the value returned from
   @link  AEAudioController::AEAudioControllerOutputLatency AEAudioControllerOutputLatency @endlink.
 
 - the number of audio frames you are expected to produce, and         音频帧的总数量
 - an AudioBufferList in which to store the generated audio.            缓冲区存储的音频
 
 
 
 **************    音频单元通道    **********************
 
    # 该AEAudioUnitChannel类作为音频设备的主机，可以让你使用任何发生器音频单元作为音源。
 The AEAudioUnitChannel class acts as a host for audio units, allowing you to use any generator audio unit as an
 audio source.
 
 To use it, call @link AEAudioUnitChannel::initWithComponentDescription: initWithComponentDescription: @endlink,
 passing in an `AudioComponentDescription` structure (you can use the utility function @link AEAudioComponentDescriptionMake @endlink for this).
 
 @code
 AudioComponentDescription component
    = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                      kAudioUnitType_MusicDevice,
                                      kAudioUnitSubType_Sampler)
 
 self.sampler = [[AEAudioUnitChannel alloc] initWithComponentDescription:component];
 @endcode
 
    # 一旦你添加的通道音频控制器，可以再直接通过访问音频单元audioUnit。您也可以通过添加在自己的初始化步骤initWithComponentDescription：preInitializeBlock：初始化。
 Once you have added the channel to the audio controller, you can then access the audio unit directly via the 
 [audioUnit](@ref AEAudioUnitChannel::audioUnit) property. You can also add your own initialization step via the
 @link AEAudioUnitChannel::initWithComponentDescription:preInitializeBlock: initWithComponentDescription:preInitializeBlock: @endlink
 initializer.
 
 
 
 
   ************      添加频道      ************
 
    # 一旦你创建了一个通道，将其添加到与音频引擎addChannels： 。
 Once you've created a channel, you add it to the audio engine with [addChannels:](@ref AEAudioController::addChannels:).
 
 @code
 [_audioController addChannels:[NSArray arrayWithObject:_channel]];
 @endcode
 
 
    # 请注意，您可以使用尽可能多的渠道作为设备可以处理，您可以添加/删除频道，只要你喜欢，通过调用addChannels：或removeChannels：
 Note that you can use as many channels as the device can handle, and you can add/remove channels whenever you like, by
 calling [addChannels:](@ref AEAudioController::addChannels:) or [removeChannels:](@ref AEAudioController::removeChannels:).
 
 
 
     ****************   通道编组   ***************
 
 The Amazing Audio Engine provides *channel groups*, which let you construct trees of channels so you can do things with them
 together.
 
    # 通过调用创建通道组createChannelGroup或者 createChannelGroupWithinChannelGroup： ，然后通过调用的频道加入这些团体toChannelGroup：addChannels：toChannelGroup： 。
 Create channel groups by calling [createChannelGroup](@ref AEAudioController::createChannelGroup) or create subgroups with
 [createChannelGroupWithinChannelGroup:](@ref AEAudioController::createChannelGroupWithinChannelGroup:), then add channels
 to these groups by calling [addChannels:toChannelGroup:](@ref AEAudioController::addChannels:toChannelGroup:).
 
 
 
   # 然后，您可以在频道群组，如执行各种操作，设置音量和平移，并添加过滤器和音频接收器，这是我们接下来要介绍。
 You can then perform a variety of operations on the channel groups, such as @link AEAudioController::setVolume:forChannelGroup: setting volume @endlink
 and @link AEAudioController::setPan:forChannelGroup: pan @endlink, and adding filters and audio receivers, which we shall cover next.
 
 -----------

        **********     过滤器     ************
 
@page Filtering Filtering
 
     # 惊人的音频引擎包括一个复杂的和灵活的音频处理架构，让你的效果应用到音频整个应用程序。
 The Amazing Audio Engine includes a sophisticated and flexible audio processing architecture, allowing you to
 apply effects to audio throughout your application.
 
     # 该引擎为您提供了效果应用到音频三种方式：
 The Engine gives you three ways to apply effects to audio:
 
 - You can process audio with blocks, via the AEBlockFilter class.              既可以使用block 来处理音频 通过 AEBlockFilter 这个类
 - You can implement Objective-C classes that implement the AEAudioFilter protocol.  你可以使用一个 实现了AEAudioFilter 协议的oc类
 - You can use Audio Units.                                                          你可以使用音频单元
 
           ******************       block 过滤器       *******************
 
 To filter audio using a block, create an instance of AEBlockFilter using [filterWithBlock:](@ref AEBlockFilter::filterWithBlock:),
 passing in a block implementation that takes the form defined by @link AEBlockFilterBlock @endlink.
 
 The block will be passed a function pointer, `producer`, which is used to pull audio from the system. Your
 implementation block must invoke this function when audio is needed, passing as the first argument the
 opaque `producerToken` pointer also passed to the block.
 
@code
 
 
self.filter = [AEBlockFilter filterWithBlock:^(AEAudioFilterProducer producer,
                                               void                     *producerToken,
                                               const AudioTimeStamp     *time,
                                               UInt32                    frames,
                                               AudioBufferList          *audio) {
     // Pull audio
     OSStatus status = producer(producerToken, audio, &frames);
     if ( status != noErr ) return;
     
     // Now filter audio in 'audio'
}];
 
 
 @endcode
 
 
 
 
 
 
     *************        Objective-C的对象过滤器        ****************
 
    #该AEAudioFilter协议定义，你可以为了创建一个可以过滤音频Objective-C类遵循一个接口。
 The AEAudioFilter protocol defines an interface that you can conform to in order to create Objective-C
 classes that can filter audio.
 
    #该协议要求您定义返回一个指针，指向一个C函数，它被定义AEAudioFilterCallback形式的方法。这个C函数将被调用时，声音将被过滤。
 The protocol requires that you define a method that returns a pointer to a C function that takes the form
 defined by AEAudioFilterCallback. This C function will be called when audio is to be filtered.

    # 注意 应该使用 -> 来访问变量   而不是使用 .  ***
 If you put this C function within the \@implementation block, you will be able to access instance
 variables via the C struct dereference operator, "->". Note that you should never make any Objective-C calls
 from within a Core Audio realtime thread, as this will cause performance problems and audio glitches. This
 includes accessing properties via the "." operator.
 </blockquote>
 
 
    #与块过滤器，上面，则提供回调将传递函数指针，producer，它用来拉从系统的音频。当需要声音，传递作为第一个参数不透明的执行块 ​​必须调用这个函数producerToken指针也将传递到块。
 As with block filters, above, the callback you provide will be passed a function pointer, `producer`, 
 which is used to pull audio from the system. Your implementation block must invoke this function when audio
 is needed, passing as the first argument the opaque `producerToken` pointer also passed to the block.
 
 @code
 @interface MyFilterClass <AEAudioFilter>
 @end

 @implementation MyFilterClass

 ...
 
 static OSStatus filterCallback(__unsafe_unretained MyFilterClass *THIS,
                                __unsafe_unretained AEAudioController *audioController,
                                AEAudioFilterProducer producer,
                                void                     *producerToken,
                                const AudioTimeStamp     *time,
                                UInt32                    frames,
                                AudioBufferList          *audio) {
 
     // Pull audio
     OSStatus status = producer(producerToken, audio, &frames);
     if ( status != noErr ) status;
 
     // Now filter audio in 'audio'
 
     return noErr;
 }

 -(AEAudioFilterCallback)filterCallback {
     return filterCallback;
 }
 
 @end

 ...
 
 self.filter = [[MyFilterClass alloc] init];
 @endcode
 
         
 
 
 
    *****************      音频单元过滤器      ****************
 
 //          该AEAudioUnitFilter类允许您使用的音频设备应用效果音频。
 The AEAudioUnitFilter class allows you to use audio units to apply effects to audio.
 
 
    #该AEAudioUnitFilter类允许您使用的音频设备应用效果音频。
     要使用它，请拨打initWithComponentDescription： ，传入一个AudioComponentDescription结构（可以使用效用函数AEAudioComponentDescriptionMake此）：
 To use it, call @link AEAudioUnitFilter::initWithComponentDescription: initWithComponentDescription: @endlink,
 passing in an `AudioComponentDescription` structure (you can use the utility function @link AEAudioComponentDescriptionMake @endlink for this):
 
 
 
 @code  代码
 AudioComponentDescription component
    = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                      kAudioUnitType_Effect,
                                      kAudioUnitSubType_Reverb2)
 
 self.reverb = [[AEAudioUnitFilter alloc] initWithComponentDescription:component];
 @endcode
 
 
    # 一旦你添加过滤器的通道，通道组或主输出，然后可以直接通过访问音频单元audioUnit财产。您也可以通过添加在自己的初始化步骤initWithComponentDescription：preInitializeBlock：初始化。
 Once you have added the filter to a channel, channel group or main output, you can then access the audio unit directly via the
 [audioUnit](@ref AEAudioUnitFilter::audioUnit) property. You can also add your own initialization step via the
 @link AEAudioUnitFilter::initWithComponentDescription:preInitializeBlock: initWithComponentDescription:preInitializeBlock: @endlink
 initializer.
 
 @code
 AudioUnitSetParameter(_reverb.audioUnit,
                       kReverb2Param_DryWetMix,
                       kAudioUnitScope_Global,
                       0,
                       100.f,
                       0);
 @endcode
 
 
        ****************      添加过滤器     ******************
        #   一旦你得到了一个过滤器，可以将其应用到各种不同的音频源：
 Once you've got a filter, you can apply it to a variety of different audio sources:
        
 
        #   它适用于使用您的整个应用程序的输出addFilter：
 - Apply it to your entire app's output using @link AEAudioController::addFilter: addFilter: @endlink.
 
        #   它适用于使用一个单独的通道addFilter：toChannel
 - Apply it to an individual channel using @link AEAudioController::addFilter:toChannel: addFilter:toChannel: @endlink.
 
        #   它适用于通道组使用addFilter：toChannelGroup： 。
 - Apply it to a [channel group](@ref Grouping-Channels) using @link AEAudioController::addFilter:toChannelGroup: addFilter:toChannelGroup: @endlink.
 
        #   它适用于使用你的应用程序的音频输入addInputFilter： 。 这个应该是录音的时候使用的
 - Apply it to your app's audio input using @link AEAudioController::addInputFilter: addInputFilter: @endlink.
 
    # ** 您可以添加在任何时间删除过滤器，使用addFilter：和removefilter我：和其他通道，组和输入当量。
 
 You can add and remove filters at any time, using @link AEAudioController::addFilter: addFilter: @endlink and
 @link AEAudioController::removeFilter: removeFilter: @endlink, and the other channel, group and input equivalents.

 
 
 
 
 
 
 
   ------------
        
             *************     接收音频     ************
 
@page Receiving-Audio Receiving Audio
 
        # 到目前为止，我们已经讨论了创建和处理音频，但如果你想要做的事与麦克风/音频设备输入，或采取音频从您的应用程序来，并用它做什么呢？
 So far we've covered creating and processing audio, but what if you want to do something with the microphone/device audio input, or
 take the audio coming from your app and do something with it?
 
 
 
 The Amazing Audio Engine supports receiving audio from a number of sources:
 惊人的音频引擎支持接收音频从一些来源
 
 - The device's audio input (the microphone, or an attached compatible audio device).   该设备的音频输入
 - Your app's audio output.                                                                 您的应用程序的音频输出
 - One particular channel.                                                                      一个特别的通道

 - A channel group.                                                                           通道组。
 
 To begin receiving audio, you can either create an Objective-C class that implements the @link AEAudioReceiver @endlink protocol:
 
 开始接收音频，你可以创建一个Objective-C类实现的
 
 
 @code
 @interface MyAudioReceiver : NSObject <AEAudioReceiver>
 @end
 @implementation MyAudioReceiver
 static void receiverCallback(__unsafe_unretained MyAudioReceiver *THIS,
                              __unsafe_unretained AEAudioController *audioController,
                              void                     *source,
                              const AudioTimeStamp     *time,
                              UInt32                    frames,
                              AudioBufferList          *audio) {
     
     // Do something with 'audio'
 }
 
 -(AEAudioReceiverCallback)receiverCallback {
     return receiverCallback;
 }
 @end
 
 ...

 id<AEAudioReceiver> receiver = [[MyAudioReceiver alloc] init];
 @endcode
 
 ...or you can use the AEBlockAudioReceiver class to specify a block to receive audio:
 
 @code
 
 也可以使用 block 的音频接收器
 id<AEAudioReceiver> receiver = [AEBlockAudioReceiver audioReceiverWithBlock:
                                    ^(void                     *source,
                                      const AudioTimeStamp     *time,
                                      UInt32                    frames,
                                      AudioBufferList          *audio) {
    // Do something with 'audio'
 }];
 @endcode
 
 
       **  在这两种情况下，你的回调或块将被传递：
 In both cases, your callback or block will be passed:
 
 
 - An opaque identifier indicating the audio source,
 
 - A timestamp that corresponds to the time the audio hit the device audio input. Timestamp will be
   automatically offset to factor in system latency if AEAudioController's
   @link AEAudioController::automaticLatencyManagement automaticLatencyManagement @endlink property is YES
   (the default). If you disable this setting and latency compensation is important, this should be offset
   by the value returned from
   @link  AEAudioController::AEAudioControllerInputLatency AEAudioControllerInputLatency @endlink.
 - the number of audio frames available, and
 - an AudioBufferList containing the audio.
 
 
 
 Then, add the receiver to the source of your choice:
 
 
         要接收音频输入，使用addInputReceiver： 。
         接收音频输出，使用addOutputReceiver： 。
         从通道接收音频，使用addOutputReceiver：forChannel： 。
         接收来自一个信道组音频，使用addOutputReceiver：forChannelGroup： 。

 - To receive audio input, use @link AEAudioController::addInputReceiver: addInputReceiver: @endlink.
 - To receive audio output, use @link AEAudioController::addOutputReceiver: addOutputReceiver: @endlink.
 - To receive audio from a channel, use @link AEAudioController::addOutputReceiver:forChannel: addOutputReceiver:forChannel: @endlink.
 - To receive audio from a channel group, use @link AEAudioController::addOutputReceiver:forChannelGroup: addOutputReceiver:forChannelGroup: @endlink.
 
 
 
 
 
 
        ********************         通关/音频监听       ********************

        #对于一些应用，可能有必要提供音频监视，其中，通过麦克风或其它设备的音频输入来在音频扬声器播放出来
 For some applications it might be necessary to provide audio monitoring, where the audio coming in through the
 microphone or other device audio input is played out of the speaker.
 
 
        #该AEPlaythroughChannel位于“模块”目录中注意到了这一问题。此类实现两者AEAudioPlayable 和所述 AEAudioReceiver协议，这样它充当两个音频接收器和音频源。
 
 The AEPlaythroughChannel located within the "Modules" directory takes care of this. This class implements both the
 @link AEAudioPlayable @endlink *and* the @link AEAudioReceiver @endlink protocols, so that it acts as both an
 audio receiver and an audio source.
 
        要使用它，初始化然后将其添加为使用输入接收器AEAudioController的addInputReceiver：并将其添加为使用通道addChannels： 。
 To use it, initialize it then add it as an input receiver using 
 AEAudioController's @link AEAudioController::addInputReceiver: addInputReceiver: @endlink
 and add it as a channel using @link AEAudioController::addChannels: addChannels: @endlink.
 

 
 
            ******************          记录           *******************
 
         #  在“模块”目录中是AERecorder类，它实现了AEAudioReceiver协议，并提供简单而复杂的录音。
 Included within the "Modules" directory is the AERecorder class, which implements the @link AEAudioReceiver @endlink
 protocol and provides simple but sophisticated audio recording.
 
 
         #  要使用AERecorder，使用初始化initWithAudioController： 。
 To use AERecorder, initialize it using @link AERecorder::initWithAudioController: initWithAudioController: @endlink.
 
 
        #  然后，当你准备开始录音，使用beginRecordingToFileAtPath：的fileType：错误：，传递路径，你想记录到文件中，并使用的文件类型。常见的文件类型包括kAudioFileAIFFType，kAudioFileWAVEType，kAudioFileM4AType（使用AAC音频编码），和kAudioFileCAFType。
 Then, when you're ready to begin recording, use
 @link AERecorder::beginRecordingToFileAtPath:fileType:error: beginRecordingToFileAtPath:fileType:error: @endlink,
 passing in the path to the file you'd like to record to, and the file type to use. Common file types include
 `kAudioFileAIFFType`, `kAudioFileWAVEType`, `kAudioFileM4AType` (using AAC audio encoding), and `kAudioFileCAFType`.
 
 
        # 最后，添加AERecorder实例作为使用上述方法的接收器
 Finally, add the AERecorder instance as a receiver using the methods listed above.
 
        # 请注意，您可以添加实例作为接收多个源，而这些将被自动混合在一起。
 Note that you can add the instance as a receiver of *more than one source*, and these will be mixed together automatically.

 
        #例如，你可能有一个记录功能的卡拉OK应用，并且你要记录背景音 和 麦克风音频

 For example, you might have a karaoke app with a record function, and you want to record both the backing music and the microphone
 audio at the same time:
 
 @code
 - (void)beginRecording {
    // Init recorder
    self.recorder = [[AERecorder alloc] initWithAudioController:_audioController];
 
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) 
                                    objectAtIndex:0];
    NSString *filePath = [documentsFolder stringByAppendingPathComponent:@"Recording.aiff"];
 
    // Start the recording process
    NSError *error = NULL;
    if ( ![_recorder beginRecordingToFileAtPath:filePath 
                                       fileType:kAudioFileAIFFType 
                                          error:&error] ) {
        // Report error
        return;
    }
 
    // Receive both audio input and audio output. Note that if you're using
    // AEPlaythroughChannel, mentioned above, you may not need to receive the input again.
    [_audioController addInputReceiver:_recorder];
    [_audioController addOutputReceiver:_recorder];
 }
 @endcode
  
        # 结束 记录 需要 调用 finishRecording
 To complete the recording, call [finishRecording](@ref AERecorder::finishRecording).
 
 @code
 - (void)endRecording {
    [_audioController removeInputReceiver:_recorder];
    [_audioController removeOutputReceiver:_recorder];
 
    [_recorder finishRecording];
 
    self.recorder = nil;
 }
 @endcode
 

 
 
     *******************        多渠道投入支持        *********************
        #惊人的音频引擎提供了选择一组输入通道的多通道输入设备连接时的能力
 The Amazing Audio Engine provides the ability to select a set of input channels when a multi-channel input
 device is connected.
 
 
        #可以分配NSIntegers到阵列inputChannelSelection的属性AEAudioController为了选择应使用的输入装置的信道。
 You can assign an array of NSIntegers to the [inputChannelSelection](@ref AEAudioController::inputChannelSelection) property
 of AEAudioController in order to select which channels of the input device should be used.
 
 
        #例如，对于四通道输入装置，下面将选择最后两个通道作为立体声流：
 For example, for a four-channel input device, the following will select the last two channels as a stereo stream:
 
 @code
 
 
 _audioController.inputChannelSelection = [NSArray arrayWithObjects:
                                            [NSNumber numberWithInt:2],
                                            [NSNumber numberWithInt:3,
                                            nil];
 @endcode
 
 
        #您也可以将音频输入接收器或过滤器的通道不同的选择。例如，可以有一个AEAudioReceiver对象从立体声输入装置的第一信道接收，和一个不同的对象，从所述第二信道接收。
 You can also assign audio input receivers or filters for different selections of channels. For example, you can
 have one AEAudioReceiver object receiving from the first channel of a stereo input device, and a different
 object receiving from the second channel.
 
        #使用addInputReceiver：forChannels：和addInputFilter：forChannels：方法来做到这一点
 Use the @link AEAudioController::addInputReceiver:forChannels: addInputReceiver:forChannels: @endlink and
 @link AEAudioController::addInputFilter:forChannels: addInputFilter:forChannels: @endlink methods to do this:
 
 @code
 [_audioController addInputReceiver:
    [ABBlockAudioReceiver audioReceiverWithBlock:^(void                     *source,
                                                   const AudioTimeStamp     *time,
                                                   UInt32                    frames,
                                                   AudioBufferList          *audio) {
        // Receiving left channel     左声道
    }]
                        forChannels:[NSArray arrayWithObject:[NSNumber numberWithInt:0]]];
 
 [_audioController addInputReceiver:
    [ABBlockAudioReceiver audioReceiverWithBlock:^(void                     *source,
                                                   const AudioTimeStamp     *time,
                                                   UInt32                    frames,
                                                   AudioBufferList          *audio) {
        // Receiving right channel     右声道
    }]
                        forChannels:[NSArray arrayWithObject:[NSNumber numberWithInt:1]]];
 @endcode
 
        #请注意，numberOfInputChannels属性是键-值观察的，所以你可以用它来 ​​通知时显示appopriate UI等。
 Note that the [numberOfInputChannels](@ref AEAudioController::numberOfInputChannels) property is key-value observable,
 so you can use this to be notified when to display appopriate UI, etc.
 
 
 ----------
 
 
    *****************       Audiobus     *******************
        #接下来，请继续阅读，了解如何与其他音频应用程序进行交互，发送与接受或过滤音频Audiobus。
 Next, read on to find out how to interact with other audio apps, sending, receiving or filtering audio
 with [Audiobus](@ref Audiobus).
 
@page Audiobus Audiobus
 
        #Audiobus是一种广泛使用的iOS库，让用户结合iOS应用为一体的综合化，模块化虚拟演播室-有点像虚拟的音频线。
 [Audiobus](http://audiob.us) is a widely-used iOS library that lets users combine iOS apps into an integrated,
 modular virtual studio - a bit like virtual audio cables.
        兼容的应用程序建立在Audiobus SDK，这使得他们打造“港口”，这既可以发送，接收或处理的音频支持。
 Compatible apps build in support for the Audiobus SDK, which allows them to create 'ports' which can either send,
 receive or process audio.
 
        #神奇的音频引擎，由迈克尔·泰森开发，谁创造Audiobus同一开发商，包含了深度整合 Audiobus，具有支持：
 
    接收Audiobus音频无缝替换麦克风/音频设备输入。
    发送从您的应用程序的任何一点Audiobus音频：主应用程序的输出，或任何通道或通道组。

 The Amazing Audio Engine, developed by Michael Tyson, the same developer who created Audiobus, contains a
 @link AEAudioController(AudiobusAdditions) deep integration @endlink of Audiobus, with support for:
 
 - Receiving Audiobus audio that seamlessly replaces microphone/device audio input.
 - Sending Audiobus audio from any point in your app: The primary app output, or any channel or channel group.
 
 To integrate Audiobus into your The Amazing Audio Engine-based app, you need to register an account with 
 the [Audiobus Developer Center](http://developer.audiob.us), download the latest Audiobus SDK and
 follow the instructions in the [Audiobus Documentation](http://developer.audiob.us/doc)'s
 [integration guide](http://developer.audiob.us/doc/_integration-_guide.html) to set up
 your project with the Audiobus SDK.

 Then you can:
 
 - Receive Audiobus audio by creating an ABReceiverPort and passing it to The Amazing Audio Engine
   via AEAudioController's [audiobusReceiverPort](@ref AEAudioController::audiobusReceiverPort) property.
 - Send your app's audio output via Audiobus by creating an ABSenderPort and passing it your [audio unit](@ref AEAudioController::audioUnit).
 - Send one individual channel via Audiobus by assigning a new ABSenderPort via
   @link AEAudioController::setAudiobusSenderPort:forChannel: setAudiobusSenderPort:forChannel: @endlink
 - Send a channel group via Audiobus by assigning a new ABSenderPort via
   @link AEAudioController::setAudiobusSenderPort:forChannelGroup: setAudiobusSenderPort:forChannelGroup: @endlink
 - Filter Audiobus audio by creating an ABFilterPort with AEAudioController's [audioUnit](@ref AEAudioController::audioUnit).
 
 
 Take a look at the header documentation for the @link AEAudioController(AudiobusAdditions) Audiobus functions @endlink
 for details.
 
 -------------
 
 We've now covered the basic building blocks of apps using The Amazing Audio Engine, but there's plenty more to know.
 
 [Read on](@ref Other-Facilities) to find out about:
 
  - [Reading](@ref Reading-Audio) from audio files.
  - [Writing](@ref Writing-Audio) to audio files.
  - [Managing audio buffers](@ref Audio-Buffers).
  - Making your app dramatically more efficient by using [vector processing operations](@ref Vector-Processing).
  - Efficient, safe and simple [inter-thread synchronization](@ref Synchronization) using The Amazing Audio Engine's messaging system.
  - How to [schedule events](@ref Timing-Receivers) with absolute accuracy.
 
@page Other-Facilities Other Facilities
 
 The Amazing Audio Engine provides quite a number of utilities and other bits and pieces designed to make writing
 audio apps easier.

 
     ## 从音频文件读取
     
     该AEAudioFileLoaderOperation类提供了一种简单的方法，以音频文件加载到内存中。由核心音频子系统支持的所有音频格式的支持，并且音频被自动转换成您所选择的音频格式。
 
 The AEAudioFileLoaderOperation class provides an easy way to load audio files into memory. All audio formats that
 are supported by the Core Audio subsystem are supported, and audio is converted automatically into the audio
 format of your choice.
 
    #类是一个NSOperation子类，这意味着它可以异步使用运行NSOperationQueue。另外，您也可以通过调用使用它以同步的方式start直接：
 The class is an `NSOperation` subclass, which means that it can be run asynchronously using an `NSOperationQueue`.
 Alternatively, you can use it in a synchronous fashion by calling `start` directly:
 
 @code
 AEAudioFileLoaderOperation *operation = [[AEAudioFileLoaderOperation alloc] initWithFileURL:url 
                                                                      targetAudioDescription:audioDescription];
 [operation start];
 
 if ( operation.error ) {
    // Load failed! Clean up, report error, etc.
    return;
 }

 _audio = operation.bufferList;
 _lengthInFrames = operation.lengthInFrames;
 @endcode
        

        #请注意，此类加载整个音频文件到存储器，并且不支持非常大的音频文件流。对于这一点，你需要使用ExtAudioFile直接的服务。
 Note that this class loads the entire audio file into memory, and doesn't support streaming of very large
 audio files. For that, you will need to use the `ExtAudioFile` services directly.
 

 
 
        *******************      写入音频文件     **********************
        #该AEAudioFileWriter类让您轻松写入系统支持的任何音频文件格式。
 The AEAudioFileWriter class allows you to easily write to any audio file format supported by the system.
 
 
        #要使用它，使用它实例化initWithAudioDescription： ，传递您希望使用的音频格式。然后，通过调用开始操作的fileType：错误：beginWritingToFileAtPath，传递路径，你想记录到文件中，并使用的文件类型。常见的文件类型包括kAudioFileAIFFType，kAudioFileWAVEType，kAudioFileM4AType（使用AAC音频编码），和kAudioFileCAFType。
 
 
 

 To use it, instantiate it using @link AEAudioFileWriter::initWithAudioDescription: initWithAudioDescription: @endlink,
 passing in the audio format you wish to use. Then, begin the operation by calling  
 @link AEAudioFileWriter::beginWritingToFileAtPath:fileType:error: beginWritingToFileAtPath:fileType:error: @endlink,
 passing in the path to the file you'd like to record to, and the file type to use. Common file types include
 `kAudioFileAIFFType`, `kAudioFileWAVEType`, `kAudioFileM4AType` (using AAC audio encoding), and `kAudioFileCAFType`.
    
        # 一旦写操作已经开始，你可以使用C函数AEAudioFileWriterAddAudio和AEAudioFileWriterAddAudioSynchronously写音频文件。请注意，您应该只使用AEAudioFileWriterAddAudio写从核心音频线音频时，因为这是在不托起线程异步的方式进行。
 Once the write operation has started, you use the C functions [AEAudioFileWriterAddAudio](@ref AEAudioFileWriter::AEAudioFileWriterAddAudio)
 and [AEAudioFileWriterAddAudioSynchronously](@ref AEAudioFileWriter::AEAudioFileWriterAddAudioSynchronously) to write audio
 to the file. Note that you should only use [AEAudioFileWriterAddAudio](@ref AEAudioFileWriter::AEAudioFileWriterAddAudio)
 when writing audio from the Core Audio thread, as this is done asynchronously in a way that does not hold up the thread.
 
        #   当您完成，请拨打finishWriting关闭文件。
 When you are finished, call [finishWriting](@ref AEAudioFileWriter::finishWriting) to close the file.
 

 
 
        *****************         管理音频缓冲器          ********************
 
 
        # AudioBufferList是音频的Core Audio的基本单元，代表音频的一小时间间隔。该结构包含一个或多个指针的存储器保持的音频样本的区域：对于被交错的声音，将有一个缓冲器保持交错样本所有通道，而对于非交错的声音会出现每个通道一个缓冲区。
 `AudioBufferList` is the basic unit of audio for Core Audio, representing a small time interval of audio. This
 structure contains one or more pointers to an area of memory holding the audio samples: For interleaved audio, there will
 be one buffer holding the interleaved samples for all channels, while for non-interleaved audio there will be one buffer
 per channel.
 
 
        #惊人的音频引擎提供了多项实用功能，用于处理音频缓冲列表：
 The Amazing Audio Engine provides a number of utility functions for dealing with audio buffer lists:
 
        # AEAudioBufferListCreate将采取AudioStreamBasicDescription帧和数目来分配，并且将分配和初始化一个音频缓冲器列表，并适当地对应的存储器缓冲器。
 - @link AEAudioBufferListCreate @endlink will take an `AudioStreamBasicDescription` and a number of frames to
   allocate, and will allocate and initialise an audio buffer list and the corresponding memory buffers appropriately.
 
        # AEAudioBufferListCreateOnStack创建堆栈上一个AudioBufferList变量，与缓冲器的数量设置适合于给定的音频描述
 - @link AEAudioBufferListCreateOnStack @endlink creates an AudioBufferList variable on the stack, with the number of
   buffers set appropriate to the given audio description
 
        # AEAudioBufferListCopy根据需要将复制现有音频缓冲器列表转换成一个新的，分配存储器。
 - @link AEAudioBufferListCopy @endlink will copy an existing audio buffer list into a new one, allocating memory as
   needed.
 
        # AEAudioBufferListFree将释放由音频缓冲器列表指向的存储器，和缓冲列表本身。
 - @link AEAudioBufferListFree @endlink will free the memory pointed to by an audio buffer list, and the buffer list
   itself.
 
        # AEAudioBufferListCopyOnStack将使堆栈上的现有缓冲器的副本（没有任何存储器分配），和任选地抵消MDATA指针; 这样做偏移缓冲区填满有用与写AudioBufferLists工具。
 - @link AEAudioBufferListCopyOnStack @endlink will make a copy of an existing buffer on the stack (without any
   memory allocation), and optionally offset its mData pointers; useful for doing offset buffer fills with utilities 
   that write to AudioBufferLists.
 
        # AEAudioBufferListGetLength将采取AudioStreamBasicDescription，并返回包含给定的音频缓冲器列表中的帧的数目mDataByteSize范围内的值。
 - @link AEAudioBufferListGetLength @endlink will take an `AudioStreamBasicDescription` and return the number
   of frames contained within the audio buffer list given the `mDataByteSize` values within.
 
        # AEAudioBufferListSetLength设置一个缓冲器表的mDataByteSize值，以对应于帧的给定数目。
 - @link AEAudioBufferListSetLength @endlink sets a buffer list's `mDataByteSize` values to correspond to
   the given number of frames.
 
        # AEAudioBufferListOffset递增缓冲器列表的mData由帧的给定数目的指针和递减mDataByteSize相应的值
 - @link AEAudioBufferListOffset @endlink increments a buffer list's `mData` pointers by the given number of frames,
   and decrements the `mDataByteSize` values accordingly.
 
        # AEAudioBufferListSilence清除在缓冲器列表（它们设置到零）的值。
 - @link AEAudioBufferListSilence @endlink clears the values in a buffer list (sets them to zero).
 
        # AEAudioBufferListGetStructSize返回AudioBufferList结构的大小，使用时的memcpy-ING缓冲区列表结构。
 - @link AEAudioBufferListGetStructSize @endlink returns the size of an AudioBufferList structure, for use when memcpy-ing buffer list structures.
 
        # 注意：不要使用执行内存分配或释放高于功能从核心音频线程内，因为这可能会导致性能问题。
 Note: Do not use those functions above that perform memory allocation or deallocation from within the Core Audio thread,
 as this may cause performance problems.
 
        #  此外，AEAudioBufferManager类可使用AudioBufferLists执行标准ARC /保留释放内存管理。
 Additionally, the AEAudioBufferManager class lets you perform standard ARC/retain-release memory management with
 AudioBufferLists.
 

 
 
        <<<<<<<<<<<<<<<<<<<<<<   定义音频格式    >>>>>>>>>>>>>>>>>>>>>>>>>>
    
        # 核心音频采用了AudioStreamBasicDescription用于描述各种音频采样的类型。惊人的音频引擎提供了一些实用程序与这些类型的工作：

 Core Audio uses the `AudioStreamBasicDescription` type for describing kinds of audio samples. The Amazing Audio Engine
 provides a number of utilities for working with these types:
    
 
        # 许多预定义的常见类
 - A number of pre-defined common types: 
    @link AEAudioStreamBasicDescriptionNonInterleavedFloatStereo @endlink,
    @link AEAudioStreamBasicDescriptionNonInterleaved16BitStereo @endlink and
    @link AEAudioStreamBasicDescriptionInterleaved16BitStereo @endlink.
 - @link AEAudioStreamBasicDescriptionMake @endlink, a method for creating custom types.       用于创建自定义类型的方法。
 - @link AEAudioStreamBasicDescriptionSetChannelsPerFrame @endlink, a method for easily modifying the number of channels of audio represented.
 
        用于容易地修改表示的音频的信道的数目的方法。
 
 
 
 
 
    *******************     提高利用向量运算效率    *******************
 
    # 矢量运算提供了加工效率超过大批标量运算的执行相同的操作幅度改进的订单。
 

 Vector operations offer orders of magnitude improvements in processing efficiency over performing the same operation
 as a large number of scalar operations.
 
 
        例如，以下面的代码，它计算的音频缓冲区内的最大绝对值：
 For example, take the following code which calculates the absolute maximum value within an audio buffer:
 
 
 
 @code
 float max = 0;
 for ( int i=0; i<frames; i++ ) {
    float value = fabs(((float*)audio->mBuffers[0].mData)[i]);
    if ( value > max ) max = value;
 }
 @endcode
 
 
        # 这包括帧处理的计算，随后的帧调用fabs，帧浮点比较，并且在最坏的情况下，帧的分配，随后帧整数增量。
 This consists of *frames* address calculations, followed by *frames* calls to `fabs`, *frames* floating-point comparisons, and at worst case,
 *frames* assignments, followed by *frames* integer increments.
 
 
        # 这可以通过单个载体操作来取代，使用加速框架：
 This can be replaced by a single vector operation, using the Accelerate framework:
 
 @code
 float max = 0;
 vDSP_maxmgv((float*)audio->mBuffers[0].mData, 1, &max, frames);
 @endcode
 
 
      # 对于那些浮点音频工作，这已经工作，但对于那些在多种音频格式的工作，需要一个额外的转换为浮点。
 For those working with floating-point audio, this already works, but for those working in other audio formats, an extra
 conversion to floating-point is required.
    
 #  如果您在使用只非交错的16位有符号整数，那么这可以很容易地使用进行vDSP_vflt16。否则，惊人的音频引擎提供了AEFloatConverter类与任何音频格式轻松地执行此操作：

 If you are using *only* non-interleaved 16-bit signed integers, then this can be performed easily, using `vDSP_vflt16`.
 Otherwise, The Amazing Audio Engine provides the AEFloatConverter class to perform this operation easily with any audio format:
 
 @code
 static const int kScratchBufferSize[4096];
 
 AudioBufferList *scratchBufferList
    = AEAudioBufferListCreate(AEAudioStreamBasicDescriptionNonInterleavedFloatStereo, kScratchBufferSize);

 
 ...
 
 self.floatConverter = [[AEFloatConverter alloc] initWithSourceFormat:_audioController.audioDescription];
 
 ...
 
 AEFloatConverterToFloatBufferList(THIS->_floatConverter, audio, THIS->_scratchBufferList, frames);
 // Now process the floating-point audio in 'scratchBufferList'.  处理这个 音频在scratchBufferList这个缓冲区内
 @endcode
 
 
 *************  线程同步    ************
 
    # 线程同步是非常困难的在最好的时候，但是当通过核心音频实时线程推出的时序约束都考虑到，这确实成为一个非常棘手的问题。
 Thread synchronization is notoriously difficult at the best of times, but when the timing constraints introduced by
 the Core Audio realtime thread are taken into account, this becomes a very tricky problem indeed.
 
 
    # 一个常见的​​解决方案是使用与尝试锁互斥体，使而不是阻塞的锁，核心音频线程只会将无法获取该锁，并且将中止操作。这可以工作，但始终运行在创建音频文物当它停止的时间间隔，而这恰恰是我们试图避免不堵问题产生音频的风险。
 A common solution is the use of mutexes with try-locks, so that rather than blocking on a lock, the Core Audio thread will 
 simply fail to acquire the lock, and will abort the operation. This can work, but always runs the risk of creating
 audio artefacts when it stops generating audio for a time interval, which is precisely the problem that we are trying
 to avoid by not blocking.
 
 
    # 这一切都可以用惊人的音频引擎的信息功能来避免。
 All this can be avoided with The Amazing Audio Engine's messaging feature.
 
    # 此实用程序允许主线程发送消息给核心音频线，反之亦然，而无需任何锁定。
 This utility allows the main thread to send messages to the Core Audio thread, and vice versa, without any locking
 required.
 
    # 要发送消息给核心音频线，使用
 To send a message to the Core Audio thread, use either
 @link AEAudioController::performAsynchronousMessageExchangeWithBlock:responseBlock: performAsynchronousMessageExchangeWithBlock:responseBlock: @endlink,
 or @link AEAudioController::performSynchronousMessageExchangeWithBlock: performSynchronousMessageExchangeWithBlock: @endlink:
 
 @code
 [_audioController performAsynchronousMessageExchangeWithBlock:^{
    // Do something on the Core Audio thread
 } responseBlock:^{
    // The thing above has been done, and now we're back on the main thread
 }];
 @endcode
 
 @code 
 [_audioController performSynchronousMessageExchangeWithBlock:^{
    // Do something on the Core Audio thread.
    // We will block on the main thread until this has been completed
 }];
 
 // Now the Core Audio thread finished doing whatever we asked it do, and we're back.
 @endcode
 
 
    # 从核心音频线将消息发送回主线程，你需要定义一个C回调，这需要通过定义的格式，AEMessageQueueMessageHandler，然后调用AEAudioControllerSendAsynchronousMessageToMainThread，传递一个引用任何参数，在字节参数的长度。
 To send messages from the Core Audio thread back to the main thread, you need to
 define a C callback, which takes the form defined by @link AEMessageQueueMessageHandler @endlink,
 then call @link AEAudioController::AEAudioControllerSendAsynchronousMessageToMainThread AEAudioControllerSendAsynchronousMessageToMainThread @endlink, passing a reference to
 any parameters, with the length of the parameters in bytes.
 
 @code
 struct _myHandler_arg_t { int arg1; int arg2; };
 static void myHandler(void *userInfo, int userInfoLength) {
    struct _myHandler_arg_t *arg = (struct _myHandler_arg_t*)userInfo;
    NSLog(@"On main thread; args are %d and %d", arg->arg1, arg->arg2);
 }
 
 ...
 
 // From Core Audio thread
 AEAudioControllerSendAsynchronousMessageToMainThread(THIS->_audioController,
                                                      myHandler,
                                                      &(struct _myHandler_arg_t) {
                                                        .arg1 = 1,
                                                        .arg2 = 2 },
                                                      sizeof(struct _myHandler_arg_t));
 @endcode
 
 Whatever is passed via the 'userInfo' parameter of
 @link AEAudioController::AEAudioControllerSendAsynchronousMessageToMainThread AEAudioControllerSendAsynchronousMessageToMainThread @endlink will be copied
 onto an internal buffer. A pointer to the copied item on the internal buffer will be passed to the
 callback you provide.
 
 **Note: This is an important distinction.** The bytes pointed to by the 'userInfo' parameter value are passed by *value*, not by reference.
 To pass a pointer to an instance of an Objective-C class, you need to pass the address to the pointer to copy using the "&" operator.
 
 This:
 
 @code
 AEAudioControllerSendAsynchronousMessageToMainThread(THIS->_audioController,
                                                      myHandler,
                                                      &object,
                                                      sizeof(id) },
 @endcode
 
 Not this:

 @code
 AEAudioControllerSendAsynchronousMessageToMainThread(THIS->_audioController,
                                                      myHandler,
                                                      object,
                                                      sizeof(id) },
 @endcode
 
 To access an Objective-C object pointer from the main thread handler function, you can bridge a 
 dereferenced `void**` to your object type, like this:

 @code
 MyObject *object = (__bridge MyObject*)*(void**)userInfo;
 @endcode
  
 @section Timing-Receivers Receiving Time Cues
 
 For certain applications, it's important that events take place at a precise time. `NSTimer` and the `NSRunLoop` scheduling
 methods simply can't do the job when it comes to millisecond-accurate timing, which is why The Amazing Audio Engine
 provides support for receiving time cues.
 
 [Audio receivers](@ref Receiving-Audio), [channels](@ref Creating-Audio) and [filters](@ref Filtering) all receive and
 can act on audio timestamps, but there are some cases where it makes more sense to have a separate class handle the
 timing and synchronization.
 
 In that case, you can implement the @link AEAudioTimingReceiver @endlink protocol and add your class as a timing receiver
 via [addTimingReceiver:](@ref AEAudioController::addTimingReceiver:).  The callback you provide will be called from
 two contexts: When input is received (@link AEAudioTimingContextInput @endlink), and when output is about to be
 generated (@link AEAudioTimingContextOutput @endlink). In both cases, the timing receivers will be notified before
 any of the audio receivers or channels are invoked, so that you can set app state that will affect the current time interval.
 
 @subsection Scheduling Scheduling Events
 
 AEBlockScheduler is a class you can use to schedule blocks for execution at a particular time. This implements the
 @link AEAudioTimingReceiver @endlink protocol, and provides an interface for scheduling blocks with sample-level
 accuracy.
 
 To use it, instantiate AEBlockScheduler, add it as a timing receiver with [addTimingReceiver:](@ref AEAudioController::addTimingReceiver:),
 then begin scheduling events using
 @link AEBlockScheduler::scheduleBlock:atTime:timingContext:identifier: scheduleBlock:atTime:timingContext:identifier: @endlink:
 
 @code
 self.scheduler = [[AEBlockScheduler alloc] initWithAudioController:_audioController];
 [_audioController addTimingReceiver:_scheduler];
 
 ...
 
 [_scheduler scheduleBlock:^(const AudioTimeStamp *time, UInt32 offset) {
    // We are now on the Core Audio thread at *time*, which is *offset* frames
    // before the time we scheduled, *timestamp*.
                           }
                  atTime:timestamp
            timingContext:AEAudioTimingContextOutput
               identifier:@"my event"];
 @endcode
 
 The block will be passed the current time, and the number of frames offset between the current time
 and the scheduled time.
 
 The alternate scheduling method, @link AEBlockScheduler::scheduleBlock:atTime:timingContext:identifier:mainThreadResponseBlock: scheduleBlock:atTime:timingContext:identifier:mainThreadResponseBlock: @endlink,
 allows you to provide a block that will be called on the main thread after the schedule has completed.
 
 There are a number of utilities you can use to construct and calculate timestamps, including
 [now](@ref AEBlockScheduler::now), [timestampWithSecondsFromNow:](@ref AEBlockScheduler::timestampWithSecondsFromNow:), 
 [hostTicksFromSeconds:](@ref AEBlockScheduler::hostTicksFromSeconds:) and
 [secondsFromHostTicks:](@ref AEBlockScheduler::secondsFromHostTicks:).
 
@page Contributing Contributing
 
 Want to help develop The Amazing Audio Engine, or some new modules?
 
 Fantastic!
 
 You can fork the [GitHub repository](https://github.com/TheAmazingAudioEngine/TheAmazingAudioEngine), and submit pull requests to
 suggest changes.
 
 Alternatively, if you've got a module you'd like to make available, but you'd like to self-host it, let us know on the
 [forum](http://forum.theamazingaudioengine.com).
 
 
 */

#ifdef __cplusplus
}
#endif

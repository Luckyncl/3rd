//
//  AEUtilities.m
//  The Amazing Audio Engine
//
//  Created by Michael Tyson on 23/03/2012.
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

#import "AEUtilities.h"
#import <mach/mach_time.h>

static double __hostTicksToSeconds = 0.0;
static double __secondsToHostTicks = 0.0;


AudioBufferList *AEAudioBufferListCreate(AudioStreamBasicDescription audioFormat, int frameCount) {
    
    int numberOfBuffers = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved ? audioFormat.mChannelsPerFrame : 1;
//     why numberOfBuffer  这样确定  是由于 kAudioFormatFlagIsNonInterleaved 这个字段所代表的的意义不同 非交叉

//    ASBD 代表 AudioStreamBasicDescription 结构体
/*
     通常，当使用ASBD时，这些字段描述完整的布局
                         本说明书所表示的缓冲区中的样本数据 -
                         通常这些缓冲区由一个AudioBuffer表示
                         包含在一个AudioBufferList中。
     
                         但是，当ASBD具有kAudioFormatFlagIsNonInterleaved标志时，
                         AudioBufferList具有不同的结构和语义。在这种情况下，ASBD
                         字段将描述包含在其中的一个AudioBuffers的格式
                         该列表，并且列表中的每个AudioBuffer被确定为具有单个（单声道）
                         音频数据的通道。然后，ASBD的mChannelsPerFrame将指示
                         AudioBufferList中包含的AudioBuffers总数 -
                         每个缓冲区包含一个通道。这主要用于
                         这个列表的AudioUnit（和AudioConverter）表示 - 并且不会被发现
                         在这个结构的AudioHardware使用
     
*/
// ***** 重要    猜测 NoInterleaved 字面翻译为 非交叉 代表着 音频 左右声道  由不同的缓冲区处理， 所以 当ASBD 中mFormatFlags代表的字段值 为 kAudioFormatFlagIsNonInterleaved
    /*
        每个缓冲区 通道数
     */
    int channelsPerBuffer = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved ? 1 : audioFormat.mChannelsPerFrame;
    /*
        生成的每个缓冲区的大小 为 音频流 每帧多少字节  乘以帧数
     */
    int bytesPerBuffer = audioFormat.mBytesPerFrame * frameCount;
    
    /*
     
     */
    AudioBufferList *audio = malloc(sizeof(AudioBufferList) + (numberOfBuffers-1)*sizeof(AudioBuffer));
    
    
    if ( !audio ) {
        return NULL;
    }
/*      设置    buffer个数   */
    audio->mNumberBuffers = numberOfBuffers;
    
    /*
     malloc（）和calloc（）函数都用于分配动态内存。每个运作与另一个略有不同。
     
     
     malloc（）和calloc（）函数都用于分配动态内存。每个运作与另一个略有不同。malloc（）需要一个大小，并返回一个指向大块内存的指针，至少是：
     void * malloc（size_t size）;
     calloc（）需要一些元素和每个元素的大小，并返回一个指向大块内存的指针
     ，至少足够大以容纳它们：
     void * calloc（size_t numElements，size_t sizeOfElement）;
     这两个功能之间有一个主要的区别和一个小的区别。主要区别是malloc（）不会初始化分配的内存。第一次malloc（）给你一个特定的内存块，内存可能是满的零。如果内存已经被分配，释放和重新分配，那么可能会有任何垃圾留在其中。
     *****
     不幸的是，一个程序可能运行在简单的情况下（当内存不再被重新分配时），但是当用得更难时（以及内存被重用时）会中断。
     *****
     这句话说的意思看了2遍还是吃不透....
     calloc（）用全零位填充分配的内存。这意味着任何你将要使用的字符或任何长度的符号或无符号的int保证为零。你将要用作指针的任何东西都被设置为全零位。
     这通常是一个空指针，但不能保证。任何你将要用作float或double的东西都被设置为全零位; 在某些类型的机器上这是一个浮点数零，但不是全部。
     两者之间的微小差别是calloc（）返回一个对象数组; malloc（）返回一个对象。有些人使用calloc（）来表明他们想要一个数组。
     */
    
    
    for ( int i=0; i<numberOfBuffers; i++ ) {
        if ( bytesPerBuffer > 0 ) {
            // 为 缓冲区列表中的 缓冲区 初始化一个 都为0 的内存
//            void    *calloc(size_t __count, size_t __size)
            audio->mBuffers[i].mData = calloc(bytesPerBuffer, 1);
            if ( !audio->mBuffers[i].mData ) {
                // 如果创建失败的话，就把所有的buffer 给手动释放
                for ( int j=0; j<i; j++ ) free(audio->mBuffers[j].mData);
                free(audio);
                return NULL;
            }
        } else {
            audio->mBuffers[i].mData = NULL;
        }
        audio->mBuffers[i].mDataByteSize = bytesPerBuffer;
        audio->mBuffers[i].mNumberChannels = channelsPerBuffer;
    }
    return audio;
}

AudioBufferList *AEAudioBufferListCopy(const AudioBufferList *original) {
    AudioBufferList *audio = malloc(sizeof(AudioBufferList) + (original->mNumberBuffers-1)*sizeof(AudioBuffer));
    if ( !audio ) {
        return NULL;
    }
    audio->mNumberBuffers = original->mNumberBuffers;
    for ( int i=0; i<original->mNumberBuffers; i++ ) {
        audio->mBuffers[i].mData = malloc(original->mBuffers[i].mDataByteSize);
        if ( !audio->mBuffers[i].mData ) {
            for ( int j=0; j<i; j++ ) free(audio->mBuffers[j].mData);
            free(audio);
            return NULL;
        }
        audio->mBuffers[i].mDataByteSize = original->mBuffers[i].mDataByteSize;
        audio->mBuffers[i].mNumberChannels = original->mBuffers[i].mNumberChannels;
        memcpy(audio->mBuffers[i].mData, original->mBuffers[i].mData, original->mBuffers[i].mDataByteSize);
    }
    return audio;
}


void AEAudioBufferListFree(AudioBufferList *bufferList ) {
    for ( int i=0; i<bufferList->mNumberBuffers; i++ ) {
        if ( bufferList->mBuffers[i].mData ) free(bufferList->mBuffers[i].mData);
    }
    free(bufferList);
}

UInt32 AEAudioBufferListGetLength(const AudioBufferList *bufferList,
                                  AudioStreamBasicDescription audioFormat,
                                  int *oNumberOfChannels) {
    int channelCount = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved
        ? bufferList->mNumberBuffers : bufferList->mBuffers[0].mNumberChannels;
    if ( oNumberOfChannels ) {
        *oNumberOfChannels = channelCount;
    }
    return bufferList->mBuffers[0].mDataByteSize / ((audioFormat.mBitsPerChannel/8) * channelCount);
}

void AEAudioBufferListSetLength(AudioBufferList *bufferList,
                                AudioStreamBasicDescription audioFormat,
                                UInt32 frames) {
    for ( int i=0; i<bufferList->mNumberBuffers; i++ ) {
        bufferList->mBuffers[i].mDataByteSize = frames * audioFormat.mBytesPerFrame;
    }
}

void AEAudioBufferListOffset(AudioBufferList *bufferList,
                             AudioStreamBasicDescription audioFormat,
                             UInt32 frames) {
    for ( int i=0; i<bufferList->mNumberBuffers; i++ ) {
        bufferList->mBuffers[i].mData = (char*)bufferList->mBuffers[i].mData + frames * audioFormat.mBytesPerFrame;
        bufferList->mBuffers[i].mDataByteSize -= frames * audioFormat.mBytesPerFrame;
    }
}

void AEAudioBufferListSilence(const AudioBufferList *bufferList,
                              AudioStreamBasicDescription audioFormat,
                              UInt32 offset,
                              UInt32 length) {
    for ( int i=0; i<bufferList->mNumberBuffers; i++ ) {
        memset((char*)bufferList->mBuffers[i].mData + offset * audioFormat.mBytesPerFrame,
               0,
               length ? length * audioFormat.mBytesPerFrame
                      : bufferList->mBuffers[i].mDataByteSize - offset * audioFormat.mBytesPerFrame);
    }
}

AudioStreamBasicDescription const AEAudioStreamBasicDescriptionNonInterleavedFloatStereo = {
    .mFormatID          = kAudioFormatLinearPCM,
    .mFormatFlags       = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved,
    .mChannelsPerFrame  = 2,
    .mBytesPerPacket    = sizeof(float),
    .mFramesPerPacket   = 1,
    .mBytesPerFrame     = sizeof(float),
    .mBitsPerChannel    = 8 * sizeof(float),
    .mSampleRate        = 44100.0,
};

AudioStreamBasicDescription const AEAudioStreamBasicDescriptionNonInterleaved16BitStereo = {
    .mFormatID          = kAudioFormatLinearPCM,
    .mFormatFlags       = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsNonInterleaved,
    .mChannelsPerFrame  = 2,
    .mBytesPerPacket    = sizeof(SInt16),
    .mFramesPerPacket   = 1,
    .mBytesPerFrame     = sizeof(SInt16),
    .mBitsPerChannel    = 8 * sizeof(SInt16),
    .mSampleRate        = 44100.0,
};

AudioStreamBasicDescription const AEAudioStreamBasicDescriptionInterleaved16BitStereo = {
    .mFormatID          = kAudioFormatLinearPCM,
    .mFormatFlags       = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked | kAudioFormatFlagsNativeEndian,
    .mChannelsPerFrame  = 2,
    .mBytesPerPacket    = sizeof(SInt16)*2,
    .mFramesPerPacket   = 1,
    .mBytesPerFrame     = sizeof(SInt16)*2,
    .mBitsPerChannel    = 8 * sizeof(SInt16),
    .mSampleRate        = 44100.0,
};

AudioStreamBasicDescription AEAudioStreamBasicDescriptionMake(AEAudioStreamBasicDescriptionSampleType sampleType,
                                                              BOOL interleaved,
                                                              int numberOfChannels,
                                                              double sampleRate) {
    int sampleSize = sampleType == AEAudioStreamBasicDescriptionSampleTypeFloat32 ? 4 :
                     sampleType == AEAudioStreamBasicDescriptionSampleTypeInt16 ? 2 :
                     sampleType == AEAudioStreamBasicDescriptionSampleTypeInt32 ? 4 : 0;
    NSCAssert(sampleSize, @"Unrecognized sample type");
    
    return (AudioStreamBasicDescription) {
        .mFormatID = kAudioFormatLinearPCM,
        .mFormatFlags = (sampleType == AEAudioStreamBasicDescriptionSampleTypeFloat32
                          ? kAudioFormatFlagIsFloat : kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian)
                        | kAudioFormatFlagIsPacked
                        | (interleaved ? 0 : kAudioFormatFlagIsNonInterleaved),
        .mChannelsPerFrame  = numberOfChannels,
        .mBytesPerPacket    = sampleSize * (interleaved ? numberOfChannels : 1),
        .mFramesPerPacket   = 1,
        .mBytesPerFrame     = sampleSize * (interleaved ? numberOfChannels : 1),
        .mBitsPerChannel    = 8 * sampleSize,
        .mSampleRate        = sampleRate,
    };
}

void AEAudioStreamBasicDescriptionSetChannelsPerFrame(AudioStreamBasicDescription *audioDescription, int numberOfChannels) {
    if ( !(audioDescription->mFormatFlags & kAudioFormatFlagIsNonInterleaved) ) {
        audioDescription->mBytesPerFrame *= (float)numberOfChannels / (float)audioDescription->mChannelsPerFrame;
        audioDescription->mBytesPerPacket *= (float)numberOfChannels / (float)audioDescription->mChannelsPerFrame;
    }
    audioDescription->mChannelsPerFrame = numberOfChannels;
}

AudioComponentDescription AEAudioComponentDescriptionMake(OSType manufacturer, OSType type, OSType subtype) {
    AudioComponentDescription description;
    memset(&description, 0, sizeof(description));
    description.componentManufacturer = manufacturer;
    description.componentType = type;
    description.componentSubType = subtype;
    return description;
}

void AETimeInit(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mach_timebase_info_data_t tinfo;
        mach_timebase_info(&tinfo);
        __hostTicksToSeconds = ((double)tinfo.numer / tinfo.denom) * 1.0e-9;
        __secondsToHostTicks = 1.0 / __hostTicksToSeconds;
    });
}

uint64_t AECurrentTimeInHostTicks(void) {
    return mach_absolute_time();
}

double AECurrentTimeInSeconds(void) {
    if ( !__hostTicksToSeconds ) AETimeInit();
    return mach_absolute_time() * __hostTicksToSeconds;
}

uint64_t AEHostTicksFromSeconds(double seconds) {
    if ( !__secondsToHostTicks ) AETimeInit();
    assert(seconds >= 0);
    return seconds * __secondsToHostTicks;
}

double AESecondsFromHostTicks(uint64_t ticks) {
    if ( !__hostTicksToSeconds ) AETimeInit();
    return ticks * __hostTicksToSeconds;
}

BOOL AERateLimit(void) {
    static double lastMessage = 0;
    static int messageCount=0;
    double now = AECurrentTimeInSeconds();
    if ( now-lastMessage > 1 ) {
        messageCount = 0;
        lastMessage = now;
    }
    if ( ++messageCount >= 10 ) {
        if ( messageCount == 10 ) {
            NSLog(@"TAAE: Suppressing some messages");
        }
        return NO;
    }
    return YES;
}


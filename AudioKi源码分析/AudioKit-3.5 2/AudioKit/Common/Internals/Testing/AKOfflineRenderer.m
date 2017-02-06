//
//  AKOfflineRenderer.m
//  AudioKit
/*
 struct AudioStreamBasicDescription
 {
 Float64             mSampleRate;   // 采样率
 AudioFormatID       mFormatID;            // 音频格式
 AudioFormatFlags    mFormatFlags;
 UInt32              mBytesPerPacket;       每一个数据包的字节数
 UInt32              mFramesPerPacket;      每一个数据包的帧数
 UInt32              mBytesPerFrame;        每一帧的字节数
 UInt32              mChannelsPerFrame;     // 1:单声道；2:立体声
 UInt32              mBitsPerChannel;        // 语音每采样点占用位数
 UInt32              mReserved;
 };
 
 
 
 
 
 
 /*!
 CF_ENUM(OSStatus)
 {
 kAudio_UnimplementedError     = -4,    未实现的核心程序
 kAudio_FileNotFoundError      = -43,   文件没有发现
 kAudio_FilePermissionError    = -54,   文件不能打开，没有沙河管理权限
 kAudio_TooManyFilesOpenError  = -42,   文件不能打开，由于有很多文件已经打开了
 kAudio_BadFilePathError       = '!pth', // 0x21707468, 561017960   路径错误
 kAudio_ParamError             = -50,          参数错误
 kAudio_MemFullError           = -108       没有那么多的内存可以使用
 };
 */



//  https://github.com/TheAmazingAudioEngine/TheAmazingAudioEngine
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "AKOfflineRenderer.h"

@implementation AKOfflineRenderer

- (instancetype)initWithEngine:(AVAudioEngine *)injun {
    self.engine = injun;
    return self;
}
- (void)render:(int)samples {
    // 获取核心引擎的输出节点
    AVAudioOutputNode *outputNode = self.engine.outputNode;
    // 得到音频流的描述（采样率等）
    AudioStreamBasicDescription const *audioDescription = [outputNode outputFormatForBus:0].streamDescription;
  
    NSUInteger lengthInFrames = (NSUInteger)samples;
    // 创建一个 512 的缓冲区
    const NSUInteger kBufferLength = 512;
    
   // 创建一个缓冲区列表
    AudioBufferList *bufferList = AEAudioBufferListCreate(*audioDescription, kBufferLength);
    
    AudioTimeStamp timeStamp;
    
//    1。void *memset(void *s,int c,size_t n)
//    　　总的作用：将已开辟内存空间 s 的首 n 个字节的值设为值 c。
    
    // 设置已开辟 的内存的内容 设置时间戳
    memset (&timeStamp, 0, sizeof(timeStamp));
    timeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    
    // OSStatus 32位的错误结果码
    OSStatus status = noErr;
    // 循环每一帧的缓冲区，然后进行渲染
    for (NSUInteger i = kBufferLength; i < lengthInFrames; i += kBufferLength) {
        status = [self renderToBufferList:bufferList bufferLength:kBufferLength timeStamp:&timeStamp];
        if (status != noErr)
            // 如果错误的话就
            break;
    }
    if (status == noErr && timeStamp.mSampleTime < lengthInFrames) {
        NSUInteger restBufferLength = (NSUInteger) (lengthInFrames - timeStamp.mSampleTime);
        AudioBufferList *restBufferList = AEAudioBufferListCreate(*audioDescription, (int)restBufferLength);
        status = [self renderToBufferList:restBufferList bufferLength:restBufferLength timeStamp:&timeStamp];
        AEAudioBufferListFree(restBufferList);
    }
}

/*       在缓冲区进行处理           */
- (OSStatus)renderToBufferList:(AudioBufferList *)bufferList
                  bufferLength:(NSUInteger)bufferLength
                     timeStamp:(AudioTimeStamp *)timeStamp {
    [self clearBufferList:bufferList];
    AudioUnit outputUnit = self.engine.outputNode.audioUnit;
    OSStatus status = AudioUnitRender(outputUnit, 0, timeStamp, 0, (int)bufferLength, bufferList);
    if (status != noErr) {
        NSLog(@"Can not render audio unit %d", (int)status);
        return status;
    }
    timeStamp->mSampleTime += bufferLength;
    return status;
}

/*                      */
- (void)clearBufferList:(AudioBufferList *)bufferList {
    for (int bufferIndex = 0; bufferIndex < bufferList->mNumberBuffers; bufferIndex++) {
        memset(bufferList->mBuffers[bufferIndex].mData, 0, bufferList->mBuffers[bufferIndex].mDataByteSize);
    }
}


/*         创建一个缓冲区，audiostreambascription 用于描述音频格式的   frameCount 指的是音频帧的数量          */
AudioBufferList *AEAudioBufferListCreate(AudioStreamBasicDescription audioFormat, int frameCount) {
    
    // 获取缓冲区的数量
    int numberOfBuffers = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved ? audioFormat.mChannelsPerFrame : 1;
    
    
    // 每一个缓冲区的通道数
    int channelsPerBuffer = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved ? 1 : audioFormat.mChannelsPerFrame;
    
    // 获取每一个缓冲区的字节数
    int bytesPerBuffer = audioFormat.mBytesPerFrame * frameCount;
    
    
    // 创建一个缓冲区  (类型说明符*) malloc (size) 功能：在内存的动态存储区中分配一块长度为"size" 字节的连续区域。函数的返回值为该区域的首地址
//    calloc 也用于分配内存空间。调用形式： (类型说明符*)calloc(n,size) 功能：在内存动态存储区中分配n块长度为“size”字节的连续区域
    AudioBufferList *audio = malloc(sizeof(AudioBufferList) + (numberOfBuffers-1)*sizeof(AudioBuffer));
    if ( !audio ) {
        return NULL;
    }
    
    
    // mdata应该指的是 一个个的数据包
    audio->mNumberBuffers = numberOfBuffers;
    for ( int i=0; i<numberOfBuffers; i++ ) {
        if ( bytesPerBuffer > 0 ) {
            // 这里进行申请内存
            audio->mBuffers[i].mData = calloc(bytesPerBuffer, 1);
#pragma mark: - 内存错误的处理
           // 这里应该是  对申请内存 错误的处理，如果申请错误的话，就将申请错误的那些内存干掉
            if ( !audio->mBuffers[i].mData ) {
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

/*     释放缓冲区         */
void AEAudioBufferListFree(AudioBufferList *bufferList ) {
    for ( int i=0; i<bufferList->mNumberBuffers; i++ ) {
        if ( bufferList->mBuffers[i].mData ) free(bufferList->mBuffers[i].mData);
    }
    free(bufferList);
}

@end

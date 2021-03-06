//
//  AERecorder.m
//  TheAmazingAudioEngine
//
//  Created by Michael Tyson on 23/04/2012.
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

#import "AERecorder.h"
#import "AEMixerBuffer.h"
#import "AEAudioFileWriter.h"

#define kProcessChunkSize 8192

NSString * AERecorderDidEncounterErrorNotification = @"AERecorderDidEncounterErrorNotification";
NSString * kAERecorderErrorKey = @"error";

@interface AERecorder () {
    AudioBufferList *_buffer;
}
@property (nonatomic, strong) AEMixerBuffer *mixer;
@property (nonatomic, strong) AEAudioFileWriter *writer;
@end

@implementation AERecorder
@synthesize mixer = _mixer, writer = _writer, currentTime = _currentTime;
@dynamic path;

+ (BOOL)AACEncodingAvailable {
    return [AEAudioFileWriter AACEncodingAvailable];
}



/**
    实例化录音器
 */
- (id)initWithAudioController:(AEAudioController*)audioController {
    if ( !(self = [super init]) ) return nil;
    
    // 创建混音器 
    self.mixer = [[AEMixerBuffer alloc] initWithClientFormat:audioController.audioDescription];
    // 创建文件写入对象
    self.writer = [[AEAudioFileWriter alloc] initWithAudioDescription:audioController.audioDescription];
    
    if ( audioController.inputEnabled && audioController.audioInputAvailable && audioController.inputAudioDescription.mChannelsPerFrame != audioController.audioDescription.mChannelsPerFrame ) {
        
        // 设置
        [_mixer setAudioDescription:*AEAudioControllerInputAudioDescription(audioController) forSource:AEAudioSourceInput];
    }
    
    // 创建音频缓冲队列
    _buffer = AEAudioBufferListCreate(audioController.audioDescription, 0);
    
    return self;
}

-(void)dealloc {
    free(_buffer);
}


-(BOOL)beginRecordingToFileAtPath:(NSString *)path fileType:(AudioFileTypeID)fileType error:(NSError **)error {
    return [self beginRecordingToFileAtPath:path fileType:fileType bitDepth:16 channels:0 error:error];
}

- (BOOL)beginRecordingToFileAtPath:(NSString*)path fileType:(AudioFileTypeID)fileType bitDepth:(UInt32)bits error:(NSError**)error {
    return [self beginRecordingToFileAtPath:path fileType:fileType bitDepth:16 channels:0 error:error];
}

- (BOOL)beginRecordingToFileAtPath:(NSString*)path fileType:(AudioFileTypeID)fileType bitDepth:(UInt32)bits channels:(UInt32)channels error:(NSError**)error
{
    BOOL result = [self prepareRecordingToFileAtPath:path fileType:fileType bitDepth:bits channels:channels error:error];
    _recording = YES;
    return result;
}

- (BOOL)prepareRecordingToFileAtPath:(NSString*)path fileType:(AudioFileTypeID)fileType error:(NSError**)error {
    return [self prepareRecordingToFileAtPath:path fileType:fileType bitDepth:16 channels:0 error:error];
}

- (BOOL)prepareRecordingToFileAtPath:(NSString*)path fileType:(AudioFileTypeID)fileType bitDepth:(UInt32)bits error:(NSError**)error {
    return [self prepareRecordingToFileAtPath:path fileType:fileType bitDepth:16 channels:0 error:error];
}


/*   核心的方法       */
- (BOOL)prepareRecordingToFileAtPath:(NSString*)path fileType:(AudioFileTypeID)fileType bitDepth:(UInt32)bits channels:(UInt32)channels error:(NSError**)error
{
    _currentTime = 0.0;
    
    // 设置 转码器
    BOOL result = [_writer beginWritingToFileAtPath:path fileType:fileType bitDepth:bits channels:channels error:error];
    
    if ( result ) {
        // Initialize async writing   添加一个空的数据到文件中
        AECheckOSStatus(AEAudioFileWriterAddAudio(_writer, NULL, 0), "AEAudioFileWriterAddAudio");
    }
            /*  如果是有音频文件的话我们是不是可以直接打开然后添加呢  */
    return result;
}

void AERecorderStartRecording(__unsafe_unretained AERecorder* THIS) {
    THIS->_recording = YES;
}

void AERecorderStopRecording(__unsafe_unretained AERecorder* THIS) {
    THIS->_recording = NO;
}

- (void)finishRecording {
    _recording = NO;
    [_writer finishWriting];
}

-(NSString *)path {
    return _writer.path;
}

struct reportError_t { void *THIS; OSStatus result; };
static void reportError(void *userInfo, int length) {
    struct reportError_t *arg = userInfo;
    [((__bridge AERecorder*)arg->THIS) finishRecording];
    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain 
                                         code:arg->result
                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Error while saving audio: Code %d", @""), arg->result]}];
    [[NSNotificationCenter defaultCenter] postNotificationName:AERecorderDidEncounterErrorNotification
                                                        object:(__bridge id)arg->THIS
                                                      userInfo:@{kAERecorderErrorKey: error}];
}


/*
     接收音频的回调
 */
static void audioCallback(__unsafe_unretained AERecorder *THIS,
                          __unsafe_unretained AEAudioController *audioController,
                          void                     *source,
                          const AudioTimeStamp     *time,
                          UInt32                    frames,
                          AudioBufferList          *audio) {
    if ( !THIS->_recording ) return;
    
    
    //  添加混音节点  记录音频需要添加混音节点
    AEMixerBufferEnqueue(THIS->_mixer, source, audio, frames, time);

    // Let the mixer buffer provide the audio buffer    让混音器缓冲区提供音频缓冲区
    UInt32 bufferLength = kProcessChunkSize;   // 8192
    for ( int i=0; i<THIS->_buffer->mNumberBuffers; i++ ) {
        THIS->_buffer->mBuffers[i].mData = NULL;              //  首先清空录音的音频缓冲区
        THIS->_buffer->mBuffers[i].mDataByteSize = 0;
    }
    
    AEMixerBufferDequeue(THIS->_mixer, THIS->_buffer, &bufferLength, NULL);  // 填充录音缓冲区
    NSLog(@"记录中 -===  frames == %u === bufferLength === %u",frames,(unsigned int)bufferLength);
    if ( bufferLength > 0 ) {
        
        // 给当前的时间赋值
        THIS->_currentTime += AEConvertFramesToSeconds(audioController, bufferLength);
        // 将混音缓冲器的混音数据  写入文件中
        OSStatus status = AEAudioFileWriterAddAudio(THIS->_writer, THIS->_buffer, bufferLength);
        if ( status != noErr ) {
            THIS->_recording = NO;
            AEAudioControllerSendAsynchronousMessageToMainThread(audioController, 
                                                                 reportError, 
                                                                 &(struct reportError_t) { .THIS = (__bridge void*)THIS, .result = status },
                                                                 sizeof(struct reportError_t));
        }
    }
}

-(AEAudioReceiverCallback)receiverCallback {
    return audioCallback;
}

@end

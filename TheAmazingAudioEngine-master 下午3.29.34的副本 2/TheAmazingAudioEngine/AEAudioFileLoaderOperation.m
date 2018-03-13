//
//  AEAudioFileLoaderOperation.m
//  The Amazing Audio Engine
//
//  Created by Michael Tyson on 17/04/2012.
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

#import "AEAudioFileLoaderOperation.h"
#import "AEUtilities.h"

static const int kIncrementalLoadBufferSize = 4096;
static const int kMaxAudioFileReadSize = 16384;

@interface AEAudioFileLoaderOperation ()
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) AudioStreamBasicDescription targetAudioDescription;
@property (nonatomic, readwrite) AudioBufferList *bufferList;
@property (nonatomic, readwrite) UInt32 lengthInFrames;
@property (nonatomic, strong, readwrite) NSError *error;
@end

@implementation AEAudioFileLoaderOperation
@synthesize url = _url, targetAudioDescription = _targetAudioDescription, audioReceiverBlock = _audioReceiverBlock, completedBlock=_completedBlock, bufferList = _bufferList, lengthInFrames = _lengthInFrames, error = _error;

+ (BOOL)infoForFileAtURL:(NSURL*)url audioDescription:(AudioStreamBasicDescription*)audioDescription lengthInFrames:(UInt32*)lengthInFrames error:(NSError**)error {
    if ( audioDescription ) memset(audioDescription, 0, sizeof(AudioStreamBasicDescription));
    
    ExtAudioFileRef audioFile;
    OSStatus status;
    
    // Open file
    status = ExtAudioFileOpenURL((__bridge CFURLRef)url, &audioFile);
    if ( !AECheckOSStatus(status, "ExtAudioFileOpenURL") ) {
        if ( error ) *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status 
                                              userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn't open the audio file", @"")}];
        return NO;
    }
        
    if ( audioDescription ) {
        // Get data format
        UInt32 size = sizeof(AudioStreamBasicDescription);
        status = ExtAudioFileGetProperty(audioFile, kExtAudioFileProperty_FileDataFormat, &size, audioDescription);
        if ( !AECheckOSStatus(status, "ExtAudioFileGetProperty") ) {
            if ( error ) *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status 
                                                  userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn't read the audio file", @"")}];
            return NO;
        }
    }    
    
    if ( lengthInFrames ) {
        // Get length
        UInt64 fileLengthInFrames = 0;
        UInt32 size = sizeof(fileLengthInFrames);
        status = ExtAudioFileGetProperty(audioFile, kExtAudioFileProperty_FileLengthFrames, &size, &fileLengthInFrames);
        if ( !AECheckOSStatus(status, "ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames)") ) {
            ExtAudioFileDispose(audioFile);
            if ( error ) *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status 
                                                  userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn't read the audio file", @"")}];
            return NO;
        }
        *lengthInFrames = (UInt32)fileLengthInFrames;
    }
    
    ExtAudioFileDispose(audioFile);
    
    return YES;
}


// 实例化方法
-(id)initWithFileURL:(NSURL *)url targetAudioDescription:(AudioStreamBasicDescription)audioDescription {
    if ( !(self = [super init]) ) return nil;
    
    self.url = url;
    self.targetAudioDescription = audioDescription;
    
    return self;
}


-(void)main {
    ExtAudioFileRef audioFile;
    OSStatus status;
    
    // Open file  (__bridge CFURLRef)_url   将oc语言的url转换成 c语言的url
    status = ExtAudioFileOpenURL((__bridge CFURLRef)_url, &audioFile);
    if ( !AECheckOSStatus(status, "ExtAudioFileOpenURL") ) {
        self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status 
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn't open the audio file", @"")}];
        return;
    }
    
    // Get file data format  获取数据描述
    AudioStreamBasicDescription fileAudioDescription;
    UInt32 size = sizeof(fileAudioDescription);
    status = ExtAudioFileGetProperty(audioFile, kExtAudioFileProperty_FileDataFormat, &size, &fileAudioDescription);
    if ( !AECheckOSStatus(status, "ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat)") ) {
        ExtAudioFileDispose(audioFile);
        self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status 
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn't read the audio file", @"")}];
        return;
    }
    
    // Apply client format  应用 数据格式
    status = ExtAudioFileSetProperty(audioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(_targetAudioDescription), &_targetAudioDescription);
    if ( !AECheckOSStatus(status, "ExtAudioFileSetProperty(kExtAudioFileProperty_ClientDataFormat)") ) {
        ExtAudioFileDispose(audioFile);
        int fourCC = CFSwapInt32HostToBig(status);
        self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status 
                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Couldn't convert the audio file (error %d/%4.4s)", @""), status, (char*)&fourCC]}];
        return;
    }
    
    /*      如果目标每帧的通道数大于源文件的通道数     */
    if ( _targetAudioDescription.mChannelsPerFrame > fileAudioDescription.mChannelsPerFrame ) {
        // More channels in target format than file format - set up a map to duplicate channel
        SInt32 channelMap[_targetAudioDescription.mChannelsPerFrame];
        AudioConverterRef converter;
        AECheckOSStatus(ExtAudioFileGetProperty(audioFile, kExtAudioFileProperty_AudioConverter, &size, &converter),
                    "ExtAudioFileGetProperty(kExtAudioFileProperty_AudioConverter)");
        for ( int outChannel=0, inChannel=0; outChannel < _targetAudioDescription.mChannelsPerFrame; outChannel++ ) {
            channelMap[outChannel] = inChannel;
            if ( inChannel+1 < fileAudioDescription.mChannelsPerFrame ) inChannel++;
        }
        AECheckOSStatus(AudioConverterSetProperty(converter, kAudioConverterChannelMap, sizeof(SInt32)*_targetAudioDescription.mChannelsPerFrame, channelMap),
                    "AudioConverterSetProperty(kAudioConverterChannelMap)");



        //        Set this property’s value to NULL to force resynchronization of the converter’s output format with the file’s data format.
        //       将此属性的值设置为NULL，强制转换器输出格式与文件数据格式重新同步。
        CFArrayRef config = NULL;
        AECheckOSStatus(ExtAudioFileSetProperty(audioFile, kExtAudioFileProperty_ConverterConfig, sizeof(CFArrayRef), &config),
                    "ExtAudioFileSetProperty(kExtAudioFileProperty_ConverterConfig)");
    }
    
    // Determine length in frames (in original file's sample rate)    计算文件的大小
    UInt64 fileLengthInFrames;
    size = sizeof(fileLengthInFrames);
    status = ExtAudioFileGetProperty(audioFile, kExtAudioFileProperty_FileLengthFrames, &size, &fileLengthInFrames);
    if ( !AECheckOSStatus(status, "ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames)") ) {
        ExtAudioFileDispose(audioFile);
        self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status 
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn't read the audio file", @"")}];
        return;
    }
    
    // Calculate the true length in frames, given the original and target sample rates     计算转换以后的音频的帧数
    fileLengthInFrames = ceil(fileLengthInFrames * (_targetAudioDescription.mSampleRate / fileAudioDescription.mSampleRate));
    
    // Prepare buffers       准备缓冲区  2 个
    int bufferCount = (_targetAudioDescription.mFormatFlags & kAudioFormatFlagIsNonInterleaved) ? _targetAudioDescription.mChannelsPerFrame : 1;
    // channelsPerBuffer  == 1
    int channelsPerBuffer = (_targetAudioDescription.mFormatFlags & kAudioFormatFlagIsNonInterleaved) ? 1 : _targetAudioDescription.mChannelsPerFrame;
    // 创建一个缓冲区列表
    // 注意有接收 音频数据block的时候， 生成的缓冲区 是 4096 大小  为什么这样处理呢？
    //
    AudioBufferList *bufferList = AEAudioBufferListCreate(_targetAudioDescription, _audioReceiverBlock ? kIncrementalLoadBufferSize : (UInt32)fileLengthInFrames);
    if ( !bufferList ) {
        ExtAudioFileDispose(audioFile);
        self.error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENOMEM 
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Not enough memory to open file", @"")}];
        return;
    }
    
    /*
        创建了一个空的 音频换城区列表
     */
    AudioBufferList *scratchBufferList = AEAudioBufferListCreate(_targetAudioDescription, 0);
    
    // Perform read in multiple small chunks (otherwise ExtAudioFileRead crashes when performing sample rate conversion)
    UInt64 readFrames = 0;
    
    // 使用一个while循环进行处理
    while ( readFrames < fileLengthInFrames && ![self isCancelled] ) {
        
        if ( _audioReceiverBlock ) {    // 如果有接收函数
            memcpy(scratchBufferList, bufferList, sizeof(AudioBufferList)+(bufferCount-1)*sizeof(AudioBuffer));
            for ( int i=0; i<scratchBufferList->mNumberBuffers; i++ ) {
                scratchBufferList->mBuffers[i].mDataByteSize = (UInt32)MIN(kIncrementalLoadBufferSize * _targetAudioDescription.mBytesPerFrame,
                                                                   (fileLengthInFrames-readFrames) * _targetAudioDescription.mBytesPerFrame);
            }
        } else {
            for ( int i=0; i<scratchBufferList->mNumberBuffers; i++ ) {
                scratchBufferList->mBuffers[i].mNumberChannels = channelsPerBuffer;
                scratchBufferList->mBuffers[i].mData = (char*)bufferList->mBuffers[i].mData + readFrames*_targetAudioDescription.mBytesPerFrame;
                scratchBufferList->mBuffers[i].mDataByteSize = (UInt32)MIN(kMaxAudioFileReadSize, (fileLengthInFrames-readFrames) * _targetAudioDescription.mBytesPerFrame);
            }
        }
        
        // Perform read   准备开始读文件
        UInt32 numberOfPackets = (UInt32)(scratchBufferList->mBuffers[0].mDataByteSize / _targetAudioDescription.mBytesPerFrame);
        status = ExtAudioFileRead(audioFile, &numberOfPackets, scratchBufferList);
        
        if ( status != noErr ) {
            ExtAudioFileDispose(audioFile);
            int fourCC = CFSwapInt32HostToBig(status);
            self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status 
                                         userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Couldn't read the audio file (error %d/%4.4s)", @""), status, (char*)&fourCC]}];
            return;
        }
        
        if ( numberOfPackets == 0 ) {
            // Termination condition
            break;
        }
        
        if ( _audioReceiverBlock ) {
            _audioReceiverBlock(bufferList, numberOfPackets);
        }
        
        readFrames += numberOfPackets;
    }
    
    if ( _audioReceiverBlock ) {
        AEAudioBufferListFree(bufferList);
        bufferList = NULL;
    }
    
    free(scratchBufferList);
    
    // Clean up    关闭文件
    ExtAudioFileDispose(audioFile);
    
    if ( [self isCancelled] ) {
        if ( bufferList ) {
            for ( int i=0; i<bufferList->mNumberBuffers; i++ ) {
                free(bufferList->mBuffers[i].mData);
            }
            free(bufferList);
            bufferList = NULL;
        }
    } else {
        _bufferList = bufferList;
        _lengthInFrames = (UInt32)fileLengthInFrames;
    }

    if ( _completedBlock ) {
        _completedBlock();
    }
}

@end

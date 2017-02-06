//
//  AERecorder.h
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

#ifdef __cplusplus
extern "C" {
#endif

#import <Foundation/Foundation.h>
#import "TheAmazingAudioEngine.h"

extern NSString * AERecorderDidEncounterErrorNotification;
extern NSString * kAERecorderErrorKey;

/*!  记录实时的音频到磁盘
 * Recorder utility, used for recording live audio to disk
 *
 *  This can be used to record just the microphone input, or the output of the
 *  audio system, just one channel, or a combination of all three. Simply add an
 *  instance of this class as an audio receiver for the particular audio you wish
 *  to record, using AEAudioController's [addInputReceiver:](@ref AEAudioController::addInputReceiver:),
 *  [addOutputReceiver:](@ref AEAudioController::addOutputReceiver:),
 *  [addOutputReceiver:forChannel:](@ref AEAudioController::addOutputReceiver:forChannel:), etc, and all 
 *  streams will be mixed together and recorded.
 *
 *  See the sample app for a demonstration.
 */
@interface AERecorder : NSObject <AEAudioReceiver>

/*!
 * Determine whether AAC encoding is possible on this device
 */
+ (BOOL)AACEncodingAvailable;

/*!
 * Initialise
 *
 * @param audioController The Audio Controller
 */
- (id)initWithAudioController:(AEAudioController*)audioController;

/*!
 * Prepare and begin recording
 *
 *  Prepare to record, then start recording immediately, without
 *  needing to call AERecorderStartRecording
 *
 * @param path The path to record to
 * @param fileType The kind of file to create
 * @param error The error, if not NULL and if an error occurs
 * @return YES on success, NO on failure.
 */
- (BOOL)beginRecordingToFileAtPath:(NSString*)path fileType:(AudioFileTypeID)fileType error:(NSError**)error;
- (BOOL)beginRecordingToFileAtPath:(NSString*)path fileType:(AudioFileTypeID)fileType bitDepth:(UInt32)bits error:(NSError**)error;
- (BOOL)beginRecordingToFileAtPath:(NSString*)path fileType:(AudioFileTypeID)fileType bitDepth:(UInt32)bits channels:(UInt32)channels error:(NSError**)error;

/*!
 * Prepare to record
 *
 *  Prepare recording and set up internal data structures.
 *  When this method returns, the recorder is ready to record.
 *
 *  Start recording by calling AERecorderStartRecording. This allows
 *  you to record synchronously with other audio events.
 *
 * @param path The path to record to
 * @param fileType The kind of file to create
 * @param error The error, if not NULL and if an error occurs
 * @return YES on success, NO on failure.
 */
- (BOOL)prepareRecordingToFileAtPath:(NSString*)path fileType:(AudioFileTypeID)fileType error:(NSError**)error;
- (BOOL)prepareRecordingToFileAtPath:(NSString*)path fileType:(AudioFileTypeID)fileType bitDepth:(UInt32)bits error:(NSError**)error;
- (BOOL)prepareRecordingToFileAtPath:(NSString*)path fileType:(AudioFileTypeID)fileType bitDepth:(UInt32)bits channels:(UInt32)channels error:(NSError**)error;

/*!
 * Start recording
 *
 *  If you prepared recording by calling @link prepareRecordingToFileAtPath:fileType:error: @endlink,
 *  call this method to actually begin recording.
 *
 *  This is thread-safe and can be used from the audio thread.
 *
 * @param recorder The recorder
 */
void AERecorderStartRecording(AERecorder* recorder);

/*!
 * Stop recording
 *
 * Will stop from recording more data to file.  This does not close or flush the file, it only stops
 * any incoming audio from being written.  You can later call finishRecording, or call AERecorderStartRecording to
 * continue recording.
 *
 *  This is thread-safe and can be used from the audio thread.
 *
 * @param recorder The recorder
 */
void AERecorderStopRecording(AERecorder* recorder);


/*!
 * Finish recording and close file
        完成录音  生成文件
 */
- (void)finishRecording;

/*!
 * The path
 */
@property (nonatomic, strong, readonly) NSString *path;

/*!
 * Current recorded time in seconds
     当前记录的时间（只读）
 */
@property (nonatomic, readonly) double currentTime;

/*!
 * Current state of the recorder
    录音器的状态（只读）
 */
@property (nonatomic, readonly) BOOL recording;

@end

#ifdef __cplusplus
}
#endif

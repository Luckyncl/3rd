//
//  AEExpanderFilter.h
//  The Amazing Audio Engine
//
//  Created by Michael Tyson on 09/07/2011.
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

#define AEExpanderFilterRatioGateMode 0

    
/*!
 * @enum AEExpanderFilterPreset
        # 预设与扩张过滤器使用
 *  Presets to use with the expander filter
 *
 * @var AEExpanderFilterPresetNone 
 * No preset
 * @var AEExpanderFilterPresetSmooth
        
        一个使用平缓的声音设定的选项
 * A smooth-sounding preset with a gentle ratio
 
 
         使用八分之一的比特率 和 5ms 的设定
 * @var AEExpanderFilterPresetMedium
 * A medium-level preset with 1/8 ratio and 5ms attack
 
         设置为 1ms的 一个模式
 * @var AEExpanderFilterPresetPercussive
 * A gate-mode preset with 1ms attack, good for persussive audio
 */
typedef enum {
    AEExpanderFilterPresetNone=-1,
    AEExpanderFilterPresetSmooth=0, // 平滑
    AEExpanderFilterPresetMedium=1,
    AEExpanderFilterPresetPercussive=2
} AEExpanderFilterPreset;

/*!
 *  扩展/噪声  过滤器
 * An expander/noise gate filter
 *
 
            （作用  就是过滤噪声）
        这个类实现了扩张过滤器，从而降低了音频
           为了掩盖背景噪声设定的阈值之下的水平。
    This class implements an expander filter, which reduces audio
  levels beneath a set threshold in order to hide background noise.
 */
@interface AEExpanderFilter : NSObject <AEAudioFilter>

/*!
 * Initialise
 */
- (id)init;

/*!
 * Apply a preset
 */
- (void)assignPreset:(AEExpanderFilterPreset)preset;

/*!
        校准门槛
 * Calibrate the threshold
 
        这个方法 开启一个  校准模式，  监控 输入波形 和 设置的最高水平
   This method enters calibration mode, watching the input level
   and setting the threshold to the maximum level seen. 
 
        在获得本底噪声以前 用户应该保持沉默
 The user should be silent during this period, to get an accurate measure
   of the noise floor.
 *
 
        这个block  在校准完成以后执行
 * @param block Block to perform when calibration is complete
 */
- (void)startCalibratingWithCompletionBlock:(void (^)(void))block;

@property (nonatomic, assign) float ratio;              // 比特率
@property (nonatomic, assign) double threshold;          // 阈值
@property (nonatomic, assign) double hysteresis;         // 滞后
@property (nonatomic, assign) NSTimeInterval attack;
@property (nonatomic, assign) NSTimeInterval decay;      // 衰减时间

@end

#ifdef __cplusplus
}
#endif
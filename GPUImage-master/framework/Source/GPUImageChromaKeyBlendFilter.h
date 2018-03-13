#import "GPUImageTwoInputFilter.h"

/** Selectively replaces a color in the first image with the second image
 
        用第二张图像有选择地替换第一张图像中的颜色
 */
@interface GPUImageChromaKeyBlendFilter : GPUImageTwoInputFilter
{
    GLint colorToReplaceUniform, thresholdSensitivityUniform, smoothingUniform;
}

/** The threshold sensitivity controls how similar pixels need to be colored to be replaced
        阈值灵敏度控制相似像素需要如何着色才能被替换
 The default value is 0.3
 */
@property(readwrite, nonatomic) CGFloat thresholdSensitivity;

/** The degree of smoothing controls how gradually similar colors are replaced in the image
        平滑程度控制图像中逐渐相似的颜色被替换的程度
 The default value is 0.1
 */
@property(readwrite, nonatomic) CGFloat smoothing;

/** The color to be replaced is specified using individual red, green, and blue components (normalized to 1.0).
 
 The default is green: (0.0, 1.0, 0.0).
 
 @param redComponent Red component of color to be replaced
 @param greenComponent Green component of color to be replaced
 @param blueComponent Blue component of color to be replaced
 */
- (void)setColorToReplaceRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent;

@end

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface SimpleVideoFileFilterViewController : UIViewController
{
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
    NSTimer * timer;
    GPUImagePicture *sourcePicture;
    
    GPUImageAlphaBlendFilter *blendFilter;
    
    GPUImageView *imageView;
    
    GPUImageTransformFilter *filter1;
    GPUImageTransformFilter *filter2;
}

@property (retain, nonatomic) IBOutlet UILabel *progressLabel;
- (IBAction)updatePixelWidth:(id)sender;

@end

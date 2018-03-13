#import "SimpleVideoFileFilterViewController.h"
#import "ShowView.h"
@implementation SimpleVideoFileFilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"m4v"];
           sampleURL = [[NSBundle mainBundle] URLForResource:@"demo1" withExtension:@"mp4"];

    movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;
    movieFile.shouldRepeat = YES;
//    filter = [[GPUImagePixellateFilter alloc] init];
    filter = [[GPUImageChromaKeyBlendFilter alloc] init];
       [(GPUImageChromaKeyBlendFilter *)filter setColorToReplaceRed:0.0 green:1.0 blue:0.0];

 
//    filter = [[GPUImageChromaKeyFilter alloc] init];
//    [(GPUImageChromaKeyFilter *)filter setColorToReplaceRed:0.0 green:1.0 blue:0.0];
    
//    [[GPUImageChromaKeyFilter alloc] init];
//    filter = [[GPUImageUnsharpMaskFilter alloc] init];
    
 


    // Only rotate the video for display, leave orientation the same for recording
    
    GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(50, 90, self.view.bounds.size.width - 100, 150)];
    [self.view addSubview:imageView];
//    [imageView setImage:[UIImage imageNamed:@"u=1905472040,363557435&fm=27&gp=0.jpg"]];

    GPUImageView *gShowImgView = [[GPUImageView alloc] initWithFrame:CGRectMake(0 , 0, 100, 100)];
    
    [imageView addSubview:gShowImgView];

    
    
    GPUImageView *filterView = (GPUImageView *)imageView;
//    GPUImageView *filterView = (GPUImageView *)self.view;

    
    
    [filterView setBackgroundColorRed:1 green:0 blue:0 alpha:1];



    
    UIImage *inputImage = [UIImage imageNamed:@"IMG_0242.JPG"];
    sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    
 
    
    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    blendFilter.mix = 1.0;
    

    

    [movieFile addTarget:filter];
    // 图片加上 透明度
//    [sourcePicture addTarget:blendFilter];
//
//    // 视频加上混合
//     [filter addTarget:blendFilter];
//
//
//
//    [filter addTarget:gShowImgView];

    
    
  
    
    [sourcePicture addTarget:filter];

      [filter addTarget:filterView];
    
    [filter setInputSize:CGSizeMake(1080, 1920) atIndex:1];
    
    [filter setShouldSmoothlyScaleOutput:YES];
    [filter setInputSize:CGSizeMake(480, 480) atIndex:0];

    
    
    
    // 视频进行旋转
    [filter setInputRotation:kGPUImageRotateRight atIndex:0];  // 视频
//    [filter setOutputTextureOptions:(GPUTextureOptions)];
    [blendFilter addTarget:filterView];
 

    [blendFilter setInputSize:CGSizeMake(1080, 1920) atIndex:1];

    [blendFilter setInputSize:CGSizeMake(480, 480) atIndex:0];

    
    
    
    // In addition to displaying to the screen, write out a processed version of the movie to disk
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];

    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
    [blendFilter addTarget:movieWriter];

//     Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    movieWriter.shouldPassthroughAudio = YES;
    movieFile.audioEncodingTarget = movieWriter;
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];

    [movieWriter startRecording];
    
    
      [sourcePicture processImage];
    [movieFile startProcessing];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                             target:self
                                           selector:@selector(retrievingProgress)
                                           userInfo:nil
                                            repeats:YES];
    
    [movieWriter setCompletionBlock:^{
        [blendFilter removeTarget:movieWriter];
        [movieWriter finishRecording];

        dispatch_async(dispatch_get_main_queue(), ^{
            [timer invalidate];
            self.progressLabel.text = @"100%";
        });
    }];
}

- (void)retrievingProgress
{
//    GPUImageChromaKeyBlendFilter *filters = (GPUImageChromaKeyBlendFilter *)filter;
//     NSLog(@"=====%ld",filters.);
    self.progressLabel.text = [NSString stringWithFormat:@"%d%%", (int)(movieFile.progress * 100)];
}

- (void)viewDidUnload
{
    [self setProgressLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)updatePixelWidth:(id)sender
{
//    [(GPUImageUnsharpMaskFilter *)filter setIntensity:[(UISlider *)sender value]];
//    [(GPUImagePixellateFilter *)filter setFractionalWidthOfAPixel:[(UISlider *)sender value]];
    
    [(GPUImageChromaKeyBlendFilter *)filter setThresholdSensitivity:[(UISlider *)sender value]];
    
//    [(GPUImageChromaKeyFilter *)filter setThresholdSensitivity:[(UISlider *)sender value]];

    
}

- (void)dealloc {
    [_progressLabel release];
    [super dealloc];
}
@end

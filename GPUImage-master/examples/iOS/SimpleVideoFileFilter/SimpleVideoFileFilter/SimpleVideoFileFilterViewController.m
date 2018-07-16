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
           sampleURL = [[NSBundle mainBundle] URLForResource:@"WeChatSight4" withExtension:@"mp4"];

    movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;
    movieFile.shouldRepeat = YES;
    
//    [movieFile forceProcessingAtSize:CGSizeMake([], <#CGFloat height#>)];
//    filter = [[GPUImagePixellateFilter alloc] init];
//    filter = [[GPUImageChromaKeyBlendFilter alloc] init];
//       [(GPUImageChromaKeyBlendFilter *)filter setColorToReplaceRed:0.0 green:0.0 blue:1.0];


    filter = [[GPUImageChromaKeyFilter alloc] init];
    [(GPUImageChromaKeyFilter *)filter setColorToReplaceRed:0.0 green:0.0 blue:1.0];
    



    // Only rotate the video for display, leave orientation the same for recording
    
    imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 90,self.view.bounds.size.width, self.view.bounds.size.width/16.*9)];
    [self.view addSubview:imageView];
//    [imageView setImage:[UIImage imageNamed:@"u=1905472040,363557435&fm=27&gp=0.jpg"]];

//    GPUImageView *gShowImgView = [[GPUImageView alloc] initWithFrame:CGRectMake(0 , 0, 100, 100)];
//
//    [imageView addSubview:gShowImgView];


    GPUImageView *filterView = (GPUImageView *)imageView;
    [filterView setBackgroundColorRed:1 green:0 blue:0 alpha:1];

    UIImage *inputImage = [UIImage imageNamed:@"IMG_0242.JPG"];
    sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];

    blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    blendFilter.mix = 1.0;
//
    filter2 = [[GPUImageTransformFilter alloc] init];


    CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
    [filter2 setAffineTransform:transform];
    
    filter1 = [[GPUImageTransformFilter alloc] init];
    [filter1 setAffineTransform:transform];
    
   [sourcePicture addTarget:blendFilter ];

    [movieFile addTarget:filter1 ];
    [filter1 addTarget:filter];
    [filter addTarget:blendFilter];
    [blendFilter addTarget:filter2];
    
    
    

    CGSize size =  [imageView sizeInPixels];
    
    [filter1 forceProcessingAtSize:CGSizeMake(size.height /9.*16, size.height)];
    
    
    [filter forceProcessingAtSize:CGSizeMake(size.height /9.*16, size.height)];
    
    [blendFilter forceProcessingAtSize:CGSizeMake(size.height /9.*16, size.height)];
//
//    [blendFilter addTarget:filter2 atTextureLocation:0];
//    [blendFilter addTarget:filter1 atTextureLocation:1];
  
    [filter2 addTarget:filterView];
    
 
    
//    [filterView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    
    
    // In addition to displaying to the screen, write out a processed version of the movie to disk
//    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
//    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
//    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
//
//    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
//    [blendFilter addTarget:movieWriter];
//
////     Configure this for video from the movie file, where we want to preserve all video frames and audio samples
//    movieWriter.shouldPassthroughAudio = YES;
//    movieFile.audioEncodingTarget = movieWriter;
//    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
//
//    [movieWriter startRecording];
    
   
      [sourcePicture processImage];
  
       [movieFile startProcessing];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                             target:self
                                           selector:@selector(retrievingProgress)
                                           userInfo:nil
                                            repeats:YES];
    
//    [movieWriter setCompletionBlock:^{
//        [blendFilter removeTarget:movieWriter];
//        [movieWriter finishRecording];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [timer invalidate];
//            self.progressLabel.text = @"100%";
//        });
//    }];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
   static BOOL isSelected = NO;
    if (isSelected) {
        CGSize size =  [imageView sizeInPixels];
        //        [blendFilter forceProcessingAtSize:CGSizeMake(size.height /9*16 *0.75 *0.75 , size.height )];
        
        CGSize ssize = [sourcePicture outputImageSize];
        [sourcePicture forceProcessingAtSize:CGSizeMake(100 , 10)];
        CGAffineTransform transform = CGAffineTransformMakeScale(0.75, 0.75);
        [filter2 setAffineTransform:transform];

//        CGAffineTransform transformw = CGAffineTransformMakeScale(0.5, 0.5);
//        [filter1 setAffineTransform:transformw ];
        isSelected = NO;
    }else{
        CGSize size =  [imageView sizeInPixels];
//        [blendFilter forceProcessingAtSize:CGSizeMake(size.height /9.*16, size.height)];
        [sourcePicture forceProcessingAtSize:[sourcePicture outputImageSize]];

        
        CGAffineTransform transform = CGAffineTransformMakeScale(0.5, 0.5);
        [filter2 setAffineTransform:transform];
        isSelected = YES;
        
//        CGAffineTransform transformw = CGAffineTransformMakeScale(0.5, 0.5);
//        [filter1 setAffineTransform:transformw ];

    }

}


- (void)dealloc {
    [_progressLabel release];
    [super dealloc];
}
@end

#import "SimpleVideoFileFilterViewController.h"

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
           sampleURL = [[NSBundle mainBundle] URLForResource:@"demo" withExtension:@"mp4"];

    movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;
//    filter = [[GPUImagePixellateFilter alloc] init];
    filter = [[GPUImageChromaKeyBlendFilter alloc] init];
//    [[GPUImageChromaKeyFilter alloc] init];
//    filter = [[GPUImageUnsharpMaskFilter alloc] init];
    
//    [(GPUImageChromaKeyBlendFilter *)filter setColorToReplaceRed:0 green:0 blue:0];
  
//    [movieFile addTarget:filter];

    // Only rotate the video for display, leave orientation the same for recording
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:imageView];
//    [imageView setImage:[UIImage imageNamed:@"u=1905472040,363557435&fm=27&gp=0.jpg"]];

//    GPUImageView *filterView = (GPUImageView *)imageView;
    GPUImageView *filterView = (GPUImageView *)self.view;

    [filterView setBackgroundColorRed:0 green:0 blue:0 alpha:1];
//    [filterView setCurrentlyReceivingMonochromeInput:YES];
//    [filter addTarget:filterView];

    
    [movieFile addTarget:filter];
    [filter addTarget:filterView];


    // In addition to displaying to the screen, write out a processed version of the movie to disk
//    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
//    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
//    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
//
//    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
//    [filter addTarget:movieWriter];

    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
//    movieWriter.shouldPassthroughAudio = YES;
//    movieFile.audioEncodingTarget = movieWriter;
//    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
//
//    [movieWriter startRecording];
    [movieFile startProcessing];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                             target:self
                                           selector:@selector(retrievingProgress)
                                           userInfo:nil
                                            repeats:YES];
    
//    [movieWriter setCompletionBlock:^{
//        [filter removeTarget:movieWriter];
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
    
    
   

    
    
}

- (void)dealloc {
    [_progressLabel release];
    [super dealloc];
}
@end

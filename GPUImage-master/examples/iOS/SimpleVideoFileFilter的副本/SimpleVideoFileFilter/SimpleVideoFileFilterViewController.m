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
  
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"demo1" withExtension:@"mp4"];
//           sampleURL = [[NSBundle mainBundle] URLForResource:@"WeChatSight4" withExtension:@"mp4"];

    movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
//    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;
    movieFile.shouldRepeat = YES;

//    filter = [[GPUImageChromaKeyBlendFilter alloc] init];
//       [(GPUImageChromaKeyBlendFilter *)filter setColorToReplaceRed:0.0 green:0.0 blue:1.0];


    filter = [[GPUImageChromaKeyFilter alloc] init];
    [(GPUImageChromaKeyFilter *)filter setColorToReplaceRed:0.0 green:0.0 blue:1.0];
//



    // Only rotate the video for display, leave orientation the same for recording
//     只需旋转视频进行显示，让方向保持一致即可进行录制
    CGFloat imgWidth = self.view.bounds.size.width;
    
   
    imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 90,imgWidth, imgWidth/16*9)];
    [self.view addSubview:imageView];



    GPUImageView *filterView = (GPUImageView *)imageView;
    [filterView setBackgroundColorRed:1 green:0 blue:0 alpha:1];
    
    // 1041521453349_.pic_hd.jpg
    UIImage *inputImage = [UIImage imageNamed:@"1041521453349_.pic_hd.jpg"];

    sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:NO];

    blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    blendFilter.mix = 1.0;
//
    filter2 = [[GPUImageTransformFilter alloc] init];
    

    CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
    [filter2 setAffineTransform:transform];
    
    filter1 = [[GPUImageTransformFilter alloc] init];
      [filter1 setAffineTransform:transform];

//    [movieFile addTarget:filter1 ];
//    [filter1 addTarget:filter];
//    [filter addTarget:filterView];
//
////    [sourcePicture forceProcessingAtSize:CGSizeMake(480, 480)];
////    [sourcePicture useNextFrameForImageCapture];
//    [sourcePicture addTarget:filter ];
//    CGSize picSize = [(GPUImageChromaKeyBlendFilter *)filter outputFrameSize];
//
//    NSLog(@"图片源的宽为%d,高为%d",picSize.width, picSize.height);
//
    
    
        [sourcePicture addTarget:blendFilter];
    [movieFile addTarget:filter];
//    [movieFile setOutputTextureOptions:kGPUImageRotateRight];
 [filter addTarget:filter1];
   
    [filter1 addTarget:blendFilter];
//    [filter1 setInputRotation:kGPUImageRotateRight atIndex:0];

        [blendFilter addTarget:filterView];



      CGSize size =  [imageView sizeInPixels];
//    [filter forceProcessingAtSizeRespectingAspectRatio: CGSizeMake(size.height /9.*16, size.height) ];
//    [filterView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    
//    [filter addTarget:filter1 atTextureLocation:0];
    

    
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

//    [filter setInputSize:CGSizeMake(100, 100) atIndex:0];
//    [filter setInputSize:CGSizeMake(100, 50) atIndex:1];
    
//    CGSize ssize =  [imageView sizeInPixels];
//    [filter forceProcessingAtSize:CGSizeMake(imgWidth, 400)];

    
    
//    CGSize filter1Size = [filter1 outputFrameSize];
//
//    CGSize sizes;
//    sizes = [(GPUImageChromaKeyBlendFilter *)filter outputFrameSize];
    
//    [filterView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    
    
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
        
          UIImage *inputImage = [UIImage imageNamed:@"1041521453349_.pic_hd.jpg"];
        
                [movieFile cancelProcessing];
//        16:9
        [sourcePicture replaceTextureWithSubimage:[self imgWithType:YES withImg:inputImage]];
        
        [sourcePicture processImage];
        
//            [sourcePicture useNextFrameForImageCapture];

        
       
        //
        //
        sourcePicture = [[GPUImagePicture alloc] initWithImage:[self imgWithType:NO withImg:inputImage] smoothlyScaleOutput:YES];
        [self performSelector:@selector(startPlay) withObject:nil afterDelay:3.f];
        CGFloat imgWidth = self.view.bounds.size.width;
        [UIView animateWithDuration:1.5 animations:^{
            imageView.frame = CGRectMake(0, 90,imgWidth, imgWidth/16*9);
//            [filter forceProcessingAtSize:CGSizeMake(imgWidth *2, imgWidth/16*9*2)];
        }];
        
        
    
//            [filter forceProcessingAtSizeRespectingAspectRatio: CGSizeMake(size.height /9.*16, size.height) ];
//
//
//        CGSize ssize = [sourcePicture outputImageSize];
//        [sourcePicture forceProcessingAtSize:CGSizeMake(ssize.width *0.75, ssize.height*0.75)];
//        CGAffineTransform transform = CGAffineTransformMakeScale(0.75, 0.75);
//        [filter2 setAffineTransform:transform];
        [sourcePicture forceProcessingAtSize:CGSizeMake(480*2 , 360*2)];
        [sourcePicture forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(480*2 , 360*2)];
        CGAffineTransform transformw = CGAffineTransformMakeScale(1, 1);
        [filter1 setAffineTransform:transformw ];
        isSelected = NO;
    }else{
        CGSize size =  [imageView sizeInPixels];
//            [blendFilter forceProcessingAtSizeRespectingAspectRatio: CGSizeMake(size.height /3.*4, size.height) ];

           [movieFile cancelProcessing];
        UIImage *inputImage = [UIImage imageNamed:@"1041521453349_.pic_hd.jpg"];
        
        sourcePicture = [[GPUImagePicture alloc] initWithImage:[self imgWithType:NO withImg:inputImage] smoothlyScaleOutput:YES];
   
        //        4 : 3
        [sourcePicture replaceTextureWithSubimage:[self imgWithType:NO withImg:inputImage]];
   
//            [sourcePicture useNextFrameForImageCapture];
        [sourcePicture forceProcessingAtSize:CGSizeMake(480*2*0.75 , 360*2*0.75)];
        [sourcePicture forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(480*2*0.75 , 360*2*0.75)];

        
//            [sourcePicture processImage];
        
        CGFloat imgWidth = self.view.bounds.size.width;
        [UIView animateWithDuration:1.5 animations:^{
            imageView.frame = CGRectMake((imgWidth - (imgWidth/16*9/3*4))/2, 90,imgWidth/16*9/3*4, imgWidth/16*9);
//            [filter forceProcessingAtSize:CGSizeMake(imgWidth/16*9/3*4 *2, imgWidth/16*9 *2)];
        }];
        [self performSelector:@selector(startPlay) withObject:nil afterDelay:3.f];
//        CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
//        [filter2 setAffineTransform:transform];
        isSelected = YES;
        
        CGAffineTransform transformw = CGAffineTransformMakeScale(1, 0.75);
        [filter1 setAffineTransform:transformw ];
    }

}


- (void)startPlay{
    [movieFile startProcessing];
}




/*
   是不是16比9
 */
- (UIImage *)imgWithType:(BOOL)is16 withImg:(UIImage *)originalImg
{
    CGFloat scale = 1;
    CGFloat imgWidth = originalImg.size.width;
    CGFloat imgHeight = originalImg.size.height;
    CGRect rect = CGRectMake(0, 0, imgWidth, imgHeight);
    // 不管是 16：9
    if (is16 ) {
//        16 : 9     最短边适配的原则
        if (imgWidth/imgHeight > 16/9) {
//             按高计算
            rect = CGRectMake((imgWidth - imgHeight /9 *16)/2, 0, imgHeight /9 *16, imgHeight);
        }else{
            rect = CGRectMake(0, (imgHeight - imgWidth/16*9)/2, imgWidth , imgWidth /16*9);
        }
    }else {
        if (imgWidth/imgHeight > 4/3) {
            //             按高计算
            rect = CGRectMake((imgWidth - imgHeight /3 *4)/2, 0, imgHeight /3 *4, imgHeight);
        }else{
            rect = CGRectMake(0, (imgHeight - imgWidth/4*3)/2, imgWidth , imgWidth /4*3);
        }
    }
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [originalImg CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:scale orientation:UIImageOrientationUp];
    return newImage;
}





- (void)dealloc {
    [_progressLabel release];
    [super dealloc];
}
@end

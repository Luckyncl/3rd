//
//  MusicSlider.m
//  Aufree
//
//  Created by Aufree on 11/7/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//

#import "MusicSlider.h"

@implementation MusicSlider

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    UIImage *thumbImage = [UIImage imageNamed:@"music_slider_circle"];
    [self setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [self setThumbImage:thumbImage forState:UIControlStateNormal];
}

// 实际上这里有没有都无所谓了
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    rect.origin.x = rect.origin.x - 10 ;
    rect.size.width = rect.size.width + 20;
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 , 10);
}

@end

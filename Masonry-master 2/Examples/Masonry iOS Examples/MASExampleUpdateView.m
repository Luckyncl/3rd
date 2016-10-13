//
//  MASExampleUpdateView.m
//  Masonry iOS Examples
//
//  Created by Jonas Budelmann on 3/11/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "MASExampleUpdateView.h"

@interface MASExampleUpdateView ()

@property (nonatomic, strong) UIButton *growingButton;
@property (nonatomic, assign) CGSize buttonSize;

@end

@implementation MASExampleUpdateView

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.growingButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.growingButton setTitle:@"Grow Me!" forState:UIControlStateNormal];
    self.growingButton.layer.borderColor = UIColor.greenColor.CGColor;
    self.growingButton.layer.borderWidth = 3;

    [self.growingButton addTarget:self action:@selector(didTapGrowButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.growingButton];

    self.buttonSize = CGSizeMake(100, 100);

    return self;
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {

    [self.growingButton updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        
        
//          当改变自身的约束的时候，设置一下自己的优先级
    
//        
//     设置宽高的低优先级  为什么先设置第优先级
        make.width.equalTo(@(self.buttonSize.width)).priorityLow();
        make.height.equalTo(@(self.buttonSize.height)).priorityLow();
        make.width.lessThanOrEqualTo(self);
        make.height.lessThanOrEqualTo(self);
    }];
    
    //according to apple super should be called at end of method
    [super updateConstraints];
}

- (void)didTapGrowButton:(UIButton *)button {
    
    //   在这里改变了 大小
    self.buttonSize = CGSizeMake(self.buttonSize.width * 0.8, self.buttonSize.height * 0.8);

    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

        // 注意这里可以使变化变得平缓一些
    [UIView animateWithDuration:0.4 animations:^{
        [self layoutIfNeeded];
    }];
}





@end

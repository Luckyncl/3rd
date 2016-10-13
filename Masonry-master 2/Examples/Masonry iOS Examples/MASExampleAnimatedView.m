//
//  MASExampleAnimatedView.m
//  Masonry iOS Examples
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//


// Basic Animated  简单的动画

#import "MASExampleAnimatedView.h"

@interface MASExampleAnimatedView ()

@property (nonatomic, strong) NSMutableArray *animatableConstraints;  // 动画约束的数组
@property (nonatomic, assign) int padding;                            // 间隔
@property (nonatomic, assign) BOOL animating;                         // 动画

@end

@implementation MASExampleAnimatedView

- (id)init {
    self = [super init];
    if (!self) return nil;

    UIView *greenView = UIView.new;
    greenView.backgroundColor = UIColor.greenColor;
    greenView.layer.borderColor = UIColor.blackColor.CGColor;
    greenView.layer.borderWidth = 2;
    [self addSubview:greenView];

    UIView *redView = UIView.new;
    redView.backgroundColor = UIColor.redColor;
    redView.layer.borderColor = UIColor.blackColor.CGColor;
    redView.layer.borderWidth = 2;
    [self addSubview:redView];

    UIView *blueView = UIView.new;
    blueView.backgroundColor = UIColor.blueColor;
    blueView.layer.borderColor = UIColor.blackColor.CGColor;
    blueView.layer.borderWidth = 2;
    [self addSubview:blueView];

    UIView *superview = self;
    int padding = self.padding = 10;
    UIEdgeInsets paddingInsets = UIEdgeInsetsMake(self.padding, self.padding, self.padding, self.padding);

    self.animatableConstraints = NSMutableArray.new;

    
    
    
    [greenView mas_makeConstraints:^(MASConstraintMaker *make) {
        [self.animatableConstraints addObjectsFromArray:@[
            make.edges.equalTo(superview).insets(paddingInsets).priorityLow(),
              make.bottom.equalTo(blueView.mas_top).offset(-padding),
        ]];
        
        make.size.equalTo(redView);                     // 设置等于红色大小
        make.height.equalTo(blueView.mas_height);       // 高度等于蓝色
    }];

    
    
    [redView mas_makeConstraints:^(MASConstraintMaker *make) {
        [self.animatableConstraints addObjectsFromArray:@[
            make.edges.equalTo(superview).insets(paddingInsets).priorityLow(),
            make.left.equalTo(greenView.mas_right).offset(padding),
            make.bottom.equalTo(blueView.mas_top).offset(-padding),
        ]];

        make.size.equalTo(greenView);
        make.height.equalTo(blueView.mas_height);
    }];

    
    
    [blueView mas_makeConstraints:^(MASConstraintMaker *make) {
        [self.animatableConstraints addObjectsFromArray:@[
            make.edges.equalTo(superview).insets(paddingInsets).priorityLow(),
        ]];

//        make.height.equalTo(greenView.mas_height);
//        make.height.equalTo(redView.mas_height);
    }];

    return self;
}


//
- (void)didMoveToWindow {
    [self layoutIfNeeded];

    if (self.window) {
        self.animating = YES;
        [self animateWithInvertedInsets:NO];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    self.animating = newWindow != nil;
}



- (void)animateWithInvertedInsets:(BOOL)invertedInsets {
    if (!self.animating) return;

    // frame 动画
    int padding = invertedInsets ? 100 : self.padding;
    UIEdgeInsets paddingInsets = UIEdgeInsetsMake(padding, padding, padding, padding);
    
    
    // 遍历
    for (MASConstraint *constraint in self.animatableConstraints) {
        constraint.insets = paddingInsets;
    }

    
    //   包在 uiview的动画里面是用于让动画变得不生硬
    [UIView animateWithDuration:1 animations:^{
        [self layoutIfNeeded];  // 重新布局
    } completion:^(BOOL finished) {
        //repeat!  进行重复动画
        [self animateWithInvertedInsets:!invertedInsets];
    }];
}


@end


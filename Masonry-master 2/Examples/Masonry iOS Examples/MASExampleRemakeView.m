//
//  MASExampleRemakeView.m
//  Masonry iOS Examples
//
//  Created by Sam Symons on 2014-06-22.
//  Copyright (c) 2014 Jonas Budelmann. All rights reserved.
//

#import "MASExampleRemakeView.h"

@interface MASExampleRemakeView ()

@property (nonatomic, strong) UIButton *movingButton;
@property (nonatomic, assign) BOOL topLeft;

- (void)toggleButtonPosition;

@end

@implementation MASExampleRemakeView

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    self.movingButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.movingButton setTitle:@"Move Me!" forState:UIControlStateNormal];
    self.movingButton.layer.borderColor = UIColor.greenColor.CGColor;
    self.movingButton.layer.borderWidth = 3;
    
    [self.movingButton addTarget:self action:@selector(toggleButtonPosition) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.movingButton];
    
    self.topLeft = YES;
    
    return self;
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

// this is Apple's recommended place for adding/updating constraints

//  这个方法调用了两次 所以不应在里面处理很多耗时操作
//  实际上这样写，只是 将处理逻辑集中在一起， 便于寻找 和 调试。
- (void)updateConstraints {
    
    //   当解除 一个约束 然后重新设置的时候 使用remake
    [self.movingButton remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(100));
        make.height.equalTo(@(100));
        
        if (self.topLeft) {
            make.left.equalTo(self.left).with.offset(10);
            make.top.equalTo(self.top).with.offset(10);
        }
        else {
            make.bottom.equalTo(self.bottom).with.offset(-10);
            make.right.equalTo(self.right).with.offset(-10);
        }
    }];
    
    //according to apple super should be called at end of method
    [super updateConstraints];
}

- (void)toggleButtonPosition {
    self.topLeft = !self.topLeft;
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];
    
    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self layoutIfNeeded];
    }];
}

@end

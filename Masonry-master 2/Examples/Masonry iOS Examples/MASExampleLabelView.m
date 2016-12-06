//
//  MASExampleLabelView.m
//  Masonry iOS Examples
//
//  Created by Jonas Budelmann on 24/10/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "MASExampleLabelView.h"

static UIEdgeInsets const kPadding = {50, 50, 50,50 };

@interface MASExampleLabelView ()

@property (nonatomic, strong) UILabel *shortLabel;
@property (nonatomic, strong) UILabel *longLabel;

@end

@implementation MASExampleLabelView

- (id)init {
    self = [super init];
    if (!self) return nil;

    // text courtesy of http://baconipsum.com/

    self.shortLabel = UILabel.new;
    self.shortLabel.numberOfLines = 0;
    self.shortLabel.textColor = [UIColor purpleColor];
    self.shortLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.shortLabel.text = @"短label 位于下label文字基准线已下";
    [self addSubview:self.shortLabel];

    
    self.longLabel = UILabel.new;
    self.longLabel.backgroundColor = [UIColor redColor];
    self.longLabel.numberOfLines = 0;
    self.longLabel.textColor = [UIColor darkGrayColor];
    self.longLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  
    [self addSubview:self.longLabel];
    
    UIView *superView = self;

    [self.longLabel makeConstraints:^(MASConstraintMaker *make) {
        
        //  注意能不能
//        make.width.lessThanOrEqualTo(superView);
//        make.width.priorityLow();
        make.left.equalTo(self.left).insets(kPadding);
        make.top.equalTo(self.top).insets(kPadding);
        make.right.equalTo(self.right).insets(kPadding);
    }];

    [self.shortLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.longLabel.bottom);
        make.right.equalTo(self.right).insets(kPadding);
    }];
    
    
      self.longLabel.text = @"Bacon ipsum dolor sit amet spare ribs fatback kielbasa salami, tri-tip jowl pastrami flank short loin rump sirloin. Tenderloin frankfurter chicken biltong rump chuck filet mignon pork t-bone flank ham hock.";
    // stay tuned for new easier way todo this coming soon to Masonry
  
//    self.longLabel.preferredMaxLayoutWidth = width;
//    [self setNeedsLayout];
//    [self.shortLabel setNeedsLayout];


    return self;
}


//- (void)layoutSubviews {
////    [super layoutSubviews];
//
//    
//        // 对于多行label来讲，需要设置prefreredMaxLayoutWidth
//    // for multiline UILabel's you need set the preferredMaxLayoutWidth
//    // you need to do this after [super layoutSubviews] as the frames will have a value from Auto Layout at this point
//
// 
//    
//    // need to layoutSubviews again as frames need to recalculated with preferredLayoutWidth
//    [super layoutSubviews];
//}

@end

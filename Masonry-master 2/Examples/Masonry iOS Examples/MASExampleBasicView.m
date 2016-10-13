//
//  MASExampleBasicView.m
//  Masonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MASExampleBasicView.h"

@implementation MASExampleBasicView

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    //  进行实例化
    UIView *greenView = UIView.new;
    greenView.backgroundColor = UIColor.greenColor;
    //   设置黑边
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
    int padding = 10;

    
//    - ==========    设置约束   =========== -
    //if you want to use Masonry without the mas_ prefix
    //define MAS_SHORTHAND before importing Masonry.h see Masonry iOS Examples-Prefix.pch
    [greenView makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.greaterThanOrEqualTo(superview.top).offset(padding);   // 距父上
        make.left.equalTo(superview.left).offset(padding);              // 距父左
        make.bottom.equalTo(blueView.top).offset(-padding);             // 距蓝
        make.right.equalTo(redView.left).offset(-padding);              // 距红右
        make.width.equalTo(redView.width);                              // 宽

        make.height.equalTo(redView.height);                            // 设置三个等高
        make.height.equalTo(blueView.height);
        
        
        
    }];

    
    
    //with is semantic and option
    [redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superview.mas_top).with.offset(padding); //with with
//        make.left.equalTo(greenView.mas_right).offset(padding); //without with
        make.bottom.equalTo(blueView.mas_top).offset(-padding);
        make.right.equalTo(superview.mas_right).offset(-padding);
//        make.width.equalTo(greenView.mas_width);
        
//        make.height.equalTo(@[greenView, blueView]); //can pass array of views
        
        
    }];
    
    [blueView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        

        make.left.equalTo(superview.mas_left).offset(padding);
        make.bottom.equalTo(superview.mas_bottom).offset(-padding);
        make.right.equalTo(superview.mas_right).offset(-padding);
//        make.height.equalTo(@[greenView.mas_height, redView.mas_height]); //can pass array of attributes
    }];

    return self;
}

@end

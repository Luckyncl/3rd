//
//  ViewController.m
//  SDWebImage框架源码注解-By文顶顶
//
//  Created by wendingding on 16/6/13.
//  Copyright © 2016年 文顶顶. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [_imageView sd_setImageWithURL:[NSURL URLWithString:@"http://img3.duitang.com/uploads/blog/201501/29/20150129203224_zKYkh.thumb.700_0.jpeg"] placeholderImage:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

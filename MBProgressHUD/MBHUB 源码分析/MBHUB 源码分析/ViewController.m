//
//  ViewController.m
//  MBHUB 源码分析
//
//  Created by Apple on 2016/12/7.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor redColor];
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[[MBProgressHUD alloc] initWithView:self.view] show:YES];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"进行了点击事件");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

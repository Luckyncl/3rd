//
//  ViewController.m
//  AFNReview
//
//  Created by Apple on 2018/7/16.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSLog(@"-=-thread-=-=%@",[NSThread currentThread]);
        
        sleep(1);
        dispatch_semaphore_signal(semaphore);
        
        NSLog(@"-=--=-=");

    });
    
    //  减少信号量的value值， 如果为-1，就等待，如果信号量值大于1 才可以执行后面的代码
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"-=-thread-=-=%@",[NSThread currentThread]);

    NSLog(@"dispatch_semaphore_wait");

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  ViewController.m
//  luckyTurntable
//
//  Created by huxuedong on 15/10/15.
//  Copyright © 2015年 huxuedong. All rights reserved.
//

#import "ViewController.h"
#import "HXDTurntableView.h"

@interface ViewController ()

@end

@implementation ViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置背景图片
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"LuckyBackground"].CGImage);
    //创建转盘
    HXDTurntableView *turnTableView = [HXDTurntableView turntableView];
    //设置转盘的位置
    turnTableView.center = self.view.center;
    //将转盘添加到控制器
    [self.view addSubview:turnTableView];
    //开始转动
    [turnTableView startRotation];
}

@end

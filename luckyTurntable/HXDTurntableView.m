//
//  HXDTurntableView.m
//  luckyTurntable
//
//  Created by huxuedong on 15/10/15.
//  Copyright © 2015年 huxuedong. All rights reserved.
//

#import "HXDTurntableView.h"
#define kButtonCount 12

@interface HXDTurntableView ()

@property (weak, nonatomic) IBOutlet UIImageView *rotateWheelImage;
@property (weak, nonatomic) UIButton *currentButton;
@property (strong, nonatomic) CADisplayLink *link;
@property (copy, nonatomic) NSString *luckyNumber;

@end

@implementation HXDTurntableView

//加载xib
+ (instancetype)turntableView {
    return [[NSBundle mainBundle] loadNibNamed:@"HXDTurntableView" owner:nil options:nil].lastObject;
}

//创建转盘中的按钮
- (void)awakeFromNib {
    for (int i = 0; i < kButtonCount; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.tag = i;
        //获取自然状态下的大图片
        UIImage *image = [UIImage imageNamed:@"LuckyAstrology"];
        //获取选中状态下的大图片
        UIImage *imagePressed = [UIImage imageNamed:@"LuckyAstrologyPressed"];
        //获取自然状态下的小图片
        image = [self clipImage:image withIndex:i];
        //获取选中状态下的小图片
        imagePressed = [self clipImage:imagePressed withIndex:i];
        [button setImage:image forState:UIControlStateNormal];
        [button setImage:imagePressed forState:UIControlStateSelected];
        //设置按钮中图片的内边距
        [button setImageEdgeInsets:UIEdgeInsetsMake(-50, 0, 0, 0)];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
        [self.rotateWheelImage addSubview:button];
    }
}

//剪切图片
- (UIImage *)clipImage:(UIImage *)image withIndex:(int)index {
    //根据不同分辨率的屏（缩放因子）计算相应的宽度
    CGFloat imageW = image.size.width / kButtonCount * [UIScreen mainScreen].scale;
    //根据不同分辨率的屏（缩放因子）计算相应的高度
    CGFloat imageH = image.size.height * [UIScreen mainScreen].scale;
    CGFloat imageX = index * imageW;
    CGFloat imageY = 0;
    //根据图片的区域创建新的ref图片
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(imageX, imageY, imageW, imageH));
    //根据缩放因子，把ref图片转换成普通图片
    return [UIImage imageWithCGImage:imageRef scale:2.5 orientation:UIImageOrientationUp];
}

//点击按钮执行
- (void)clickButton:(UIButton *)button {
    //设置当前的按钮不被选中
    self.currentButton.selected = NO;
    //设置点击的按钮被选中状态
    button.selected = YES;
    //设置当前按钮为被点击按钮
    self.currentButton = button;
}

//布局子控件
- (void)layoutSubviews {
    [super layoutSubviews];
    for (int i = 0; i < self.rotateWheelImage.subviews.count; i++) {
        UIButton *button = self.rotateWheelImage.subviews[i];
        CGFloat buttonW = 68;
        CGFloat buttonH = 143;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        CGFloat centerX = self.bounds.size.width * 0.5;
        CGFloat centerY = self.bounds.size.height * 0.5;
        button.center = CGPointMake(centerX, centerY);
        //设置锚点/定位点
        button.layer.anchorPoint = CGPointMake(0.5, 1);
        //设置每个按钮旋转的角度
        CGFloat angle = 2 * M_PI / kButtonCount;
        button.transform = CGAffineTransformMakeRotation(i * angle);
    }
}

//开始旋转
- (void)startRotation {
    //刷新，默认每秒刷新60次
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(rotate)];
    //将刷新添加到主循环
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.link = link;
}

//旋转
- (void)rotate {
    //设置旋转的角度为10秒钟转一圈
    self.rotateWheelImage.transform = CGAffineTransformRotate(self.rotateWheelImage.transform, 2 * M_PI / 60 / 10);
}

//点击开始选号执行
- (IBAction)pickNumberAction {
    //判断转盘是否有标识符为animation的动画
    if (![self.rotateWheelImage.layer animationForKey:@"animation"]) {
        //创建基本动画，改变的值为transform.rotation
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        //设置每个按钮要额外旋转的角度
        CGFloat angle = 2 * M_PI / kButtonCount * self.currentButton.tag;
        //设置动画的终点
        animation.toValue = @(2 * M_PI * 5 - angle);
        //设置动画的时间
        animation.duration = 3;
        //设置不回到初始位置
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        //将动画添加到转盘
        [self.rotateWheelImage.layer addAnimation:animation forKey:@"animation"];
        //延时方法
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animation.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //3秒钟转（5圈 - 额外的角度）
            self.rotateWheelImage.transform = CGAffineTransformMakeRotation([animation.toValue floatValue]);
            //移除动画
            [self.rotateWheelImage.layer removeAnimationForKey:@"animation"];
            //暂停刷新
            self.link.paused = YES;
            //创建提示框
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:self.luckyNumber delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        });
    }
}

//点击确认执行的方法
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.link.paused = NO;
}

//随机生成3个不同的幸运数字
- (NSString *)luckyNumber {
    int num1, num2, num3;
    num1 = arc4random_uniform(10) + 1;
    do {
        num2 = arc4random_uniform(10) + 1;
    } while (num1 == num2);
    do {
        num3 = arc4random_uniform(10) + 1;
    } while (num3 == num1 || num3 == num2);
    NSString *luckyNumber = [NSString stringWithFormat:@"您的幸运号码为：%d %d %d",num1,num2,num3];
    return luckyNumber;
}

@end

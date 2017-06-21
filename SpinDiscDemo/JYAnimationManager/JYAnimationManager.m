//
//  JYAnimationManager.m
//  SpinDiscDemo
//
//  Created by 纪宇伟 on 2017/6/12.
//  Copyright © 2017年 纪宇伟. All rights reserved.
//

#import "JYAnimationManager.h"

JYAnimationType const JYAnimationTypeRotaion   = @"animationRotation";
JYAnimationType const JYAnimationTypeScaleMove = @"animationScaleMove";
JYAnimationType const JYAnimationTypeFade      = @"animationFade";


@implementation JYAnimationManager

+ (instancetype)manager
{
    return [[JYAnimationManager alloc] init];
}

#pragma mark - AnimMethod

- (void)jy_addAnimationWithLayer:(CALayer *)layer forKey:(NSString *)key
{
    if (key == JYAnimationTypeRotaion) {
        [self jy_addRotateAnimationWithLayer:layer];
    }
    else if (key == JYAnimationTypeScaleMove){
        [self jy_addChangeMusicAnimationWithLayer:layer];
    }
    else if (key == JYAnimationTypeFade){
        [self jy_addShowDiscAnimationWithLayer:layer];
    }
    else{
        return;
    }
}

//暂停动画
- (void)jy_pauseAnimationWithLayer:(CALayer *)layer
{
    //申明一个暂停时间为这个层动画的当前时间
    CFTimeInterval currTimeoffset = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0; //当前层的速度
    layer.timeOffset = currTimeoffset; //层的停止时间设为上面申明的暂停时间
}

//恢复动画
- (void)jy_resumeAnimationWithLayer:(CALayer *)layer
{
    CFTimeInterval pausedTime = layer.timeOffset; // 当前层的暂停时间
    /** 层动画时间的初始化值 **/
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    /** end **/
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    CFTimeInterval timePause = timeSincePause - pausedTime; //计算从哪里开始恢复动画
    layer.beginTime = timePause; //让层的动画从停止的位置恢复动效
}

//移除指定动画
-(void)jy_removeAnimationFromLayer:(CALayer *)layer forKey:(NSString *)key
{
//    if (key == JYAnimationTypeRotaion) {   //针对旋转动画 移除前将layer旋转到动画停止时的位置
//        if (layer.speed > 0) {
//            [self jy_pauseRotateWithLayer:layer];
//        }
//        CFTimeInterval beginTime = firstBeginTime;
//        CFTimeInterval endTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
//        CFTimeInterval pausedTime = endTime - layer.timeOffset + totalPauseTime;
//        CFTimeInterval durTime = endTime - beginTime - pausedTime;
//        CGFloat transAngle = 2.0 * M_PI * durTime / 30;
//        layer.transform = CATransform3DRotate(layer.transform, transAngle, 0, 0, 1);
//    }
    [layer removeAnimationForKey:key];
}

//移除所有动画
-(void)jy_removeAllAnimationFromLayer:(CALayer *)layer
{
    [layer removeAllAnimations];
}

#pragma mark - Private

//创建旋转动画
- (void)jy_addRotateAnimationWithLayer:(CALayer *)layer
{
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 30;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.delegate = self;

    [layer addAnimation:rotationAnimation forKey:JYAnimationTypeRotaion];
    layer.speed = 1.0;
}



//切换唱片动画
- (void)jy_addChangeMusicAnimationWithLayer:(CALayer *)layer
{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 0.2;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的倍率
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.9]; // 结束时的倍率
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation"];
    moveAnimation.duration = 0.4;
    moveAnimation.beginTime = 0.4;
    moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, -[[UIScreen mainScreen] bounds].size.height)];
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.duration = 0.8;
    fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    fadeAnimation.removedOnCompletion = NO;
    fadeAnimation.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.8;
    group.animations=@[scaleAnimation,moveAnimation,fadeAnimation];
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.delegate = self;
    
    [layer addAnimation:group forKey:JYAnimationTypeScaleMove];
}

//显示唱片动画
-(void)jy_addShowDiscAnimationWithLayer:(CALayer *)layer
{
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.duration = 0.8;
    
    [layer addAnimation:fadeAnimation forKey:JYAnimationTypeFade];
}


#pragma mark - CAAnimationDelegate

-(void)animationDidStart:(CAAnimation *)anim
{
    if ([_delegate respondsToSelector:@selector(jy_animationDidStart:)]) {
        [_delegate jy_animationDidStart:anim];
    }
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([_delegate respondsToSelector:@selector(jy_animationDidStop:finished:)]) {
        [_delegate jy_animationDidStop:anim finished:flag];
    }
}

@end

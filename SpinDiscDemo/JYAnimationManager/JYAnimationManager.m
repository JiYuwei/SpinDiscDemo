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

-(instancetype)init
{
    if (self=[super init]) {
        
    }
    
    return self;
}

+ (instancetype)manager
{
    return [[JYAnimationManager alloc] init];
}

#pragma mark - AnimMethod

- (void)jy_addAnimationWithView:(UIView *)view forKey:(NSString *)key
{
    if (key == JYAnimationTypeRotaion) {
        [self jy_addRotateAnimationWithView:view];
    }
    else if (key == JYAnimationTypeScaleMove){
        [self jy_addChangeMusicAnimationWithView:view];
    }
    else if (key == JYAnimationTypeFade){
        [self jy_addShowDiscAnimationWithView:view];
    }
    else{
        return;
    }
}

//暂停动画
- (void)jy_pauseRotateWithView:(UIView *)view
{
    //申明一个暂停时间为这个层动画的当前时间
    CFTimeInterval currTimeoffset = [view.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    view.layer.speed = 0.0; //当前层的速度
    view.layer.timeOffset = currTimeoffset; //层的停止时间设为上面申明的暂停时间
}

//恢复动画
- (void)jy_resumeRotateWithView:(UIView *)view
{
    CFTimeInterval pausedTime = view.layer.timeOffset; // 当前层的暂停时间
    /** 层动画时间的初始化值 **/
    view.layer.speed = 1.0;
    view.layer.timeOffset = 0.0;
    view.layer.beginTime = 0.0;
    /** end **/
    CFTimeInterval timeSincePause = [view.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    CFTimeInterval timePause = timeSincePause - pausedTime; //计算从哪里开始恢复动画
    view.layer.beginTime = timePause; //让层的动画从停止的位置恢复动效
}

//移除指定动画
-(void)jy_removeAnimationFromView:(UIView *)view forKey:(NSString *)key
{
    [view.layer removeAnimationForKey:key];
}

//移除所有动画
-(void)jy_removeAllAnimationFromView:(UIView *)view
{
    [view.layer removeAllAnimations];
}

#pragma mark - Private
//创建旋转动画
- (void)jy_addRotateAnimationWithView:(UIView *)view
{
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 30;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.delegate = self;
    
    [view.layer addAnimation:rotationAnimation forKey:JYAnimationTypeRotaion];
    view.layer.speed = 1;
}



//切换唱片动画
- (void)jy_addChangeMusicAnimationWithView:(UIView *)view
{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 0.2;
    scaleAnimation.repeatCount = 1;
    scaleAnimation.beginTime = 0.0;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的倍率
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.9]; // 结束时的倍率
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation"];
    moveAnimation.duration = 0.4;
    moveAnimation.repeatCount = 1;
    moveAnimation.beginTime = 0.4;
    moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, -[[UIScreen mainScreen] bounds].size.height)];
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.duration = 0.8;
    fadeAnimation.repeatCount = 1;
    fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    fadeAnimation.removedOnCompletion = NO;
    fadeAnimation.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.8;
    group.animations=@[scaleAnimation,moveAnimation,fadeAnimation];
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.delegate = self;
    
    [view.layer addAnimation:group forKey:JYAnimationTypeScaleMove];
}

//显示唱片动画
-(void)jy_addShowDiscAnimationWithView:(UIView *)view
{
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.duration = 0.8;
    
    [view.layer addAnimation:fadeAnimation forKey:JYAnimationTypeFade];
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

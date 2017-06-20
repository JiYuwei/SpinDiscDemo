//
//  JYAnimationManager.h
//  SpinDiscDemo
//
//  Created by 纪宇伟 on 2017/6/12.
//  Copyright © 2017年 纪宇伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NSString * JYAnimationType NS_STRING_ENUM;

FOUNDATION_EXPORT JYAnimationType const JYAnimationTypeRotaion;
FOUNDATION_EXPORT JYAnimationType const JYAnimationTypeScaleMove;
FOUNDATION_EXPORT JYAnimationType const JYAnimationTypeFade;

@protocol JYAnimationDelegate <NSObject>

- (void)jy_animationDidStart:(CAAnimation *)anim;
- (void)jy_animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;

@end


@interface JYAnimationManager : NSObject <CAAnimationDelegate>

@property(nonatomic,weak) id <JYAnimationDelegate> delegate;

+ (instancetype)manager;

- (void)jy_addAnimationWithLayer:(CALayer *)layer forKey:(NSString *)key;

- (void)jy_pauseRotateWithLayer:(CALayer *)layer;
- (void)jy_resumeRotateWithLayer:(CALayer *)layer;

- (void)jy_removeAnimationFromLayer:(CALayer *)layer forKey:(NSString *)key;
- (void)jy_removeAllAnimationFromLayer:(CALayer *)layer;

@end

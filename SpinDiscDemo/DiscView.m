//
//  DiscView.m
//  SpinDiscDemo
//
//  Created by 纪宇伟 on 2017/6/10.
//  Copyright © 2017年 纪宇伟. All rights reserved.
//

#import "DiscView.h"
#import "JYAnimationManager.h"

@interface DiscView()

@property(nonatomic,strong)JYAnimationManager *jyAManager;

@end


@implementation DiscView

-(JYAnimationManager *)jyAManager
{
    if (!_jyAManager) {
        _jyAManager=[JYAnimationManager manager];
    }
    
    return _jyAManager;
}


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPlayStatus) name:@"CheckPlayStatus" object:nil];
//        [self jy_createRotate];
        [self.jyAManager jy_addAnimationWithView:self forKey:JYAnimationTypeRotaion];
    }
    
    return self;
}

//app进入后台后动画会被移除，重回前台后需要重新创建
-(void)resetPlayStatus
{
    [self.jyAManager jy_addAnimationWithView:self forKey:JYAnimationTypeRotaion];
    [self checkPlayStatus];
}


-(void)checkPlayStatus
{
    if (_switchRotate) {
        [self.jyAManager jy_resumeRotateWithView:self];
    }
    else{
        [self.jyAManager jy_pauseRotateWithView:self];
    }
}


-(void)setSwitchRotate:(BOOL)switchRotate
{
    if (_switchRotate!=switchRotate) {
        _switchRotate=switchRotate;
    }
    
    [self checkPlayStatus];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CheckPlayStatus" object:nil];
    [self.layer removeAllAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

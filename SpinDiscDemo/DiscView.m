//
//  DiscView.m
//  SpinDiscDemo
//
//  Created by 纪宇伟 on 2017/6/10.
//  Copyright © 2017年 纪宇伟. All rights reserved.
//

#import "DiscView.h"
#import "JYAnimationManager.h"
#import "UIImageView+CornerRadius.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DiscView() <JYAnimationDelegate>

@property(nonatomic,strong)UIView *baseDiscView;
@property(nonatomic,strong)UIImageView *imgDiscView;

@property(nonatomic,strong)JYAnimationManager *jyAManager;

@end


@implementation DiscView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPlayStatus) name:@"CheckPlayStatus" object:nil];
        [self createDisc];
    }
    
    return self;
}


#pragma mark - Public

-(void)takeOutDiscAnim
{
    if ([_imgDiscView.layer animationForKey:JYAnimationTypeRotaion]) {
        [self.jyAManager jy_removeAnimationFromView:_imgDiscView forKey:JYAnimationTypeRotaion];
    }

    [self.jyAManager jy_addAnimationWithView:self forKey:JYAnimationTypeScaleMove];
}

-(void)takeInDiscAnim
{
    [self.jyAManager jy_addAnimationWithView:self forKey:JYAnimationTypeFade];
}

-(void)disc_setImageWithUrl:(NSURL *)url
{
    [_imgDiscView sd_setImageWithURL:url];
}

#pragma mark - Private

-(JYAnimationManager *)jyAManager
{
    if (!_jyAManager) {
        _jyAManager=[JYAnimationManager manager];
        _jyAManager.delegate = self;
    }
    
    return _jyAManager;
}

- (void)createDisc
{
    _baseDiscView=[[UIView alloc] initWithFrame:self.bounds];
    _baseDiscView.backgroundColor=[UIColor blackColor];
    _baseDiscView.layer.cornerRadius=self.bounds.size.width/2;
    _baseDiscView.alpha=0.2f;
    [self addSubview:_baseDiscView];
    
    _imgDiscView=[[UIImageView alloc] initWithFrame:CGRectMake(8, 8, self.bounds.size.width-16, self.bounds.size.height-16)];
    _imgDiscView.backgroundColor=[UIColor clearColor];
    [_imgDiscView zy_cornerRadiusRoundingRect];
//    _imgDiscView.layer.cornerRadius = _imgDiscView.bounds.size.width/2;
//    _imgDiscView.layer.masksToBounds = YES;
    [self addSubview:_imgDiscView];
}

//app进入后台后动画会被移除，重回前台后需要重新创建
-(void)resetPlayStatus
{
    [self checkPlayStatus];
}


-(void)checkPlayStatus
{
    if (_switchRotate) {
        if ([_imgDiscView.layer animationForKey:JYAnimationTypeRotaion]) {
            [self.jyAManager jy_resumeRotateWithView:_imgDiscView];
        }
        else{
            [self.jyAManager jy_addAnimationWithView:_imgDiscView forKey:JYAnimationTypeRotaion];
        }
    }
    else{
        [self.jyAManager jy_pauseRotateWithView:_imgDiscView];
    }
}


-(void)setSwitchRotate:(BOOL)switchRotate
{
    if (_switchRotate!=switchRotate) {
        _switchRotate=switchRotate;
    }
    
    [self checkPlayStatus];
}


#pragma mark - JYAnimationDelegate

-(void)jy_animationDidStart:(CAAnimation *)anim
{
    if (anim == [self.layer animationForKey:JYAnimationTypeScaleMove]) {
        _switchRotate = NO;
        if ([_delegate respondsToSelector:@selector(changeDiscDidStart)]) {
            [_delegate changeDiscDidStart];
        }

    }
}

-(void)jy_animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.layer animationForKey:JYAnimationTypeScaleMove] && flag) {
        [self.jyAManager jy_removeAnimationFromView:self forKey:JYAnimationTypeScaleMove];
        if ([_delegate respondsToSelector:@selector(changeDiscDidFinish)]) {
            [_delegate changeDiscDidFinish];
        }
    }
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

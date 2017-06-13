//
//  ConsoleView.m
//  SpinDiscDemo
//
//  Created by 纪宇伟 on 2017/6/11.
//  Copyright © 2017年 纪宇伟. All rights reserved.
//

#import "ConsoleView.h"

@interface ConsoleView ()

@property(nonatomic,weak) id target;
@property(nonatomic,assign) SEL action;

@end


@implementation ConsoleView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        [self createButtons];
    }
    
    return self;
}

-(void)setConsoleBtnEnabled:(BOOL)consoleBtnEnabled
{
    if (_consoleBtnEnabled != consoleBtnEnabled) {
        _consoleBtnEnabled = consoleBtnEnabled;
    }
    
    _lastBtn.enabled=_consoleBtnEnabled;
    _playBtn.enabled=_consoleBtnEnabled;
    _nextBtn.enabled=_consoleBtnEnabled;
}


-(void)createButtons
{
    CGSize cSize=self.bounds.size;
    
    _lastBtn=[[ConsoleBtn alloc] initWithFrame:CGRectMake(10, (cSize.height-smallBtnWidth)/2, smallBtnWidth, smallBtnWidth) ConsoleType:ConsoleBtnTypeLast];
    [_lastBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_lastBtn];
    
    _playBtn=[[ConsoleBtn alloc] initWithFrame:CGRectMake((cSize.width-bigBtnWidth)/2, (cSize.height-bigBtnWidth)/2, bigBtnWidth, bigBtnWidth) ConsoleType:ConsoleBtnTypePlay];
    [_playBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playBtn];
    
    _nextBtn=[[ConsoleBtn alloc] initWithFrame:CGRectMake(cSize.width-10-smallBtnWidth, (cSize.height-smallBtnWidth)/2, smallBtnWidth, smallBtnWidth) ConsoleType:ConsoleBtnTypeNext];
    [_nextBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_nextBtn];
}

-(void)btnClicked:(UIButton *)sender
{
    [self.target performSelector:self.action withObject:sender afterDelay:0];
}

-(void)addTarget:(id)target action:(SEL)action
{
    self.target=target;
    self.action=action;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

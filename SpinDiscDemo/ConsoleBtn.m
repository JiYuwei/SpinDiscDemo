//
//  ConsoleBtn.m
//  SpinDiscDemo
//
//  Created by 纪宇伟 on 2017/6/11.
//  Copyright © 2017年 纪宇伟. All rights reserved.
//

#import "ConsoleBtn.h"

#define BUTTON_COLOR   [UIColor colorWithRed:0.27 green:0.73 blue:0.36 alpha:1]
#define DISABLE_COLOR  [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]
//static CGFloat enableColor[4]  = {0.27,0.73,0.36,1.0};
//static CGFloat disableColor[4] = {0.5,0.5,0.5,1.0};

@interface ConsoleBtn ()

@property(nonatomic,strong)UIColor *btnColor;

@end


@implementation ConsoleBtn

-(instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame ConsoleType:ConsoleBtnTypePlay];
}

-(instancetype)initWithFrame:(CGRect)frame ConsoleType:(ConsoleBtnType)type
{
    if (self=[super initWithFrame:frame]) {
        
//        for (int i=0; i<4; i++) {
//            _zColor[i]=enableColor[i];
//        }
        _btnColor = BUTTON_COLOR;
        
        self.consoleType=type;
        [self customBtnStyle];
    }
    
    return self;
}

-(void)setConsoleType:(ConsoleBtnType)consoleType
{
    if (_consoleType!=consoleType) {
        _consoleType=consoleType;
    }
    
    [self setNeedsDisplay];
}

-(void)customBtnStyle
{
    self.layer.cornerRadius=self.frame.size.width/2;
    self.layer.borderColor=BUTTON_COLOR.CGColor;
    self.layer.borderWidth=2.0f;
}

#pragma mark - OverRide
-(void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (self.consoleType == ConsoleBtnTypeLast || self.consoleType == ConsoleBtnTypeNext) {
        [self enabledBtnColor:enabled];
    }
}

-(void)enabledBtnColor:(BOOL)enabled
{
//    for (int i=0; i<4; i++) {
//        _zColor[i]=enabled?enableColor[i]:disableColor[i];
//    }
    _btnColor = enabled ? BUTTON_COLOR : DISABLE_COLOR;
    
    self.layer.borderColor=enabled?BUTTON_COLOR.CGColor:DISABLE_COLOR.CGColor;
    [self setNeedsDisplay];
}

#pragma mark - DrawRect
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetStrokeColor(context, _zColor);
//    CGContextSetFillColor(context, _zColor);
    [_btnColor set];
    CGContextSetLineWidth(context, 1.0);
    
    switch (_consoleType) {
        case ConsoleBtnTypePlay:
            [self drawPlayBtnwithContext:context rect:rect];
            break;
        case ConsoleBtnTypeLast:
            [self drawLastBtnwithContext:context rect:rect];
            break;
        case ConsoleBtnTypeNext:
            [self drawNextBtnwithContext:context rect:rect];
            break;
        case ConsoleBtnTypePause:
            [self drawPauseBtnwithContext:context rect:rect];
            break;
            
        default:
            break;
    }
    

}

- (void)drawPlayBtnwithContext:(CGContextRef)context rect:(CGRect)rect
{
    CGPoint sPoints[3];//坐标点
    sPoints[0] =CGPointMake(rect.size.width*0.3+2, rect.size.height*0.3);//坐标1
    sPoints[1] =CGPointMake(rect.size.width*0.3+2, rect.size.height*0.7);//坐标2
    sPoints[2] =CGPointMake(rect.size.width*0.7+2, rect.size.height*0.5);//坐标3
    CGContextAddLines(context, sPoints, 3);//添加线
    CGContextClosePath(context);//封起来
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
}

- (void)drawLastBtnwithContext:(CGContextRef)context rect:(CGRect)rect
{
    CGPoint sPoints[3];//坐标点
    sPoints[0] =CGPointMake(rect.size.width*0.65, rect.size.height*0.65);//坐标1
    sPoints[1] =CGPointMake(rect.size.width*0.65, rect.size.height*0.35);//坐标2
    sPoints[2] =CGPointMake(rect.size.width*0.35, rect.size.height*0.5);//坐标3
    CGContextAddLines(context, sPoints, 3);//添加线
    CGContextClosePath(context);//封起来
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
    
    CGContextFillRect(context, CGRectMake(rect.size.width*0.35-1, rect.size.height*0.35, 2, rect.size.height*0.3));
}

- (void)drawNextBtnwithContext:(CGContextRef)context rect:(CGRect)rect
{
    CGPoint sPoints[3];//坐标点
    sPoints[0] =CGPointMake(rect.size.width*0.35, rect.size.height*0.35);//坐标1
    sPoints[1] =CGPointMake(rect.size.width*0.35, rect.size.height*0.65);//坐标2
    sPoints[2] =CGPointMake(rect.size.width*0.65, rect.size.height*0.5);//坐标3
    CGContextAddLines(context, sPoints, 3);//添加线
    CGContextClosePath(context);//封起来
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
    
    CGContextFillRect(context, CGRectMake(rect.size.width*0.65-1, rect.size.height*0.35, 2, rect.size.height*0.3));
}

- (void)drawPauseBtnwithContext:(CGContextRef)context rect:(CGRect)rect
{
    CGContextFillRect(context, CGRectMake(rect.size.width*0.3+2, rect.size.height*0.3, 5, rect.size.height*0.4));
    CGContextFillRect(context, CGRectMake(rect.size.width*0.7-7, rect.size.height*0.3, 5, rect.size.height*0.4));
}

@end

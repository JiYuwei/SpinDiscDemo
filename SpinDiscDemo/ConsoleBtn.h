//
//  ConsoleBtn.h
//  SpinDiscDemo
//
//  Created by 纪宇伟 on 2017/6/11.
//  Copyright © 2017年 纪宇伟. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ConsoleBtnType) {
    ConsoleBtnTypePlay,
    ConsoleBtnTypeLast,
    ConsoleBtnTypeNext,
    ConsoleBtnTypePause
};

static CGFloat bigBtnWidth = 60;
static CGFloat smallBtnWidth = 40;

@interface ConsoleBtn : UIButton

@property(nonatomic)ConsoleBtnType consoleType;

-(instancetype)initWithFrame:(CGRect)frame ConsoleType:(ConsoleBtnType)type;

@end

//
//  ConsoleView.h
//  SpinDiscDemo
//
//  Created by 纪宇伟 on 2017/6/11.
//  Copyright © 2017年 纪宇伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConsoleBtn.h"

@interface ConsoleView : UIView

@property(nonatomic,strong)ConsoleBtn *lastBtn;
@property(nonatomic,strong)ConsoleBtn *playBtn;
@property(nonatomic,strong)ConsoleBtn *nextBtn;

@property(nonatomic) BOOL consoleBtnEnabled;

//传递button事件
-(void)addTarget:(id)target action:(SEL)action;

@end

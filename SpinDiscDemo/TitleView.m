//
//  TitleView.m
//  SpinDiscDemo
//
//  Created by 纪宇伟 on 2017/6/20.
//  Copyright © 2017年 纪宇伟. All rights reserved.
//

#import "TitleView.h"

@interface TitleView ()

@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *artistLabel;

@end



@implementation TitleView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createLabels];
    }
    
    return self;
}

-(void)createLabels
{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height/2)];
    _titleLabel.text = @"hello";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font =[UIFont systemFontOfSize:25];
    [self addSubview:_titleLabel];
    
    _artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height / 2, self.bounds.size.width, self.bounds.size.height / 2)];
    _artistLabel.text = @"world";
    _artistLabel.textAlignment = NSTextAlignmentCenter;
    _artistLabel.textColor = [UIColor whiteColor];
    _artistLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:_artistLabel];
    
}

-(void)setTitleDict:(NSDictionary *)titleDict
{
    if (_titleDict != titleDict) {
        _titleDict = titleDict;
    }
    
    _titleLabel.text = _titleDict[@"title"];
    _artistLabel.text = _titleDict[@"artist"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

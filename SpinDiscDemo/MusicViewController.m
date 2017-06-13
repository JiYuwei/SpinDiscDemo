//
//  MusicViewController.m
//  SpinDiscDemo
//
//  Created by 纪宇伟 on 2017/6/10.
//  Copyright © 2017年 纪宇伟. All rights reserved.
//

#import "MusicViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+CornerRadius.h"
#import "UIImage+ColorImage.h"
#import "DiscView.h"
#import "ConsoleView.h"
#import "JYAnimationManager.h"

#define SCREENWIDTH   [[UIScreen mainScreen] bounds].size.width
#define SCREENHEIGHT  [[UIScreen mainScreen] bounds].size.height

static NSInteger musicIndex = 0;

@interface MusicViewController () <JYAnimationDelegate>

@property(nonatomic,strong)UIImageView *baseImgView;
@property(nonatomic,strong)UIView *circleView;
@property(nonatomic,strong)DiscView *discView;
@property(nonatomic,strong)ConsoleView *consoleView;

@property(nonatomic,strong)JYAnimationManager *jyAManager;

@property(nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation MusicViewController

//Lazyload
-(JYAnimationManager *)jyAManager
{
    if (!_jyAManager) {
        _jyAManager=[JYAnimationManager manager];
        _jyAManager.delegate=self;
    }
    
    return _jyAManager;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarStyle=UIStatusBarStyleLightContent;
    self.view.backgroundColor=[UIColor blackColor];
    
    [self prepareData];
    [self createUI];
    [self loadingImageAtIndex:0];
}

-(void)prepareData
{
    _dataArray=[NSMutableArray arrayWithObjects:
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1497113221174&di=41a218890b3758c6bb13bdd22193d55f&imgtype=0&src=http%3A%2F%2Fps4.tgbus.com%2FUploadFiles%2F201609%2F20160923163211619.jpg",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1497199837902&di=6e5051443280a42b0fd648af21e9e2ed&imgtype=0&src=http%3A%2F%2Ff8.topit.me%2F8%2F50%2F48%2F11670736748fb48508l.jpg",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1497199837902&di=e6f1b9c5910bbf82a213cf148cec7370&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fbaike%2Fpic%2Fitem%2F9113862234eee8b8d6cae209.jpg",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1497199837902&di=1890c8849503480e0fdd67d16046a85a&imgtype=0&src=http%3A%2F%2Fimg4.duitang.com%2Fuploads%2Fitem%2F201306%2F09%2F20130609223125_JJRBr.jpeg",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1497199837902&di=16786e6db88db21919c8e2bf4121ee9d&imgtype=0&src=http%3A%2F%2Fa4.att.hudong.com%2F55%2F92%2F01300542281695138572924404362.jpg",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1497199837901&di=80605ef778ad73bcbcd44eb448e08481&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fblog%2F201401%2F04%2F20140104203604_BGBPa.thumb.600_0.png",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1497199837901&di=b74a96027040f000c62c3550bda54f39&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fbaike%2Fpic%2Fitem%2F42a98226cffc1e1736f0fc9d4a90f603728de9cb.jpg",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1497199837901&di=35659d06922f66cb3e5e5bf7d748c721&imgtype=0&src=http%3A%2F%2Ffile01.16sucai.com%2Fd%2Ffile%2F2014%2F0105%2Fc9c75688beea99a5d671ceeb27428efa.jpg",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1497199837901&di=b029be8751565687b322c10d92a8cf3f&imgtype=0&src=http%3A%2F%2Fa4.topitme.com%2Fl%2F201101%2F14%2F12949466828066.jpg",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1497199837901&di=cd52d5bd51a54e1622af1a560a956896&imgtype=0&src=http%3A%2F%2Fwww.fevte.com%2Fdata%2Fattachment%2Fportal%2F201204%2F09%2F3300201204091559165.jpg",
                nil];
}

-(void)createUI
{
    [self createMaskView];
    [self createDiscView];
    [self createBtns];
}

//创建背景视图
-(void)createMaskView
{
    _baseImgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    _baseImgView.backgroundColor=[UIColor darkGrayColor];
    [self.view addSubview:_baseImgView];
    
//不合适但有效的方案
    
    UIToolbar *toolBar=[[UIToolbar alloc] initWithFrame:_baseImgView.bounds];
    toolBar.barStyle=UIBarStyleBlack;
    [_baseImgView addSubview:toolBar];
    
    
//    UIVisualEffectView *blurView=[[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
//    blurView.frame=CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
//    [_baseImgView addSubview:blurView];
}

//创建唱片视图
-(void)createDiscView
{
    _circleView=[[UIView alloc] initWithFrame:CGRectMake(30, 150, SCREENWIDTH-60, SCREENWIDTH-60)];
    _circleView.backgroundColor=[UIColor blackColor];
    _circleView.layer.cornerRadius=_circleView.bounds.size.width/2;
    _circleView.alpha=0.2f;
    [self.view addSubview:_circleView];
    
    _discView=[[DiscView alloc] initWithFrame:CGRectMake(_circleView.frame.origin.x+8, _circleView.frame.origin.y+8, _circleView.frame.size.width-16, _circleView.frame.size.height-16)];
    _discView.backgroundColor=[UIColor clearColor];
    [_discView zy_cornerRadiusRoundingRect];
    [_discView addObserver:self forKeyPath:@"switchRotate" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:_discView];
}


-(void)createBtns
{
    _consoleView=[[ConsoleView alloc] initWithFrame:CGRectMake((SCREENWIDTH-220)/2, SCREENHEIGHT-150, 220, 80)];
    [_consoleView addTarget:self action:@selector(buttonClicked:)];
    [self.view addSubview:_consoleView];
}

-(void)loadingImageAtIndex:(NSInteger)index
{
    NSString *imgUrl=_dataArray[index];

    [_baseImgView sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    
    [_discView sd_setImageWithURL:[NSURL URLWithString:imgUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self.jyAManager jy_removeAnimationFromView:_discView forKey:JYAnimationTypeScaleMove];
        [self.jyAManager jy_removeAnimationFromView:_circleView forKey:JYAnimationTypeScaleMove];
    }];
}


-(void)buttonClicked:(UIButton *)sender
{
    ConsoleBtn *btn=(ConsoleBtn *)sender;
    switch (btn.consoleType) {
        case ConsoleBtnTypePlay:
            [self playMusic];
            break;
        case ConsoleBtnTypeLast:
            [self loadingLastMusic];
            break;
        case ConsoleBtnTypeNext:
            [self loadingNextMusic];
            break;
        case ConsoleBtnTypePause:
            [self playMusic];
            break;
            
        default:
            break;
    }
}

-(void)playMusic
{
    _discView.switchRotate=!_discView.switchRotate;
}

-(void)loadingLastMusic
{
    musicIndex--;
    if (musicIndex<0) {
        musicIndex=_dataArray.count-1;
    }
    
    [self changeMusic];
}

-(void)loadingNextMusic
{
    musicIndex++;
    if (musicIndex>=_dataArray.count) {
        musicIndex=0;
    }
    
    [self changeMusic];
}

-(void)changeMusic
{
    [self.jyAManager jy_addAnimationWithView:_discView forKey:JYAnimationTypeScaleMove];
    [self.jyAManager jy_addAnimationWithView:_circleView forKey:JYAnimationTypeScaleMove];
    if (!_discView.switchRotate) {
        [self playMusic];
    }
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"switchRotate"]) {
        BOOL switchRotate=[change[NSKeyValueChangeNewKey] boolValue];
        _consoleView.playBtn.consoleType=switchRotate?ConsoleBtnTypePause:ConsoleBtnTypePlay;
    }
}

#pragma mark - JYAnimationDelegate

-(void)jy_animationDidStart:(CAAnimation *)anim
{
    if (anim == [_discView.layer animationForKey:JYAnimationTypeScaleMove]) {
        _consoleView.consoleBtnEnabled=NO;
    }
}

-(void)jy_animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [_discView.layer animationForKey:JYAnimationTypeScaleMove]) {
        _consoleView.consoleBtnEnabled=YES;
        [self loadingImageAtIndex:musicIndex];
    }
}

-(void)dealloc
{
    [_jyAManager jy_removeAllAnimationFromView:_discView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

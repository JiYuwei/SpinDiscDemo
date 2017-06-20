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

#define SCREENWIDTH   [[UIScreen mainScreen] bounds].size.width
#define SCREENHEIGHT  [[UIScreen mainScreen] bounds].size.height

static NSInteger musicIndex = 0;

@interface MusicViewController () <DiscViewDelegate>

@property(nonatomic,strong)UIImageView *baseImgView;
@property(nonatomic,strong)NSMutableArray <DiscView *> *discViewArray;
@property(nonatomic,strong)ConsoleView *consoleView;

@property(nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation MusicViewController

//Lazyload
- (NSMutableArray *)discViewArray
{
    if (!_discViewArray) {
        _discViewArray = [NSMutableArray array];
    }
    
    return _discViewArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarStyle=UIStatusBarStyleLightContent;
    self.view.backgroundColor=[UIColor blackColor];
    
    [self prepareData];
    [self createUI];
    
    NSString *imgUrl=_dataArray[0];
    [_baseImgView sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    [self.discViewArray[0] disc_setImageWithUrl:[NSURL URLWithString:imgUrl]];
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
    DiscView *discView1 = [[DiscView alloc] initWithFrame:CGRectMake(20, 130, SCREENWIDTH-40, SCREENWIDTH-40)];
    [discView1 addObserver:self forKeyPath:@"switchRotate" options:NSKeyValueObservingOptionNew context:nil];
    discView1.delegate = self;
    
    [self.view addSubview:discView1];
    
    DiscView *discView2 = [[DiscView alloc] initWithFrame:CGRectMake(20, 130, SCREENWIDTH-40, SCREENWIDTH-40)];
    [discView2 addObserver:self forKeyPath:@"switchRotate" options:NSKeyValueObservingOptionNew context:nil];
    discView2.delegate = self;
    discView2.alpha = 0;
    [self.view addSubview:discView2];
    
    [self.discViewArray addObject:discView1];
    [self.discViewArray addObject:discView2];
}


-(void)createBtns
{
    _consoleView=[[ConsoleView alloc] initWithFrame:CGRectMake((SCREENWIDTH-220)/2, SCREENHEIGHT-150, 220, 80)];
    [_consoleView addTarget:self action:@selector(buttonClicked:)];
    [self.view addSubview:_consoleView];
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
    _discViewArray[0].switchRotate=!_discViewArray[0].switchRotate;
}

-(void)loadingLastMusic
{
    musicIndex = [self minusIndex:musicIndex];
    
    [self changeMusic];
}

-(void)loadingNextMusic
{
    musicIndex = [self plusIndex:musicIndex];
    
    [self changeMusic];
}

-(void)changeMusic
{
    [_discViewArray[0] takeOutDiscAnim];
    [_discViewArray[1] takeInDiscAnim];
    [self loadingNextImageAtIndex:musicIndex];
//    [self exchangeDiscViewArrayItems];
}

//- (void)exchangeDiscViewArrayItems
//{
//    DiscView *discView1 = _discViewArray[0];
//    DiscView *discView2 = _discViewArray[1];
//    
//    [UIView animateWithDuration:0.8 animations:^{
//        discView1.alpha = 0;
//        discView2.alpha = 1;
//    } completion:^(BOOL finished) {
//        [_discViewArray exchangeObjectAtIndex:0 withObjectAtIndex:1];
//        
//        if (!_discViewArray[0].switchRotate) {
//            [self playMusic];
//        }
//    }];
//}

//加载下一首歌曲数据
-(void)loadingNextImageAtIndex:(NSInteger)index
{
    NSString *imgUrl = _dataArray[index];
    
    [_baseImgView sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    [self.discViewArray[1] disc_setImageWithUrl:[NSURL URLWithString:imgUrl]];
}

#pragma mark - KVO switchRotate
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"switchRotate"]) {
        BOOL switchRotate=[change[NSKeyValueChangeNewKey] boolValue];
        _consoleView.playBtn.consoleType=switchRotate?ConsoleBtnTypePause:ConsoleBtnTypePlay;
    }
}

#pragma mark - DiscViewDelegate

-(void)changeDiscDidStart
{
    _consoleView.consoleBtnEnabled=NO;
    if (_consoleView.playBtn.consoleType != ConsoleBtnTypePlay) {
        _consoleView.playBtn.consoleType = ConsoleBtnTypePlay;
    }
    
    _discViewArray[0].alpha = 0.0;
    _discViewArray[1].alpha = 1.0;
}

-(void)changeDiscDidFinish
{
    _consoleView.consoleBtnEnabled=YES;
    if (_consoleView.playBtn.consoleType != ConsoleBtnTypePause) {
        _consoleView.playBtn.consoleType = ConsoleBtnTypePause;
    }
    
    [_discViewArray exchangeObjectAtIndex:0 withObjectAtIndex:1];
    
    if (!_discViewArray[0].switchRotate) {
        [self playMusic];
    }
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)plusIndex:(NSInteger)index
{
    index++;
    if (index>=_dataArray.count) {
        index=0;
    }
    
    return index;
}

- (NSInteger)minusIndex:(NSInteger)index
{
    index--;
    if (index<0) {
        index=_dataArray.count-1;
    }
    
    return index;
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

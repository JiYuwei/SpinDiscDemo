# SpinDiscDemo
a demo for QQMusic
####需要实现的需求

- 背景图（毛玻璃效果、渐变动画）
- 标题（切换曲目、作者信息）
- 播放按钮控件（按钮绘图、监听播放状态与控制动画）
- 唱片（圆角处理、旋转动画、换歌动画）
- 后台回到前台重置动画

#####背景图毛玻璃效果
首先我们来创建一个不需要导航栏的视图控制器，在Controller中创建一个UIImageView作为最底层的背景图界面：
```
@interface MusicViewController () 

@property(nonatomic,strong)UIImageView *baseImgView;

@end
```
```
//创建背景视图
-(void)createMaskView
{
    _baseImgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    _baseImgView.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_baseImgView];
}
```
关于毛玻璃效果，我们第一时间可以想到的方法就是使用UIToolBar或者UIVisualEffectView（iOS 8.0以上可用）覆盖在背景图上，使用方法如下：
```
UIToolbar *toolBar=[[UIToolbar alloc] initWithFrame:_baseImgView.bounds];
toolBar.barStyle=UIBarStyleBlack;
[_baseImgView addSubview:toolBar];
```
或者
```
UIVisualEffectView *blurView=[[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
blurView.frame=CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
[_baseImgView addSubview:blurView];
```
运行一下，效果如图所示：
![原图](http://upload-images.jianshu.io/upload_images/6363544-e2a6581b3e7f7f4f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/300)
![毛玻璃](http://upload-images.jianshu.io/upload_images/6363544-92bdb46328a26803.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/300)

看上去很不错，不过继续进行下去很快就发现这两种方式会存在一些问题。首先我们来大致地了解下原版QQ音乐界面对于性能上的优化方式。

Xcode -> Open Developer Tool -> Instruments
![Xcode菜单](http://upload-images.jianshu.io/upload_images/6363544-90188d9f70155390.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

选择Core Animation

![Instruments](http://upload-images.jianshu.io/upload_images/6363544-061da560dcfa4a74.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

将手机上的QQ音乐打开，切换到播放页面，然后连接电脑，在Core Animation测试工具左上角选择所连接的手机。

![CoreAnimation](http://upload-images.jianshu.io/upload_images/6363544-d35cd1165624bb16.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

左下角找到Debug Options，这里我们主要看一下 Color OffScreen-Rendered Yellow（离屏渲染）和 Color Blended Layers（混合图层），这两项对于性能的影响比较大，如果想详细了解其他选项的含义及相关知识可以移步 [UIKit性能调优实战讲解](http://www.jianshu.com/p/619cf14640f3)

勾选 Color OffScreen-Rendered Yellow
![Debug Options](http://upload-images.jianshu.io/upload_images/6363544-57d73abfc3a0dd65.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

然后可以看到手机变成了这个样子：

![QQ音乐界面](http://upload-images.jianshu.io/upload_images/6363544-0afc276c272a649d.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)

图中除了状态栏以外没有任何地方被标记为黄色，也就是说没有触发离屏渲染。
回头再测试下我们刚刚写的页面：

![Demo](http://upload-images.jianshu.io/upload_images/6363544-8a0c2940566e62d9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)

整个屏幕都被标记成黄色，也就是说上述两种实现毛玻璃效果的方法都会导致离屏渲染，会在一定程度上影响页面流畅度。

下面我们勾选 Color Blended Layers 再来看看：

![Debug Options](http://upload-images.jianshu.io/upload_images/6363544-0ec7b5f4dd183f8f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


![QQ音乐界面](http://upload-images.jianshu.io/upload_images/6363544-fb1ce68ddce10c60.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)

红色表示出现了混合图层，绿色表示没有混合图层。整个界面全部被标记成红色。

这下我们可以很清楚的明白QQ音乐播放界面的设计思路了，尽量规避离屏渲染，使用混合图层模拟所有特效，这样一来，所有的圆角、模糊等效果就要从图片本身着手处理，而不能再从视图上进行处理。

- UIImage+ImageEffects
这是UIImage的一个category，基于vImage实现的模糊效果的代码，增加方法来对图像进行模糊和着色效果，模糊效果非常美观，推荐使用。

```
#pragma mark - Blur Image

/**
 *  Get blured image.
 *
 *  @return Blured image.
 */
- (UIImage *)blurImage;

/**
 *  Get the blured image masked by another image.
 *
 *  @param maskImage Image used for mask.
 *
 *  @return the Blured image.
 */
- (UIImage *)blurImageWithMask:(UIImage *)maskImage;

/**
 *  Get blured image and you can set the blur radius.
 *
 *  @param radius Blur radius.
 *
 *  @return Blured image.
 */
- (UIImage *)blurImageWithRadius:(CGFloat)radius;

/**
 *  Get blured image at specified frame.
 *
 *  @param frame The specified frame that you use to blur.
 *
 *  @return Blured image.
 */
- (UIImage *)blurImageAtFrame:(CGRect)frame;
```

由于我们的图片使用SDWebImage来加载，将模糊效果的处理放在加载完成后进行。

```
NSString *imgUrl = _dataArray[0][@"url"]; //随便找一个图片的url
   
[_baseImgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            _baseImgView.image = [image blurImage];
        }
}];
```
效果如图：

![模拟毛玻璃效果](http://upload-images.jianshu.io/upload_images/6363544-b0b0753959b62d24.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)

由于作为背景图色调需要偏暗，接下来要调整背景图的亮度，本咸鱼尝试了很多种调整亮度的方法，使用Core Image、GPUImage，可行但是效果不太理想，卡顿感严重；后来想到改变imageView的透明度，大家应该注意到了我的Controller的跟视图以及baseImgView的backgroundColor都设置为blackColor，通过修改view的alpha值调整亮度一样可行且不影响流畅度，缺点是依然会造成离屏渲染。

最后的解决方案是在此基础上稍作更改，view的alpha不变，修改图片的透明度来达到效果，这样既不会出现离屏渲染也不会对流畅度造成影响。

新建一个 UIImage+ImageOpacity 的 category
```
@interface UIImage (ImageOpacity)

-(UIImage *)jy_lucidImage;
-(UIImage *)jy_imageWithAlpha:(CGFloat)alpha;

@end
```
```
#import "UIImage+ImageOpacity.h"

@implementation UIImage (ImageOpacity)

-(UIImage *)jy_lucidImage
{
    return [self jy_imageWithAlpha:0.5];
}

//设置图片透明度
-(UIImage *)jy_imageWithAlpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContextWithOptions(self.size,NO,0.0f);
    CGContextRef ctx =UIGraphicsGetCurrentContext();
    CGRect area =CGRectMake(0,0, self.size.width, self.size.height);
    CGContextScaleCTM(ctx,1, -1);
    CGContextTranslateCTM(ctx,0, -area.size.height);
    CGContextSetBlendMode(ctx,kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, self.CGImage);
    UIImage*newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
```

在Controller中对baseImgView作如下设置：
```
[_baseImgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            _baseImgView.image = [[image blurImage] jy_lucidImage];
        }
}];
```

效果如图：

![Demo](http://upload-images.jianshu.io/upload_images/6363544-bb170c957658a53a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)

这样没有离屏渲染的毛玻璃背景就创建好了。

#####背景图渐变动画

第一时间想到的就是使用UIView封装的动画来实现，在下一张图片加载完成时使用UIView animateWithDuration:方法更改view的alpha模拟渐变效果，但是实测发现这样的效果会有一个亮度上的波动，由于我的背景色设置为黑色，切换背景时会先变黑在变到下一张图片，而不是平滑过渡。后来想到使用Core Animation中的CATranstion来实现，代码如下：
```
NSString *imgUrl = _dataArray[index][@"url"];  //下一张背景图url
UIImage *placeHolder = _baseImgView.image;     //使用上一张唱片背景图作为placeholder
[_baseImgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:placeHolder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) 
            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionFade;
            transition.duration = 1.0f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [_baseImgView.layer addAnimation:transition forKey:nil];

            _baseImgView.image = [[image blurImage] jy_lucidImage];
        }
}];
```
效果
![背景转场动画](http://upload-images.jianshu.io/upload_images/6363544-0781a0b826b68d65.gif?imageMogr2/auto-orient/strip)

值得一提的是，如果使用UIToolBar或者UIVisualEffectView覆盖的方式实现毛玻璃效果时，将会导致UIImageView上的转场动画无法播放，这就是刚才所说的另一个问题。目前还不明白具体的原因，有哪位同学对此比较了解的话可以在下方留言。

#####标题
标题的实现比较简单，直接给出代码：
```
@interface TitleView : UIView

@property(nonatomic,copy)NSDictionary *titleDict;

@end
```
```
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
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font =[UIFont systemFontOfSize:25];
    [self addSubview:_titleLabel];
    
    _artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height / 2, self.bounds.size.width, self.bounds.size.height / 2)];
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

@end
```

需要修改标题信息时，直接修改titleDict属性即可

```
NSDictionary *titleDic = _dataArray[index][@"titleDic"];
_titleView.titleDict = titleDic;
```

#####播放按钮控件

我们需要封装一个集播放、暂停、上一首、下一首等功能于一身的自定义控件，大概像这样：

![按钮控件](http://upload-images.jianshu.io/upload_images/6363544-436e6f24bb177c57.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

一个view上有3个button，分别用来控制播放／暂停、上一首、下一首。

首先来封装一个自定义button类，可以用这个类创建任意一种我们需要的button，我们叫它ConsoleBtn，头文件如下：
```
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
```
我们需要的button有4种，因此我们定义一个枚举区分我们具体需要哪一种button，在初始化方法中，我们对button进行一个大概的设置：
```
-(void)customBtnStyle
{
    self.layer.cornerRadius=self.frame.size.width/2;
    self.layer.borderColor=BUTTON_COLOR.CGColor;
    self.layer.borderWidth=2.0f;
}
```
值得注意的是，这里设置button.layer的cornerRadius并不会触发离屏渲染，由于我们的button不需要设置图片，button里的图案我们选择用绘图画出来，只要图形没有超过圆角的部分便不需要使用self.layer.maskToBounds = YES来裁剪，仅设置圆角是不会触发离屏渲染的，只有这两句同时放在一起时才会出现离屏渲染，所以不用担心性能问题。

接下来重写DrawRect方法，根据不同的类型画不同的图案（当然用CALayer也可以实现且性能会更好，不过由于篇幅限制这里不去深究）：

```
#pragma mark - DrawRect
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext(); //获得图形上下文
//    CGContextSetStrokeColor(context, _zColor);
//    CGContextSetFillColor(context, _zColor);
    [_btnColor set]; //设置颜色
    CGContextSetLineWidth(context, 1.0); //设置线宽
    
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
```
```
//画一个播放按钮（三角形）
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
```
```
//画一个上一首按钮（竖线加三角形）
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
```
```
//画一个下一首按钮（三角形加竖线）
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
```
```
//画一个暂停按钮（两条竖线）
- (void)drawPauseBtnwithContext:(CGContextRef)context rect:(CGRect)rect
{
    CGContextFillRect(context, CGRectMake(rect.size.width*0.3+2, rect.size.height*0.3, 5, rect.size.height*0.4));
    CGContextFillRect(context, CGRectMake(rect.size.width*0.7-7, rect.size.height*0.3, 5, rect.size.height*0.4));
}
```
ConsoleBtn封装基本完成，接下来封装一个按钮视图控件ConsoleView：
```
#import <UIKit/UIKit.h>
@class ConsoleBtn;

@interface ConsoleView : UIView

@property(nonatomic,strong)ConsoleBtn *lastBtn;
@property(nonatomic,strong)ConsoleBtn *playBtn;
@property(nonatomic,strong)ConsoleBtn *nextBtn;

@property(nonatomic) BOOL consoleBtnEnabled;

//传递button事件
-(void)addTarget:(id)target action:(SEL)action;

@end
```

我们在这个视图中创建三个button，分别为上一首、播放／暂停、下一首；属性consoleBtnEnabled用来控制按钮的可用状态，通过该属性可以设置控件中所有按钮为可用／禁用；为了可以直接在Controller中进行按钮事件回调，我们添加了一个addTarget: action:方法用于传递按钮事件；部分实现代码如下：
```
@interface ConsoleView ()

@property(nonatomic,weak) id target;
@property(nonatomic,assign) SEL action;

@end
```
```
-(void)addTarget:(id)target action:(SEL)action
{
    self.target=target;
    self.action=action;
}
```
```
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
```
```
-(void)btnClicked:(UIButton *)sender
{
    [self.target performSelector:self.action withObject:sender afterDelay:0];
}
```

现在我们可以回到Controller中去创建一个封装好的ConsoleView了：
```
-(void)createBtns
{
    _consoleView=[[ConsoleView alloc] initWithFrame:CGRectMake((SCREENWIDTH-220)/2, SCREENHEIGHT-140, 220, 80)];
    [_consoleView addTarget:self action:@selector(buttonClicked:)];
    [self.view addSubview:_consoleView];
}
```

```
-(void)buttonClicked:(UIButton *)sender
{
    ConsoleBtn *btn=(ConsoleBtn *)sender;//这里可以获取点击的按钮
    switch (btn.consoleType) {
        case ConsoleBtnTypePlay:
        case ConsoleBtnTypePause:
            [self playMusic];
            break;
        case ConsoleBtnTypeLast:
            [self loadingLastMusic];
            break;
        case ConsoleBtnTypeNext:
            [self loadingNextMusic];
            break;
        
        default:
            break;
    }
}
```
#####唱片视图圆角处理

最重要的环节来了，唱片视图。首先观察一下原版的QQ音乐视图：

![QQ音乐界面](http://upload-images.jianshu.io/upload_images/6363544-790b26976c1c01ad.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)

可以看到唱片视图分为2层，表层放置图片，里层为半透明效果用来模拟唱片边缘。

根据原版的视图层次结构，我们开始封装唱片视图DiscView：
```
@interface DiscView : UIView

- (void)disc_setImageWithUrl:(NSURL *)url;

@end
```

```
@interface DiscView() 

@property(nonatomic,strong)UIView *baseDiscView;
@property(nonatomic,strong)UIImageView *imgDiscView;

@end
```

```
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
```

这里的问题刚才实现自定义按钮时我们也遇到了，baseDiscView的圆角我们直接设置没有问题，imgDiscView由于需要显示图片，如果采用注释的方法设置圆角会导致离屏渲染，这里的解决办法依然是从图片本身进行处理，我们使用了 UIImageView+CornerRadius 这个 category，它使用了UIBezierPath对图片进行圆角裁切处理，核心代码如下：
```
#pragma mark - Kernel
/**
 * @brief clip the cornerRadius with image, UIImageView must be setFrame before, no off-screen-rendered
 */
- (void)zy_cornerRadiusWithImage:(UIImage *)image cornerRadius:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType {
    CGSize size = self.bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cornerRadii = CGSizeMake(cornerRadius, cornerRadius);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    if (nil == currentContext) {
        return;
    }
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCornerType cornerRadii:cornerRadii];
    [cornerPath addClip];
    [self.layer renderInContext:currentContext];
    [self drawBorder:cornerPath];
    UIImage *processedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (processedImage) {
        objc_setAssociatedObject(processedImage, &kProcessedImage, @(1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    self.image = processedImage;
}
```

这种圆角处理方法不会造成离屏渲染，但对view的背景色有要求，因为是直接裁切图片，如果view的背景色不为透明或与父视图背景色不同则会显示出来，建议使用时将view的背景色设为透明或与父视图相同的背景色。

由于我们的图片都是用的SDWebImage加载，使用此方法需要在加载完成后手动对图片进行处理，因此这个category使用了大量的代码将这一过程自动化，它使用了runtime替换了UIImageView的layoutSubViews方法，将图片圆角处理放在这个方法中进行，同时使用了KVO对UIImageView的image属性进行监听，以便图片发生改变时可以及时的进行处理，需要了解详细的实现原理可以移步 [iOS圆角图片实现](http://www.jianshu.com/p/5ccdbaa9e109)

这样我们只要在初始化UIImageView时调用zy_cornerRadiusRoundingRect方法，后面使用SDWebImage加载图片就可以自动进行圆角处理了。

回到Controller，我们创建一个DiscView：
```
@property(nonatomic,strong)DiscView *discView;
```
```
_discView = [[DiscView alloc] initWithFrame:CGRectMake(20, 140, SCREENWIDTH-40, SCREENWIDTH-40)];
[self.view addSubview:_discView];

NSString *imgUrl = _dataArray[0][@"url"];
[_discView disc_setImageWithUrl:[NSURL URLWithString:imgUrl]];
```

效果图：

![Demo](http://upload-images.jianshu.io/upload_images/6363544-77f1367cacf27bb8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)

#####唱片动画及响应事件

这里是本文的核心部分，由于UIView的动画方法不便于封装且调用起来比较麻烦，我们使用CAAnimation来处理唱片动画。关于CAAnimation的详细介绍可以移步 [CAAnimation 核心动画](http://www.jianshu.com/p/b904e52137fe)

唱片动画分为旋转动画和换歌动画，为了方便调用我们封装一个唱片动画管理类JYAnimationManager：
```
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

- (void)jy_pauseAnimationWithLayer:(CALayer *)layer;
- (void)jy_resumeAnimationWithLayer:(CALayer *)layer;

- (void)jy_removeAnimationFromLayer:(CALayer *)layer forKey:(NSString *)key;
- (void)jy_removeAllAnimationFromLayer:(CALayer *)layer;

@end
```

根据需求我们用字符串枚举确定要创建的动画类型。这里之所以使用字符串枚举是因为动画添加到layer时可以设置key，key为NSString *类型，将来可以使用JYAnimationType方便地创建、查找、移除对应的动画。

同样地，我们可以为动画类添加delegate用来传递CAAnimation的代理方法。

核心代码实现：

```
#pragma mark - AnimMethod

- (void)jy_addAnimationWithLayer:(CALayer *)layer forKey:(NSString *)key
{
    if (key == JYAnimationTypeRotaion) {
        [self jy_addRotateAnimationWithLayer:layer];
    }
    else if (key == JYAnimationTypeScaleMove){
        [self jy_addChangeMusicAnimationWithLayer:layer];
    }
    else if (key == JYAnimationTypeFade){
        [self jy_addShowDiscAnimationWithLayer:layer];
    }
    else{
        return;
    }
}

//暂停动画
- (void)jy_pauseAnimationWithLayer:(CALayer *)layer
{
    //申明一个暂停时间为这个层动画的当前时间
    CFTimeInterval currTimeoffset = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0; //当前层的速度
    layer.timeOffset = currTimeoffset; //层的停止时间设为上面申明的暂停时间
}

//恢复动画
- (void)jy_resumeAnimationWithLayer:(CALayer *)layer
{
    CFTimeInterval pausedTime = layer.timeOffset; // 当前层的暂停时间
    /** 层动画时间的初始化值 **/
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    /** end **/
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    CFTimeInterval timePause = timeSincePause - pausedTime; //计算从哪里开始恢复动画
    layer.beginTime = timePause; //让层的动画从停止的位置恢复动效
}

//移除指定动画
-(void)jy_removeAnimationFromLayer:(CALayer *)layer forKey:(NSString *)key
{
    [layer removeAnimationForKey:key];
}

//移除所有动画
-(void)jy_removeAllAnimationFromLayer:(CALayer *)layer
{
    [layer removeAllAnimations];
}
```

旋转动画的代码实现：
```
//创建旋转动画
- (void)jy_addRotateAnimationWithLayer:(CALayer *)layer
{
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"]; //layer绕z轴旋转
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0]; //旋转1圈
    rotationAnimation.duration = 30;  //动画时长
    rotationAnimation.cumulative = YES; //延展效果
    rotationAnimation.repeatCount = HUGE_VALF; //重复次数 HUGE_VALF表示无限重复
    rotationAnimation.delegate = self;

    [layer addAnimation:rotationAnimation forKey:JYAnimationTypeRotaion];
    layer.speed = 1.0; //重设layer的speed防止暂停后没有初始化speed造成动画不播放的问题
}
```
换歌动画，由于换歌动画分为3部分，缩放、平移、渐变，这里使用动画组来实现：

```
//切换唱片动画
- (void)jy_addChangeMusicAnimationWithLayer:(CALayer *)layer
{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"]; //缩放动画
    scaleAnimation.duration = 0.2; //持续时间
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的倍率
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.9]; // 结束时的倍率
    //以下两句同时设置表示动画完成后保持完成时的状态
    scaleAnimation.removedOnCompletion = NO; 
    scaleAnimation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation"]; //平移动画
    moveAnimation.duration = 0.4;
    moveAnimation.beginTime = 0.4; //延迟0.4秒执行
    moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, -[[UIScreen mainScreen] bounds].size.height)]; //目标位置
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"]; //渐变动画
    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0]; //初始透明度
    fadeAnimation.toValue = [NSNumber numberWithFloat:0.0]; //结束透明度
    fadeAnimation.duration = 0.8;
    fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]; //消失速度先慢后快
    fadeAnimation.removedOnCompletion = NO;
    fadeAnimation.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group = [CAAnimationGroup animation]; //创建动画组
    group.duration = 0.8;
    group.animations=@[scaleAnimation,moveAnimation,fadeAnimation]; //包含三种动画
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.delegate = self;
    
    [layer addAnimation:group forKey:JYAnimationTypeScaleMove]; //添加动画组到layer
}
```
换歌过程中，第一张唱片消失的同时，第二张唱片会渐变出现，所以最后我们在封装一个渐变显示唱片的动画：
```
//显示唱片动画
-(void)jy_addShowDiscAnimationWithLayer:(CALayer *)layer
{
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.duration = 0.8;
    
    [layer addAnimation:fadeAnimation forKey:JYAnimationTypeFade];
}
```

delegate传递，我们可以在DiscView中实现manager的代理方法进行动画开始或完成时的回调：
```
#pragma mark - CAAnimationDelegate

-(void)animationDidStart:(CAAnimation *)anim
{
    if ([_delegate respondsToSelector:@selector(jy_animationDidStart:)]) {
        [_delegate jy_animationDidStart:anim];
    }
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([_delegate respondsToSelector:@selector(jy_animationDidStop:finished:)]) {
        [_delegate jy_animationDidStop:anim finished:flag];
    }
}
```
有了JYAnimationManager，下面我们就可以为DiscView创建动画了。
首先在DiscVIew中添加属性，导入头文件这里不多说：
```
@property(nonatomic,strong)JYAnimationManager *jyAManager;
```

使用lazy load，重写getter方法：
```
-(JYAnimationManager *)jyAManager
{
    if (!_jyAManager) {
        _jyAManager=[JYAnimationManager manager];
        _jyAManager.delegate = self;
    }
    
    return _jyAManager;
}
```
之后我们可以使用self.jyAManager调用方法创建动画。

现在让我们回到Controller看下button的回调方法：
```
-(void)buttonClicked:(UIButton *)sender
{
    ConsoleBtn *btn=(ConsoleBtn *)sender;
    switch (btn.consoleType) {
        case ConsoleBtnTypePlay:
        case ConsoleBtnTypePause:
            [self playMusic];
            break;
        case ConsoleBtnTypeLast:
            [self loadingLastMusic];
            break;
        case ConsoleBtnTypeNext:
            [self loadingNextMusic];
            break;
        
            
        default:
            break;
    }
}
```

由于动画受button来控制，我们现在要做的就是：
- 按下播放按钮，唱片开转，按钮变为暂停
- 按下暂停按钮，唱片暂停旋转，按钮变回播放
- 按下上一首／下一首按钮，播放换唱片动画，背景图随之一起变换

######播放／暂停（-playMusic）
在DiscView头文件中添加属性和delegate：
```
#import <UIKit/UIKit.h>

@protocol DiscViewDelegate <NSObject>

- (void)changeDiscDidStart;
- (void)changeDiscDidFinish;

@end


@interface DiscView : UIView

@property (nonatomic,assign) BOOL switchRotate;  //播放暂停状态开关
@property (nonatomic,weak) id <DiscViewDelegate> delegate;

- (void)disc_setImageWithUrl:(NSURL *)url;

@end
```
这个delegate将动画的回调传递到Controller中执行，为换歌动画的回调做准备，暂时先放在一边；我们具体看一下switchRotate属性，这个属性用来控制播放／暂停唱片的旋转动画，具体实现过程如下：
重写setSwitchRotate:方法：

```
-(void)setSwitchRotate:(BOOL)switchRotate
{
    if (_switchRotate!=switchRotate) {
        _switchRotate=switchRotate;
    }
    
    [self checkPlayStatus];
}
```
在-checkPlayStatus方法中判断switchRotate属性的值，YES为播放，NO为暂停：
```
-(void)checkPlayStatus
{
    if (_switchRotate) {
        //如果layer上已有旋转动画，执行恢复动画，否则创建新的动画
        if ([_imgDiscView.layer animationForKey:JYAnimationTypeRotaion]) {
            [self.jyAManager jy_resumeAnimationWithLayer:_imgDiscView.layer];
        }
        else{
            [self.jyAManager jy_addAnimationWithLayer:_imgDiscView.layer forKey:JYAnimationTypeRotaion];
        }
    }
    else{
        //暂停动画
        [self.jyAManager jy_pauseAnimationWithLayer:_imgDiscView.layer];
    }
}
```
回到Controller中实现-playMusic：
```
-(void)playMusic
{
    _discView.switchRotate=!_discView.switchRotate;
}
```
做完这一步，点击中间的大按钮应该就可以控制唱片旋转／暂停了。不过我们还需要根据播放状态切换按钮的播放／暂停状态，因为现在点击播放后，按钮不会变到暂停状态上。我们可以在Controller中使用KVO监听discView的switchRotate属性来实现。

在创建唱片视图的方法中，添加观察者：
```
[_discView addObserver:self forKeyPath:@"switchRotate" options:NSKeyValueObservingOptionNew context:nil];
```
```
#pragma mark - KVO switchRotate
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"switchRotate"]) {
        BOOL switchRotate=[change[NSKeyValueChangeNewKey] boolValue];
        _consoleView.playBtn.consoleType=switchRotate?ConsoleBtnTypePause:ConsoleBtnTypePlay;
    }
}
```

在ConsoleBtn类中，重写consoleType属性的setter方法：
```
-(void)setConsoleType:(ConsoleBtnType)consoleType
{
    if (_consoleType!=consoleType) {
        _consoleType=consoleType;
    }
    
    [self setNeedsDisplay]; //根据consoleType调用drawRect:进行重绘
}
```
最后记得移除观察者：
```
-(void)dealloc
{
    [_discView removeObserver:self forKeyPath:@"switchRotate"];
}
```
这样唱片的旋转／暂停功能基本就实现了，效果图：

![Demo](http://upload-images.jianshu.io/upload_images/6363544-1b5b8b55b6284fb4.gif?imageMogr2/auto-orient/strip)

######上一首／下一首 （-loadingLastMusic／-loadingNextMusic）

由于切换唱片动画需要用到2个DiscView，我们需要重新对Controller中的discView进行设置。

在Controller中添加一个泛型数组用于存储2个DiscView：
```
@property(nonatomic,strong)NSMutableArray <DiscView *> *discViewArray;
```
```
//Lazyload
- (NSMutableArray *)discViewArray
{
    if (!_discViewArray) {
        _discViewArray = [NSMutableArray array];
    }
    
    return _discViewArray;
}
```

移除之前创建的唱片视图，创建新的唱片视图并添加进数组
```
//创建唱片视图
-(void)createDiscView
{
    DiscView *discView1 = [[DiscView alloc] initWithFrame:CGRectMake(20, 140, SCREENWIDTH-40, SCREENWIDTH-40)];
    [discView1 addObserver:self forKeyPath:@"switchRotate" options:NSKeyValueObservingOptionNew context:nil];
    discView1.delegate = self;
    
    [self.view addSubview:discView1];
    
    DiscView *discView2 = [[DiscView alloc] initWithFrame:CGRectMake(20, 140, SCREENWIDTH-40, SCREENWIDTH-40)];
    discView2.delegate = self;
    discView2.alpha = 0; //第二个唱片初始化为隐藏 
    [self.view insertSubview:discView2 belowSubview:discView1]; //将第二个唱片放在第一个下面
    
    [self.discViewArray addObject:discView1];
    [self.discViewArray addObject:discView2];
}
```
由于屏幕中只显示self.discViewArray[0]，我们修改一下-playMusic方法，将_discView改为_discViewarray[0]：

```
-(void)playMusic
{
    _discViewArray[0].switchRotate=!_discViewArray[0].switchRotate;
}
```

下面开始创建切换唱片动画，在DiscView头文件中添加两个新的方法：
```
- (void)takeOutDiscAnim;
- (void)takeInDiscAnim;
```
```
//添加离场动画
-(void)takeOutDiscAnim;
{
   [self.jyAManager jy_addAnimationWithLayer:self.layer forKey:JYAnimationTypeScaleMove];
}
```
```
//添加入场动画
-(void)takeInDiscAnim
{
    [self.jyAManager jy_addAnimationWithLayer:self.layer forKey:JYAnimationTypeFade];
}
```

回到Controller中，实现-loadingLastMusic／-loadingNextMusic：
```
static NSInteger musicIndex = 0;
```
```
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
```

```
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
```
在-changeMusic中做两件事情，播放切换唱片动画、加载下一首歌曲数据：

```
-(void)changeMusic
{
    //如果唱片正在旋转，暂停之
    if (_discViewArray[0].switchRotate) {
        _discViewArray[0].switchRotate = NO;
    }
    [_discViewArray[0] takeOutDiscAnim]; //第一张唱片离场
    [_discViewArray[1] takeInDiscAnim]; //第二张唱片入场
    [self loadingNextImageAtIndex:musicIndex]; //加载下一首歌曲数据
}
```

```
//加载下一首歌曲数据
-(void)loadingNextImageAtIndex:(NSInteger)index
{
    //设置歌曲标题／作者信息
    NSDictionary *titleDic = _dataArray[index][@"titleDic"];
    _titleView.titleDict = titleDic;
    
    NSString *imgUrl = _dataArray[index][@"url"];
    //使用上一张唱片背景图作为placeholder
    UIImage *placeHolder = _baseImgView.image;
    [_baseImgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:placeHolder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            _baseImgView.image = [[image blurImage] jy_lucidImage];
            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionFade;
            transition.duration = 1.0f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [_baseImgView.layer addAnimation:transition forKey:nil];
        }
    }];
    [self.discViewArray[1] disc_setImageWithUrl:[NSURL URLWithString:imgUrl]];
}
```

实现DiscView的delegate，对切换唱片动画开始及完成时进行回调：

```
#pragma mark - DiscViewDelegate

-(void)changeDiscDidStart
{
    _consoleView.consoleBtnEnabled=NO; //离场动画开始时，按钮禁用
    //离场动画开始时，将playBtn设为播放状态
    if (_consoleView.playBtn.consoleType != ConsoleBtnTypePlay) {
        _consoleView.playBtn.consoleType = ConsoleBtnTypePlay;
    }
    
    //为了避免动画完成时出现闪屏，将discView的alpha值修改放在动画开始时进行
    _discViewArray[0].alpha = 0.0;
    _discViewArray[1].alpha = 1.0;
}

-(void)changeDiscDidFinish
{
    _consoleView.consoleBtnEnabled=YES; //离场动画完成时，按钮可用

    //离场动画完成时，自动进入播放状态，按钮状态设置为暂停
    if (_consoleView.playBtn.consoleType != ConsoleBtnTypePause) {
        _consoleView.playBtn.consoleType = ConsoleBtnTypePause;
    }
    
    //移除前一张唱片的观察者，为新的唱片添加观察者
    [_discViewArray[0] removeObserver:self forKeyPath:@"switchRotate"];
    [_discViewArray[1] addObserver:self forKeyPath:@"switchRotate" options:NSKeyValueObservingOptionNew context:nil];
    
    //将新的唱片移到视图最前面
    [self.view bringSubviewToFront:_discViewArray[1]];
    
    //交换两张唱片在数组中的位置，这一步非常关键
    [_discViewArray exchangeObjectAtIndex:0 withObjectAtIndex:1];
    
    //如果新的唱片处在暂停状态，自动开始播放
    if (!_discViewArray[0].switchRotate) {
        [self playMusic];
    }
}
```

这里的按钮禁用可以做一些细节处理，回到ConsoleView中，重写consoleBtnEnabled的setter方法
```
-(void)setConsoleBtnEnabled:(BOOL)consoleBtnEnabled
{
    if (_consoleBtnEnabled != consoleBtnEnabled) {
        _consoleBtnEnabled = consoleBtnEnabled;
    }
    
    _lastBtn.enabled=_consoleBtnEnabled;
    _playBtn.enabled=_consoleBtnEnabled;
    _nextBtn.enabled=_consoleBtnEnabled;
}
```
在ConsoleBtn中，重写enabled属性的setter方法：
```
#pragma mark - OverRide
-(void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    //按钮禁用时，上一首／下一首显示为灰色
    if (self.consoleType == ConsoleBtnTypeLast || self.consoleType == ConsoleBtnTypeNext) {
        [self enabledBtnColor:enabled];
    }
}

-(void)enabledBtnColor:(BOOL)enabled
{
    _btnColor = enabled ? BUTTON_COLOR : DISABLE_COLOR;
    
    self.layer.borderColor=enabled?BUTTON_COLOR.CGColor:DISABLE_COLOR.CGColor;
    [self setNeedsDisplay];
}
```


回到DiscView，看一下如何将JYAnimationManager的delegate传递到Controller中；由于离场和入场动画时间相同且在同一时刻开始，所以delegate中只需要判断是否为其中之一即可：
```
#pragma mark - JYAnimationDelegate

-(void)jy_animationDidStart:(CAAnimation *)anim
{
    //判断是否为离场动画
    if (anim == [self.layer animationForKey:JYAnimationTypeScaleMove]) {
        if ([_delegate respondsToSelector:@selector(changeDiscDidStart)]) {
            [_delegate changeDiscDidStart];
        }

    }
}

-(void)jy_animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //判断离场动画是否正常执行完
    if (anim == [self.layer animationForKey:JYAnimationTypeScaleMove] && flag) {
        //移除视图中所有的动画
        [self.jyAManager jy_removeAnimationFromLayer:_imgDiscView.layer forKey:JYAnimationTypeRotaion];
        [self.jyAManager jy_removeAnimationFromLayer:self.layer forKey:JYAnimationTypeScaleMove];
        if ([_delegate respondsToSelector:@selector(changeDiscDidFinish)]) {
            [_delegate changeDiscDidFinish];
        }
    }
}
```

如果你坚持看到这里，恭喜，整个唱片动画应该已经实现了，效果如下：

![Demo](http://upload-images.jianshu.io/upload_images/6363544-c5a32c07221f1924.gif?imageMogr2/auto-orient/strip)

#####完善与测试

由于CAAnimation动画在app进入后台后会自动移除，所以我们还需要对此进行优化。
在 DiscView的初始化方法中，添加通知：
```
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPlayStatus) name:@"CheckPlayStatus" object:nil];
        [self createDisc];
    }
    
    return self;
}

//app进入后台后动画会被移除，重回前台后需要重新创建
-(void)resetPlayStatus
{
    [self checkPlayStatus]; //根据switchRotate决定播放／暂停动画
}
```
```
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CheckPlayStatus" object:nil];
}
```
在AppDelegate的-applicationDidBecomeActive:中，发送通知：
```
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckPlayStatus" object:nil];
}
```

效果图：

![Demo](http://upload-images.jianshu.io/upload_images/6363544-ef89e62cf36c0458.gif?imageMogr2/auto-orient/strip)

最后的最后，让我们用Instrument的Core Animation工具测试一下demo


![Color Off-screen Rendered](http://upload-images.jianshu.io/upload_images/6363544-3df721c26dbb8ab2.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)


![Color Blended Layers](http://upload-images.jianshu.io/upload_images/6363544-b3be7664e30dadde.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/400)

没有离屏渲染，所有效果使用混合图层模拟，基本和原版的QQ音乐保持一致。

最后看下fps：

![fps测试](http://upload-images.jianshu.io/upload_images/6363544-14556b6a583edc13.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

毫无卡顿感，动画效果非常流畅。

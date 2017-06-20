//
//  UIImage+ImageOpacity.m
//  SpinDiscDemo
//
//  Created by 纪宇伟 on 2017/6/20.
//  Copyright © 2017年 纪宇伟. All rights reserved.
//

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

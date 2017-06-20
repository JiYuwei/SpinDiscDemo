//
//  UIImage+FinalEffects.m
//  SpinDiscDemo
//
//  Created by 纪宇伟 on 2017/6/20.
//  Copyright © 2017年 纪宇伟. All rights reserved.
//

#import "UIImage+FinalEffects.h"
#import <GPUImage/GPUImage.h>

@implementation UIImage (FinalEffects)

-(UIImage *)jy_finalImage
{
    return [self jy_finalImageWithBrightness:-0.5];
}

-(UIImage *)jy_finalImageWithBrightness:(CGFloat)brightness
{
    //创建亮度滤镜对象
    GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
    //原始样子 -1.0 -- 1.0
    filter.brightness = brightness;
    //设置纹理尺寸
    [filter forceProcessingAtSize:self.size];
    [filter useNextFrameForImageCapture];
    //
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:self];
    //添加Target
    [pic addTarget:filter];
    [pic processImage];
    
    UIImage *outPutImage = [filter imageFromCurrentFramebuffer];
    
    return outPutImage;
}

@end

//
//  UIImage+ColorImage.h
//  SpinDiscDemo
//
//  Created by 纪宇伟 on 2017/6/10.
//  Copyright © 2017年 纪宇伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColorImage)

+(UIImage *)jy_imageWithColor:(UIColor *)color;
-(UIImage *)jy_reSizeImage:(CGSize)reSize;

@end

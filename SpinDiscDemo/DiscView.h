//
//  DiscView.h
//  SpinDiscDemo
//
//  Created by 纪宇伟 on 2017/6/10.
//  Copyright © 2017年 纪宇伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DiscViewDelegate <NSObject>

- (void)changeDiscDidStart;
- (void)changeDiscDidFinish;

@end


@interface DiscView : UIView

@property (nonatomic,assign) BOOL switchRotate;  //播放暂停状态开关
@property (nonatomic,weak) id <DiscViewDelegate> delegate;

- (void)takeOutDiscAnim;
- (void)takeInDiscAnim;
- (void)disc_setImageWithUrl:(NSURL *)url;

@end

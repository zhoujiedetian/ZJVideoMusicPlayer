//
//  ZJCoverImageView.m
//  ZJAvPlayer
//
//  Created by 精灵要跳舞 on 17/1/3.
//  Copyright © 2017年 zhiyou. All rights reserved.
//

#import "ZJCoverImageView.h"
@interface ZJCoverImageView()<CAAnimationDelegate>
{
    CADisplayLink* _display ;
}
@end

@implementation ZJCoverImageView
-(void)startRound
{
    if (!_display) {
        _display=[CADisplayLink displayLinkWithTarget:self selector:@selector(roundMove)] ;
        _display.paused=YES ;
        [_display addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes] ;
    }
    _display.paused=NO ;
    _isRound=YES ;
}

-(void)stopRound
{
    _display.paused=YES ;
    [_display invalidate] ;
    _display=nil ;
    _isRound=NO ;
}

-(void)roundMove
{
    self.layer.transform=CATransform3DMakeRotation((_count%360)*M_PI/180.0, 0, 0, 1) ;
    _count++ ;
    _count=_count%360 ;
}

@end

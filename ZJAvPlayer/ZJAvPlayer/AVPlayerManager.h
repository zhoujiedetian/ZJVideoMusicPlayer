//
//  AVPlayerManager.h
//  ZJAvPlayer
//
//  Created by 精灵要跳舞 on 16/12/20.
//  Copyright © 2016年 zhiyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,PlayerState)
{
    ZJPlayerWaiting  = 0 ,
    ZJPlayerPlaying ,
    ZJPlayerPaused ,
    ZJPlayerStoped ,
    ZJPlayerFailToPlay
    
    
} ;

@protocol AVPlayerManagerDelegate <NSObject>

-(void)refreshFatherView:(float)currentTime total:(float)totalTime ;

-(void)loadingBuffer:(BOOL)loading ;

-(void)finishPlay ;

@end
@interface AVPlayerManager : NSObject
@property(nonatomic,weak)id<AVPlayerManagerDelegate> delegate ;
@property(nonatomic,assign)CGFloat playProgress ;
@property(nonatomic,assign)CGFloat bufferProgress ;
@property(nonatomic,assign)PlayerState playerState ;
@property(nonatomic,copy)NSDictionary* songList ;

-(instancetype)initWithUrl:(NSURL* )url ;
-(void)play ;
-(void)pause ;
-(void)next:(BOOL)isNext ;
@end

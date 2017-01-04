//
//  AVPlayerManager.m
//  ZJAvPlayer
//
//  Created by 精灵要跳舞 on 16/12/20.
//  Copyright © 2016年 zhiyou. All rights reserved.
//

#define  WS(weakSelf) __weak __typeof(&*self)weakSelf = self

#import "AVPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import "ZJPlayerNetHandler.h"
#import "NSString+CachePath.h"
@interface AVPlayerManager()<ZJPlayerNetHandlerDelegate>
{
    NSInteger _currentIndex ;
}
@property(nonatomic,strong)NSURL* currentUrl ;
@property(nonatomic,strong)AVPlayer* player ;
@property(nonatomic,strong)AVPlayerItem* currentItem ;
@property(nonatomic,strong)id timeObserver ;
@property(nonatomic,strong)ZJPlayerNetHandler* resourceLoader ;
@end

@implementation AVPlayerManager

-(instancetype)initWithUrl:(NSURL* )url
{
    if (self=[super init]) {
        _currentUrl=url ;
        [self initPlayer] ;
    }
    return self ;
}

-(void)initPlayer
{
    if ([_currentUrl.absoluteString hasPrefix:@"http"]) {
        
       //本地缓存视频
        NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath], [NSString fileNameWithURL:_currentUrl]];
        NSFileManager* manager=[NSFileManager defaultManager] ;
        if ([manager fileExistsAtPath:cacheFilePath]) {
            NSURL* url=[NSURL fileURLWithPath:cacheFilePath] ;
            _currentItem=[AVPlayerItem playerItemWithURL:url] ;
        }else
        {
            //网络视频
            self.resourceLoader=[[ZJPlayerNetHandler alloc]init] ;
            self.resourceLoader.delegate=self ;
            NSURLComponents* components=[[NSURLComponents alloc]initWithURL:_currentUrl resolvingAgainstBaseURL:@""] ;
            components.scheme=@"streaming" ;
            NSLog(@"%@",[components URL]) ;
            AVURLAsset* asset=[AVURLAsset URLAssetWithURL:[components URL] options:nil] ;
            [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()] ;
            _currentItem=[AVPlayerItem playerItemWithAsset:asset] ;
        }
    }else
    {
       //本地视频
        _currentItem=[AVPlayerItem playerItemWithURL:_currentUrl] ;
    }
    _player=[AVPlayer playerWithPlayerItem:_currentItem] ;
    if([[UIDevice currentDevice] systemVersion].intValue>=10){
        //      增加下面这行可以解决ios10兼容性问题了
        self.player.automaticallyWaitsToMinimizeStalling = NO;
    }
    [self addObserver] ;
    
    //初始为waiting
    _playerState=0 ;
}

-(void)addObserver
{
    //播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    //监听缓存状态
    [_currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil] ;
    //监听加载状态
    [_currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil] ;
    
    [_currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil] ;
    [_currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil] ;
    
    //监听播放时间
    WS(weakSelf) ;
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CGFloat current=CMTimeGetSeconds(time) ;
        CGFloat total=CMTimeGetSeconds(weakSelf.currentItem.duration) ;
        weakSelf.playProgress=current/total ;
        if ([weakSelf.delegate respondsToSelector:@selector(refreshFatherView:total:)]) {
            [weakSelf.delegate refreshFatherView:current total:total] ;
        }
    }] ;
    [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
    
    [_currentItem removeObserver:self forKeyPath:@"status"] ;
    [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"] ;
    [_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"] ;
    [_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"] ;
    
    if (_timeObserver) {
        [_player removeTimeObserver:_timeObserver] ;
        _timeObserver=nil ;
    }
    [_player removeObserver:self forKeyPath:@"rate"] ;
}

#pragma mark ----delegate
-(void)playbackFinished
{
    if ([_delegate respondsToSelector:@selector(finishPlay)]) {
        [_delegate finishPlay] ;
    }
    [self next:YES] ;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    AVPlayerItem * songItem = object;
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray * array = songItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue]; //本次缓冲的时间范围
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration); //缓冲总长度
        self.bufferProgress=totalBuffer/CMTimeGetSeconds(_currentItem.duration) ;
        if ([_delegate respondsToSelector:@selector(loadingBuffer:)]) {
            [_delegate loadingBuffer:NO] ;
        }
    }
    
    if ([keyPath isEqualToString:@"rate"])
    {
        if (_player.rate==0.0) {
            _playerState=2 ;
        }else
        {
            _playerState=1 ;
        }
    }
    
    
    
}

#pragma mark - Delegate
- (void)loader:(ZJPlayerNetHandler *)loader cacheProgress:(CGFloat)progress {
    self.bufferProgress=progress ;
    if ([_delegate respondsToSelector:@selector(loadingBuffer:)]) {
        [_delegate loadingBuffer:YES] ;
    }
}

#pragma mark ----EventResponse
-(void)play
{
    if (_playerState == 0 || _playerState == 2) {
        [_player play] ;
    }
}

-(void)pause
{
    if (_playerState==1) {
        [_player pause] ;
    }
}

-(void)stop
{
    [_player pause];
    [self removeObserver];
    _currentItem = nil;
    _player = nil;
    _playProgress = 0.0;
    _bufferProgress = 0.0;
    self.playerState = 3;
}

-(void)next:(BOOL)isNext
{
    [self stop] ;
    if (isNext) {
        _currentIndex++ ;
        if (_currentIndex>_songList.count) {
            _currentIndex=0 ;
        }
    }else
    {
        _currentIndex-- ;
        if (_currentIndex<0) {
            _currentIndex=_songList.count-1 ;
        }
    }
    _currentUrl=[NSURL URLWithString:_songList[@"songList"][_currentIndex]] ;
    [self initPlayer] ;
    [self play] ;
}
@end

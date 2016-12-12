//
//  ViewController.m
//  ZJMusicPlayer
//
//  Created by admin on 16/12/12.
//  Copyright © 2016年 eTanTan. All rights reserved.
//
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVAudioPlayerDelegate>
{
    AVAudioPlayer* _player ;
}
@property(nonatomic,strong)UIButton* playButton ;
@property(nonatomic,strong)UIButton* stopButton ;
@property(nonatomic,strong)UIImageView* topImageView ;
@property(nonatomic,strong)UIButton* recordButton ;
@end

@implementation ViewController
#pragma mark ----LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView] ;
}

#pragma mark ----SetUpView
-(void)setUpView
{
    [self.view addSubview:self.topImageView] ;
    [self.view addSubview:self.playButton] ;
    [self.view addSubview:self.stopButton] ;
    [self.view addSubview:self.recordButton] ;
}

#pragma mark ----AvAudioPlayerDelegate
//播放完成
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"播放完成") ;
}

//播放错误
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    
}
#pragma mark ----EventResponse
-(void)clickPlay
{
    if (_player==nil) {
        
        NSError* error ;
        _player=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"miaoxiao" ofType:@"mp3"]] error:&error] ;
        if (error) {
            
        }
        [_player prepareToPlay] ;
        _player.numberOfLoops=1 ;
        _player.delegate=self ;
    }
    
    if (_player.isPlaying) {
        [_player pause] ;
        self.playButton.backgroundColor=[UIColor blueColor] ;
    }else
    {
        [_player play] ;
        self.playButton.backgroundColor=[UIColor redColor] ;
    }
}

-(void)clickStop
{
    if (_player) {
        [_player stop] ;
        _player.delegate=nil ;
        _player=nil ;
        _playButton.backgroundColor=[UIColor blueColor] ;
    }
}

-(void)cilckRecord
{
   
}

#pragma mark ----PrivateMethod

#pragma mark ----LazyLoading
-(UIButton* )playButton
{
    if (_playButton==nil) {
        _playButton=[UIButton buttonWithType:UIButtonTypeCustom] ;
        _playButton.frame=CGRectMake(ScreenWidth/2-25-30, ScreenHeight/2-25, 50, 50) ;
        _playButton.clipsToBounds=YES ;
        _playButton.layer.cornerRadius=25 ;
        _playButton.backgroundColor=[UIColor blueColor] ;
        [_playButton addTarget:self action:@selector(clickPlay) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _playButton ;
}

-(UIButton* )stopButton
{
    if (!_stopButton) {
        _stopButton=[UIButton buttonWithType:UIButtonTypeCustom] ;
        _stopButton.frame=CGRectMake(ScreenWidth/2-20+30, ScreenHeight/2-20, 40, 40) ;
        _stopButton.backgroundColor=[UIColor grayColor] ;
        [_stopButton addTarget:self action:@selector(clickStop) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _stopButton ;
}

-(UIImageView* )topImageView
{
    if (_topImageView==nil) {
        _topImageView=[[UIImageView alloc]init] ;
        _topImageView.frame=CGRectMake(0, 0, ScreenWidth, 300) ;
        _topImageView.contentMode=1 ;
        _topImageView.image=[UIImage imageNamed:@"miaoxiao.jpg"] ;
    }
    return _topImageView ;
}

-(UIButton* )recordButton
{
    if (!_recordButton) {
        _recordButton=[UIButton buttonWithType:UIButtonTypeCustom] ;
        _recordButton.frame=CGRectMake(ScreenWidth/2-40, ScreenHeight/2+20+10, 80, 40) ;
        [_recordButton setTitle:@"录制" forState:0] ;
        [_recordButton setTitleColor:[UIColor blackColor] forState:0] ;
        _recordButton.layer.borderWidth=1 ;
        _recordButton.layer.borderColor=[UIColor blackColor].CGColor ;
        [_recordButton addTarget:self action:@selector(cilckRecord) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _recordButton ;
}

@end

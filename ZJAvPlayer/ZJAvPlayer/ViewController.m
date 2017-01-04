//
//  ViewController.m
//  ZJAvPlayer
//
//  Created by 精灵要跳舞 on 16/12/15.
//  Copyright © 2016年 zhiyou. All rights reserved.
//
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define  WS(weakSelf) __weak __typeof(&*self)weakSelf = self

#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "UIImageView+WebCache.h"
#import "ZJNextButton.h"
#import "AVPlayerManager.h"
#import "ZJCoverImageView.h"

@interface ViewController ()<AVPlayerManagerDelegate>
{
    NSInteger _currentSelect ;
    BOOL _isPlaying ;
}
@property(nonatomic,copy)NSArray* itemArr ;
@property(nonatomic,copy)NSArray* imageArr ;


@property(nonatomic,strong)UIImageView* backGroundImage ;
@property(nonatomic,strong)ZJCoverImageView* coverImage ;
@property(nonatomic,strong)UIButton* playButton ;
@property(nonatomic,strong)ZJNextButton* leftButton ;
@property(nonatomic,strong)ZJNextButton* rightButton ;
@property(nonatomic,strong)UIProgressView* progress ;
@property(nonatomic,strong)UIProgressView* bufferProgress ;
@property(nonatomic,strong)UILabel* timeLabel ;

@property(nonatomic,strong)AVPlayerManager* playerManager ;
@property(nonatomic,strong)AVPlayer* player ;
@property(nonatomic,strong)AVPlayerItem* currentItem ;

@property(nonatomic,strong)id timeObserve ;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView] ;
}

#pragma mark ----setUpView
-(void)setUpView
{
    self.view.backgroundColor=[UIColor whiteColor] ;
    self.topTitle.text=@"网易云" ;
    self.bottomLine.backgroundColor=UIColorFromRGB(0xd7d7d7) ;
    
    //背景大图
    [self.view addSubview:self.backGroundImage] ;
    [self.backGroundImage sd_setImageWithURL:self.imageArr[_currentSelect]] ;
    [self.backGroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_offset(0) ;
        make.top.mas_equalTo(64) ;
    }] ;
    
    //创建毛玻璃效果
    UIBlurEffect* blurEffect=[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight] ;
    UIVisualEffectView* effectView=[[UIVisualEffectView alloc]initWithEffect:blurEffect] ;
    effectView.frame=CGRectMake(0, 64, KScreenWidth, KScreenHeight) ;
    effectView.alpha=1 ;
    [self.view addSubview:effectView] ;
    
    [self.view addSubview:self.coverImage] ;
    [self.coverImage sd_setImageWithURL:self.imageArr[_currentSelect]] ;
    [self.coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(240) ;
        make.height.offset(240) ;
        make.top.mas_equalTo(64+40) ;
        make.centerX.mas_equalTo(0) ;
    }] ;
    
    [self.view addSubview:self.playButton] ;
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0) ;
        make.bottom.mas_equalTo(-40) ;
        make.width.height.offset(120) ;
    }] ;
    
    [self.view addSubview:self.leftButton] ;
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playButton.mas_centerY).offset(0) ;
        make.left.mas_equalTo(20) ;
        make.width.height.offset(60) ;
    }] ;
    
    [self.view addSubview:self.rightButton] ;
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playButton.mas_centerY).offset(0) ;
        make.right.mas_equalTo(-20) ;
        make.width.height.offset(60) ;
    }] ;
    
    [self.view addSubview:self.bufferProgress] ;
    [self.bufferProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20) ;
        make.right.mas_equalTo(-20) ;
        make.bottom.equalTo(self.playButton.mas_top).offset(-40) ;
        make.height.offset(5) ;
    }] ;
    
    [self.view addSubview:self.progress] ;
    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20) ;
        make.right.mas_equalTo(-20) ;
        make.bottom.equalTo(self.playButton.mas_top).offset(-40) ;
        make.height.offset(5) ;
    }] ;
    
    [self.view addSubview:self.timeLabel] ;
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.progress.mas_right).offset(0) ;
        make.top.equalTo(self.progress.mas_bottom).offset(10) ;
    }] ;
}

#pragma mark ----Delegate
-(void)refreshFatherView:(float)currentTime total:(float)totalTime
{
    if (totalTime>=0) {
        self.progress.progress=_playerManager.playProgress ;
        self.timeLabel.text=[NSString stringWithFormat:@"%@/%@",[self secondsToMinutes:currentTime],[self secondsToMinutes:totalTime]] ;
    }else
    {
        self.timeLabel.text=@"00:00/00:00" ;
    }
}

//缓存
-(void)loadingBuffer:(BOOL)loading
{
   [self.bufferProgress setProgress:_playerManager.bufferProgress animated:loading] ;
}

//播放完成回调
-(void)finishPlay
{
    [self refreshView:YES] ;
}

#pragma mark ----EventResponse
//播放
-(void)clickPlay
{
    if (!_playerManager) {
        _playerManager=[[AVPlayerManager alloc]initWithUrl:[NSURL URLWithString:self.itemArr[0]]] ;
        
        _playerManager.songList=@{@"songList":[self.itemArr copy],@"image":[self.imageArr copy]} ;
        [_playerManager play] ;
        
        _isPlaying=YES ;
        _playerManager.delegate=self ;
        self.playButton.backgroundColor=[UIColor redColor] ;
        
        [self.coverImage startRound] ;
        return ;
    }
    if (!_isPlaying) {
        [_playerManager play] ;
        _isPlaying=YES ;
        self.playButton.backgroundColor=[UIColor redColor] ;
        [self.coverImage startRound] ;
    }else
    {
       [_playerManager pause] ;
        _isPlaying=NO ;
        self.playButton.backgroundColor=[UIColor blueColor] ;
        [self.coverImage stopRound] ;
    }
}

#pragma mark ----PrivateMethod
-(NSString* )secondsToMinutes:(float)time
{
    NSString* minutesTime ;
    int minute=time/60 ;
    int seconds=(int)time%60 ;
    if (minute<10) {
        
        if (seconds<10) {
          minutesTime=[NSString stringWithFormat:@"%@:%@",[NSString stringWithFormat:@"0%d",minute],[NSString stringWithFormat:@"0%d",seconds]] ;
        }else
        {
            minutesTime=[NSString stringWithFormat:@"%@:%d",[NSString stringWithFormat:@"0%d",minute],seconds] ;
        }
       
    }else
    {
        if (seconds<10) {
            minutesTime=[NSString stringWithFormat:@"%d:%@",minute,[NSString stringWithFormat:@"0%d",seconds]] ;
        }else
        {
            minutesTime=[NSString stringWithFormat:@"%d:%d",minute,seconds] ;
        }
    }
    
    return minutesTime ;
}

-(void)refreshView:(BOOL)isNext
{
    _bufferProgress.progress=0.0 ;
    _progress.progress=0.0 ;
    _isPlaying=YES ;
    if (isNext) {
        _currentSelect++ ;
        if (_currentSelect>self.itemArr.count-1) {
            _currentSelect=0 ;
        }
    }else
    {
        _currentSelect-- ;
        if (_currentSelect<0) {
            _currentSelect=self.itemArr.count-1 ;
        }
    }
    
    self.playButton.backgroundColor=[UIColor redColor] ;
    if (!self.coverImage.isRound) {
        [self.coverImage startRound] ;
    }

    [UIView transitionWithView:self.coverImage duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
       [self.coverImage sd_setImageWithURL:[NSURL URLWithString:self.imageArr[_currentSelect]] placeholderImage:[UIImage imageNamed:@""]] ;
        [self.backGroundImage sd_setImageWithURL:[NSURL URLWithString:self.imageArr[_currentSelect]] placeholderImage:[UIImage imageNamed:@""]] ;
    } completion:nil] ;
}

#pragma mark ----LazyLoading
-(NSArray* )itemArr
{
    if (!_itemArr) {
        _itemArr=@[@"http://182.140.142.95/v4.music.126.net/20161227020018/52f8f8205850d30e0dd67b8f1de38580/web/cloudmusic/ODVgYCExZCQgMTAhJDI2Mw==/mv/499091/4b501d1eb977e2c7cd570f3dc170d8a3.mp4?wshc_tag=0&wsts_tag=5860b1f3&wsid_tag=da581d54&wsiphost=ipdbm",@"http://m2.music.126.net/oaTEVivRgmeS2lILneYzoA==/3312828534986116.mp3",@"http://m2.music.126.net/3rZf3dmLBLj7UaCzwhV_Hw==/1042337023140344.mp3"] ;
    }
    return _itemArr ;
}

-(NSArray* )imageArr
{
    if (!_imageArr) {
        _imageArr=@[@"http://p3.music.126.net/5QI8Y7yg6X033usOsgO_YQ==/6622358534316943.jpg",@"http://p4.music.126.net/3x632DWQIBhCzjBk8k_zTA==/6665239488611810.jpg",@"http://p3.music.126.net/pdUYw8LUs6GszgVeZ0osug==/50577534894767.jpg"] ;
    }
    return _imageArr ;
}

-(UIImageView* )backGroundImage
{
    if (!_backGroundImage) {
        _backGroundImage=[UIImageView new] ;
        _backGroundImage.contentMode=2 ;
        _backGroundImage.clipsToBounds=YES ;
        
    }
    return _backGroundImage ;
}

-(ZJCoverImageView* )coverImage
{
    if (!_coverImage) {
        _coverImage=[ZJCoverImageView new] ;
        _coverImage.contentMode=2 ;
        _coverImage.clipsToBounds=YES ;
        _coverImage.layer.cornerRadius=120 ;
        _coverImage.layer.masksToBounds=YES ;
    }
    return _coverImage ;
}

-(UIButton* )playButton
{
    if (!_playButton) {
        _playButton=[UIButton buttonWithType:UIButtonTypeCustom] ;
        _playButton.layer.cornerRadius=60 ;
        _playButton.backgroundColor=[UIColor blueColor] ;
        [_playButton addTarget:self action:@selector(clickPlay) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _playButton ;
}

-(ZJNextButton* )leftButton
{
    if (!_leftButton) {
        _leftButton=[[ZJNextButton alloc]init] ;
        WS(weakSelf) ;
        _leftButton.clickNext=^()
        {
            if (weakSelf.playerManager) {
                [weakSelf refreshView:YES] ;
                [weakSelf.playerManager next:NO] ;
            }
        } ;
    }
    return _leftButton ;
}

-(ZJNextButton* )rightButton
{
    if (!_rightButton) {
        _rightButton=[[ZJNextButton alloc]init] ;
        _rightButton.shapeLayer.path=_rightButton.RightPath.CGPath ;
        WS(weakSelf) ;
        _rightButton.clickNext=^()
        {
            if (weakSelf.playerManager) {
                [weakSelf refreshView:YES] ;
                [weakSelf.playerManager next:YES] ;
            }
        } ;
    }
    return _rightButton ;
}

-(UIProgressView* )progress
{
    if (!_progress) {
        _progress=[[UIProgressView alloc]init] ;
        _progress.progressTintColor=[UIColor darkGrayColor] ;
        _progress.trackTintColor=[UIColor clearColor] ;
        _progress.progress=0.0 ;
    }
    return _progress ;
}

-(UIProgressView* )bufferProgress
{
    if (!_bufferProgress) {
        _bufferProgress=[[UIProgressView alloc]init] ;
        _bufferProgress.progressTintColor=[UIColor lightGrayColor] ;
        _bufferProgress.trackTintColor=[UIColor clearColor] ;
        _bufferProgress.progress=0.0 ;
    }
    return _bufferProgress ;
}

-(UILabel* )timeLabel
{
    if (!_timeLabel) {
        _timeLabel=[UILabel new] ;
        _timeLabel.font=[UIFont systemFontOfSize:10] ;
        _timeLabel.textColor=[UIColor blackColor] ;
        _timeLabel.text=@"00:00" ;
    }
    return _timeLabel ;
}

@end

//
//  BaseViewController.m
//  gcd
//
//  Created by 精灵要跳舞 on 16/8/18.
//  Copyright © 2016年 zhiyou. All rights reserved.
//
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "BaseViewController.h"
#import "Masonry.h"

@interface BaseViewController ()
{
    
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(UILabel* )bottomLine
{
    if (!_bottomLine) {
        _bottomLine=[[UILabel alloc]init] ;
        _bottomLine.backgroundColor=UIColorFromRGB(0xd7d7d7) ;
        [self.topView addSubview:_bottomLine] ;
        [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.topView).offset(0) ;
            make.height.offset(0.5) ;
        }] ;
    }
    return _bottomLine ;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES] ;
    self.navigationController.navigationBarHidden=YES ;
}

-(UIView*)topView
{
    if (!_topView) {
        _topView=[[UIView alloc]init] ;
        [self.view addSubview:_topView] ;
        [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(0) ;
            make.right.equalTo(self.view.mas_right).offset(0) ;
            make.top.equalTo(self.view.mas_top).offset(0) ;
            make.height.offset(64) ;
            
        }] ;
    }
    return _topView ;
}

-(UILabel* )topTitle
{
    if (!_topTitle) {
        _topTitle=[[UILabel alloc]init] ;
        _topTitle.font=[UIFont systemFontOfSize:17] ;
        _topTitle.textColor=UIColorFromRGB(0x009882) ;
        _topTitle.textAlignment=1 ;
        [self.topView addSubview:_topTitle] ;
        [_topTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.mas_top).offset(31) ;
            make.centerX.equalTo(self.topView.mas_centerX).offset(0) ;
        }] ;
    }
    return _topTitle ;
}


-(UIImageView* )topImageView
{
    if (!_topImageView) {
        _topImageView=[[UIImageView alloc]init] ;
        _topImageView.contentMode=UIViewContentModeScaleAspectFill ;
        _topImageView.clipsToBounds=YES ;
        [self.topView addSubview:_topImageView] ;
        [_topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.mas_top).offset(31) ;
            make.centerX.equalTo(self.topView.mas_centerX).offset(0) ;
            make.width.offset(80) ;
            make.height.offset(10) ;
        }] ;
    }
    return _topImageView ;
}


-(UIImageView* )leftImage
{
    if (!_leftImage) {
        _leftImage=[[UIImageView alloc]init] ;
        _leftImage.contentMode=UIViewContentModeScaleAspectFill ;
        [self.topView addSubview:_leftImage] ;
        [_leftImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.mas_top).offset(31);
            make.left.equalTo(self.topView.mas_left).offset(15);
            make.height.offset(22);
            make.width.offset(22);
        }] ;
        
        if (!_leftBtn) {
            _leftBtn=[UIButton buttonWithType:UIButtonTypeCustom] ;
            [_leftBtn addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside] ;
            [self.topView addSubview:_leftBtn] ;
            [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.topView.mas_left).offset(0) ;
                make.top.equalTo(self.topView.mas_top).offset(0) ;
                make.width.equalTo(_leftImage.mas_width).offset(20) ;
                make.height.offset(64) ;
            }] ;
        }
    }
    
    return _leftImage ;
}

-(UIImageView* )rightImage
{
    if (!_rightImage) {
        _rightImage=[[UIImageView alloc]init] ;
        _rightImage.contentMode=UIViewContentModeScaleAspectFill ;
        [self.topView addSubview:_rightImage] ;
        [_rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.mas_top).offset(31);
            make.right.equalTo(self.topView.mas_right).offset(-15);
            make.height.offset(22);
            make.width.offset(22);
        }] ;
        
        if (!_rightBtn) {
            _rightBtn=[UIButton buttonWithType:UIButtonTypeCustom] ;
            
            [_rightBtn addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside] ;
            [self.topView addSubview:_rightBtn] ;
            [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.topView.mas_right).offset(0) ;
                make.top.equalTo(self.topView.mas_top).offset(0) ;
                make.width.equalTo(_rightImage.mas_width).offset(20) ;
                make.height.offset(64) ;
            }] ;
        }
    }
    
    return _rightImage ;
}


-(UILabel* )leftLabel
{
    if (!_leftLabel) {
        _leftLabel=[[UILabel alloc]init] ;
        _leftLabel.font=[UIFont systemFontOfSize:15] ;
        _leftLabel.textColor=UIColorFromRGB(0x009882) ;
        [self.topView addSubview:_leftLabel] ;
        [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topView.mas_left).offset(15) ;
            make.top.equalTo(self.topView.mas_top).offset(32) ;
        }] ;
        
        if (!_leftBtn) {
            _leftBtn=[UIButton buttonWithType:UIButtonTypeCustom] ;
            [_leftBtn addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside] ;
            _leftBtn.alpha=0.5 ;
            [self.topView addSubview:_leftBtn] ;
            [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.topView.mas_left).offset(0) ;
                make.top.equalTo(self.topView.mas_top).offset(0) ;
                make.width.equalTo(_leftLabel.mas_width).offset(20) ;
                make.height.offset(64) ;
            }] ;
        }
    }
    
    return _leftLabel ;
}

-(UILabel* )rightLabel
{
    if (!_rightLabel) {
        _rightLabel=[[UILabel alloc]init] ;
        _rightLabel.font=[UIFont systemFontOfSize:15] ;
        _rightLabel.textColor=UIColorFromRGB(0x009882) ;
        [self.topView addSubview:_rightLabel] ;
        [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.topView.mas_right).offset(-15) ;
            make.top.equalTo(self.topView.mas_top).offset(32) ;
        }] ;
        
        
        if (!_rightBtn) {
            _rightBtn=[UIButton buttonWithType:UIButtonTypeCustom] ;
            [_rightBtn addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside] ;
            _rightBtn.alpha=0.5 ;
            [self.topView addSubview:_rightBtn] ;
            [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.topView.mas_right).offset(0) ;
                make.top.equalTo(self.topView.mas_top).offset(0) ;
                make.width.equalTo(_rightLabel.mas_width).offset(20) ;
                make.height.offset(64) ;
            }] ;
        }
    }
    
    return _rightLabel ;
}


-(void)clickLeftBtn
{
    if (self.leftBlock) {
       self.leftBlock() ;
    }else
    {
        [self.navigationController popViewControllerAnimated:YES] ;
    }
    
}

-(void)clickRightBtn
{
    if (self.rightBlock) {
      self.rightBlock() ;
    }
}


@end

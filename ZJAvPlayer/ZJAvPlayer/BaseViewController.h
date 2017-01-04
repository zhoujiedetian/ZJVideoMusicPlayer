//
//  BaseViewController.h
//  gcd
//
//  Created by 精灵要跳舞 on 16/8/18.
//  Copyright © 2016年 zhiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
@property(nonatomic,strong)UIView* topView ;
@property(nonatomic,strong)UILabel* topTitle ;
@property(nonatomic,strong)UIImageView* topImageView ;
@property(nonatomic,strong)UILabel* bottomLine ;

@property(nonatomic,strong)UIImageView* leftImage ;
@property(nonatomic,strong)UIImageView* rightImage ;
@property(nonatomic,strong)UILabel* leftLabel ;
@property(nonatomic,strong)UILabel* rightLabel ;

@property(nonatomic,strong)UIButton* leftBtn ;
@property(nonatomic,strong)UIButton* rightBtn ;

@property(nonatomic,copy)void(^leftBlock)() ;
@property(nonatomic,copy)void(^rightBlock)() ;
@end

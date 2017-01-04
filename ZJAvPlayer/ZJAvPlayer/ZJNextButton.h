//
//  ZJNextButton.h
//  ZJAvPlayer
//
//  Created by 精灵要跳舞 on 16/12/19.
//  Copyright © 2016年 zhiyou. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
@interface ZJNextButton : UIView
@property(nonatomic,strong)CAShapeLayer* shapeLayer ;
@property(nonatomic,strong)UIBezierPath* RightPath ;
@property(nonatomic,strong)UIBezierPath* shapePath ;
@property(nonatomic,copy)void(^ clickNext)() ;
@end

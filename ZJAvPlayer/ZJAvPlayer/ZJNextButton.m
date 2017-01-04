//
//  ZJNextButton.m
//  ZJAvPlayer
//
//  Created by 精灵要跳舞 on 16/12/19.
//  Copyright © 2016年 zhiyou. All rights reserved.
//

#import "ZJNextButton.h"
//#import <UIKit/UIKit.h>
@interface ZJNextButton()
{
    
}


@end

@implementation ZJNextButton
-(instancetype)init
{
    if (self=[super init]) {
        [self.layer addSublayer:self.shapeLayer] ;
        UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickSelf)] ;
        [self addGestureRecognizer:tap] ;
    }
    return self ;
}

-(void)clickSelf
{
    self.clickNext() ;
}

-(CAShapeLayer* )shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer=[CAShapeLayer layer] ;
        _shapeLayer.path=self.shapePath.CGPath ;
        _shapeLayer.fillColor=[UIColor purpleColor].CGColor ;
    }
    return _shapeLayer ;
}

-(UIBezierPath* )shapePath
{
    if (!_shapePath) {
        _shapePath=[UIBezierPath bezierPath] ;
        [_shapePath moveToPoint:CGPointMake(0, 30)] ;
        [_shapePath addLineToPoint:CGPointMake(60, 0)] ;
        [_shapePath addLineToPoint:CGPointMake(60, 60)] ;
        [_shapePath closePath] ;
    }
    return _shapePath ;
}

-(UIBezierPath* )RightPath
{
    if (!_RightPath) {
        _RightPath=[UIBezierPath bezierPath] ;
        [_RightPath moveToPoint:CGPointMake(0, 0)] ;
        [_RightPath addLineToPoint:CGPointMake(0, 60)] ;
        [_RightPath addLineToPoint:CGPointMake(60, 30)] ;
        [_RightPath closePath] ;
    }
    return _RightPath ;
}

@end

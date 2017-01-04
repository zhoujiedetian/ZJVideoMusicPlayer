//
//  ZJCoverImageView.h
//  ZJAvPlayer
//
//  Created by 精灵要跳舞 on 17/1/3.
//  Copyright © 2017年 zhiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJCoverImageView : UIImageView
@property(nonatomic,assign)int count ;
@property(nonatomic,assign)BOOL isRound ;
-(void)startRound ;
-(void)stopRound ;
@end

//
//  ZJPlayerNetHandler.h
//  ZJAvPlayer
//
//  Created by 精灵要跳舞 on 16/12/21.
//  Copyright © 2016年 zhiyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class ZJPlayerNetHandler;
@protocol ZJPlayerNetHandlerDelegate <NSObject>

@required
- (void)loader:(ZJPlayerNetHandler *)loader cacheProgress:(CGFloat)progress;

@optional
- (void)loader:(ZJPlayerNetHandler *)loader failLoadingWithError:(NSError *)error;

@end
@interface ZJPlayerNetHandler : NSObject<AVAssetResourceLoaderDelegate>
@property(nonatomic,weak)id<ZJPlayerNetHandlerDelegate>  delegate ;
@end

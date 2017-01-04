//
//  ZJPlayerRequestTask.h
//  ZJAvPlayer
//
//  Created by 精灵要跳舞 on 16/12/22.
//  Copyright © 2016年 zhiyou. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ZJPlayerRequestTaskDelegate <NSObject>

@required
- (void)requestTaskDidUpdateCache; //更新缓冲进度代理方法

@optional
- (void)requestTaskDidReceiveResponse ;
- (void)requestTaskDidFinishLoadingWithCache:(BOOL)cache ;
- (void)requestTaskDidFailWithError:(NSError *)error ;

@end
@interface ZJPlayerRequestTask : NSObject
@property(nonatomic,weak)id<ZJPlayerRequestTaskDelegate> delegate ;
@property(nonatomic,strong)NSURL* requestURL ; //请求网址
@property (nonatomic, assign) NSUInteger requestOffset; //请求起始位置
@property (nonatomic, assign) NSUInteger fileLength; //文件长度
@property (nonatomic, assign) NSUInteger cacheLength; //缓冲长度
@property(nonatomic,copy)NSString* contentType ;
@property (nonatomic, assign) BOOL cache; //是否缓存文件
@property (nonatomic, assign) BOOL cancel; //是否取消请求

-(void)start ;
@end

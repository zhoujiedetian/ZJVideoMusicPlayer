//
//  ZJPlayerNetHandler.m
//  ZJAvPlayer
//
//  Created by 精灵要跳舞 on 16/12/21.
//  Copyright © 2016年 zhiyou. All rights reserved.
//

#import "ZJPlayerNetHandler.h"
#import "ZJPlayerRequestTask.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSString+CachePath.h"

#define MimeType @"video/mp4"

@interface ZJPlayerNetHandler()<ZJPlayerRequestTaskDelegate>
{
}
@property(nonatomic,copy)NSMutableArray* requestArr ;
@property(nonatomic,strong)ZJPlayerRequestTask* task ;
@end

@implementation ZJPlayerNetHandler

-(instancetype)init
{
    if (self=[super init]) {
        _requestArr=[[NSMutableArray alloc]init] ;
    }
    return self ;
}

#pragma mark ----ZJPlayerRequestTaskDelegate
- (void)requestTaskDidUpdateCache
{
    [self processRequestList] ;
    if (self.delegate && [self.delegate respondsToSelector:@selector(loader:cacheProgress:)]) {
        CGFloat cacheProgress = (CGFloat)self.task.cacheLength / (self.task.fileLength - self.task.requestOffset);
        [self.delegate loader:self cacheProgress:cacheProgress];
    }
}

- (void)requestTaskDidFinishLoadingWithCache:(BOOL)cache {
//    self.cacheFinished = cache;
}

- (void)requestTaskDidFailWithError:(NSError *)error {
    //加载数据错误的处理
}


#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self responseWithRequest:loadingRequest] ;
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.requestArr removeObject:loadingRequest] ;
}




#pragma mark -----PrivateMethod
-(void)responseWithRequest:(AVAssetResourceLoadingRequest* )loadingRequest
{
    [self.requestArr addObject:loadingRequest] ;
    @synchronized (self) {
        if (self.task) {
            if (loadingRequest.dataRequest.requestedOffset >= self.task.requestOffset &&
                loadingRequest.dataRequest.requestedOffset <= self.task.requestOffset + self.task.cacheLength) {
                //数据已经缓存，则直接完成
                [self processRequestList];
            }else {
                //数据还没缓存，则等待数据下载；如果是Seek操作，则重新请求
//                if (self.seekRequired) {
//                    NSLog(@"Seek操作，则重新请求");
//                    [self newTaskWithLoadingRequest:loadingRequest cache:NO];
//                }
            }
        }else
        {
            [self newDataTaskWithRequest:loadingRequest shouldCache:YES] ;
        }
    }
}

-(void)newDataTaskWithRequest:(AVAssetResourceLoadingRequest* )loadingRequest shouldCache:(BOOL)cache
{
    NSUInteger fileLength = 0;
    if (self.task) {
        fileLength = self.task.fileLength;
        self.task.cancel = YES;
//        NSLog(@"进行了123456789") ;
    }
    self.task = [[ZJPlayerRequestTask alloc]init];
    self.task.requestURL = loadingRequest.request.URL;
    self.task.requestOffset = loadingRequest.dataRequest.requestedOffset;
    self.task.cache = cache;
    if (fileLength > 0) {
        self.task.fileLength = fileLength;
    }
    self.task.delegate = self;
    [self.task start];
//    self.seekRequired = NO;
}

- (void)processRequestList {
    NSMutableArray * finishRequestList = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest * loadingRequest in self.requestArr) {
        if ([self finishLoadingWithLoadingRequest:loadingRequest]) {
            [finishRequestList addObject:loadingRequest];
//            [loadingRequest finishLoading] ;
        }
    }
    [self.requestArr removeObjectsInArray:finishRequestList];
}

- (BOOL)finishLoadingWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    //填充信息
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(MimeType), NULL);
    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType) ;
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadingRequest.contentInformationRequest.contentLength = self.task.fileLength;
    
    //读文件，填充数据
    NSUInteger cacheLength = self.task.cacheLength;
    NSUInteger requestedOffset = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != 0) {
        requestedOffset = loadingRequest.dataRequest.currentOffset;
    }
    NSUInteger canReadLength = cacheLength - (requestedOffset - self.task.requestOffset);
    NSUInteger respondLength = MIN(canReadLength, loadingRequest.dataRequest.requestedLength);
    
    
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:[NSString tempPath]];
    [handle seekToFileOffset:requestedOffset - self.task.requestOffset];
    //填充数据
//    NSLog(@"-------%lu",(unsigned long)[[handle readDataOfLength:respondLength] length]) ;
    [loadingRequest.dataRequest respondWithData:[handle readDataOfLength:respondLength]] ;
    
    //如果完全响应了所需要的数据，则完成
    NSUInteger nowendOffset = requestedOffset + canReadLength;
    NSUInteger reqEndOffset = loadingRequest.dataRequest.requestedOffset + loadingRequest.dataRequest.requestedLength;
    if (nowendOffset >= reqEndOffset) {
        [loadingRequest finishLoading] ;
        return YES;
    }
    return NO;
}


@end

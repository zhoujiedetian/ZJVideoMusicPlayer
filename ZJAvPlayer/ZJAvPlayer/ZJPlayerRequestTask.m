//
//  ZJPlayerRequestTask.m
//  ZJAvPlayer
//
//  Created by 精灵要跳舞 on 16/12/22.
//  Copyright © 2016年 zhiyou. All rights reserved.
//
#define RequestTimeout 10.0

#import "ZJPlayerRequestTask.h"
#import "NSString+CachePath.h"
@interface ZJPlayerRequestTask()<NSURLSessionDelegate>
{
    
}
@property(nonatomic,strong)NSURLSession* session ;
@property(nonatomic,strong)NSURLSessionDataTask* task ;
@end

@implementation ZJPlayerRequestTask
-(instancetype)init
{
    if (self=[super init]) {
      NSString* path=[[NSHomeDirectory( ) stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"MusicTemp.mp4"] ;
        NSFileManager* manager=[NSFileManager defaultManager] ;
        if ([manager fileExistsAtPath:path]) {
            [manager removeItemAtPath:path error:nil] ;
        }
        [manager createFileAtPath:path contents:nil attributes:nil] ;
    }
    
    return self ;
}

-(void)start
{
    NSURLComponents* components=[[NSURLComponents alloc]initWithURL:_requestURL resolvingAgainstBaseURL:@""] ;
    components.scheme=@"http" ;
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[components URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:RequestTimeout];
    if (self.requestOffset > 0) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld", self.requestOffset, self.fileLength - 1] forHTTPHeaderField:@"Range"];
    }
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
}

- (void)setCancel:(BOOL)cancel {
    _cancel = cancel;
    [self.task cancel];
    [self.session invalidateAndCancel];
}

#pragma mark - NSURLSessionDataDelegate
//服务器响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    if (self.cancel)
        return;
    completionHandler(NSURLSessionResponseAllow);
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    NSString * contentRange = [[httpResponse allHeaderFields] objectForKey:@"Content-Range"];
    NSString * fileLength = [[contentRange componentsSeparatedByString:@"/"] lastObject];
    
    self.fileLength = fileLength.integerValue > 0 ? fileLength.integerValue : response.expectedContentLength;
    
    self.contentType=[[httpResponse allHeaderFields] objectForKey:@"Content-Type"] ;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidReceiveResponse)]) {
        [self.delegate requestTaskDidReceiveResponse];
    }
}

//服务器返回数据 可能会调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (self.cancel)
        return;
    NSFileHandle* handle=[NSFileHandle fileHandleForWritingAtPath:[NSString tempPath]] ;
    [handle seekToEndOfFile] ;
    [handle writeData:data] ;
    self.cacheLength += data.length;
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidUpdateCache)]) {
        [self.delegate requestTaskDidUpdateCache];
    }
}

//请求完成会调用该方法，请求失败则error有值
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (self.cancel) {
        NSLog(@"下载取消");
    }else {
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidFailWithError:)]) {
                [self.delegate requestTaskDidFailWithError:error];
            }
        }else {
            //可以缓存则保存文件
            if (self.cache) {
                NSFileManager * manager = [NSFileManager defaultManager];
                if (![manager fileExistsAtPath:[NSString cacheFolderPath] ]) {
                    [manager createDirectoryAtPath:[NSString cacheFolderPath] withIntermediateDirectories:YES attributes:nil error:nil];
                }
                NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath] , [[_requestURL.path componentsSeparatedByString:@"/"] lastObject]] ;
                BOOL success = [[NSFileManager defaultManager] copyItemAtPath:[NSString tempPath] toPath:cacheFilePath error:nil];
                NSLog(@"cache file : %@", success ? @"success" : @"fail");
                NSLog(@"%@",cacheFilePath) ;
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidFinishLoadingWithCache:)]) {
                [self.delegate requestTaskDidFinishLoadingWithCache:self.cache];
            }
            
            
        }
    }
}

@end

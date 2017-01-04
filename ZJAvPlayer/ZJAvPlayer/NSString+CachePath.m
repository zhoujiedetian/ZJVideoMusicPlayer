//
//  NSString+CachePath.m
//  ZJAvPlayer
//
//  Created by 精灵要跳舞 on 16/12/22.
//  Copyright © 2016年 zhiyou. All rights reserved.
//

#import "NSString+CachePath.h"

@implementation NSString (CachePath)
//临时文件路径
+(NSString* )tempPath
{
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"MusicTemp.mp4"] ;
}

+ (NSString *)cacheFolderPath
{
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"MusicCaches"];
}

+ (NSString *)fileNameWithURL:(NSURL *)url {
    return [[url.path componentsSeparatedByString:@"/"] lastObject];
}
@end

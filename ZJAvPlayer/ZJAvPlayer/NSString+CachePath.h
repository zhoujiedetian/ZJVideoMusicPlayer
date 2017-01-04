//
//  NSString+CachePath.h
//  ZJAvPlayer
//
//  Created by 精灵要跳舞 on 16/12/22.
//  Copyright © 2016年 zhiyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CachePath)
//临时路径文件
+(NSString* )tempPath ;

//保存目录文件夹
+ (NSString *)cacheFolderPath ;

+ (NSString *)fileNameWithURL:(NSURL *)url ;
@end

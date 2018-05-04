//
//  SYDownloadModel.m
//  JKDB数据库下载
//
//  Created by 谷胜亚 on 2017/8/22.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

#import "SYDownloadModel.h"
#import "SYFileManager.h"
#import <CommonCrypto/CommonDigest.h>

/**根据字符串获得对应MD5字符串*/
static NSString * getMD5String(NSString *str) {
    
    if (str == nil) return nil;
    
    const char *cstring = str.UTF8String;
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstring, (CC_LONG)strlen(cstring), bytes);
    
    NSMutableString *md5String = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", bytes[i]];
    }
    return md5String;
}

@implementation SYDownloadModel

- (NSString *)Name_File
{
    return [getMD5String(self.Path_SourceDownload) stringByAppendingString: [@"." stringByAppendingString:self.Path_SourceDownload.pathExtension]];
}

- (NSString *)Name_Folder
{
    return self.Path_FolderRelative.lastPathComponent;
}

/// 该时刻沙盒完整路径
- (NSString *)realtimeFullPath
{
    return [[SYFileManager relativeBasePath] stringByAppendingString:self.Path_FileRelative];
}

#pragma mark- <-----------  不保存到数据库中的字段  ----------->
+ (NSArray *)transients
{
    return @[@"Name_File", @"Name_Folder", @"realtimeFullPath"];
}

@end

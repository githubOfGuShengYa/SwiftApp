//
//  SYDownloadModel.h
//  JKDB数据库下载
//
//  Created by 谷胜亚 on 2017/8/22.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

#import "JKDBModel.h"
#import "SYDownloadDefine.h"

@interface SYDownloadModel : JKDBModel

#pragma mark- <-----------  保存到本地下载记录中的属性  ----------->

/// 资源下载路径
@property (nonatomic, copy) NSString *Path_SourceDownload;

/// 资源所属文件夹相对路径
@property (nonatomic, copy) NSString *Path_FolderRelative;

/// 资源保存到本地的相对路径 -- 由于苹果的沙盒机制会导致路径不停更改
@property (nonatomic, copy) NSString *Path_FileRelative;

/// 资源已经被写入内存的字节总数
@property (nonatomic, assign) int64_t Bytes_TotalWritten;

/// 资源文件总的字节数
@property (nonatomic, assign) int64_t Bytes_Total;

/// 当前下载状态
@property (nonatomic, assign) SYSourceDownloadState state;

#pragma mark- <-----------  不保存到本地的属性  ----------->

/// 资源保存到本地的文件名
@property (nonatomic, copy) NSString *Name_File;

/// 资源所属文件夹名
@property (nonatomic, copy) NSString *Name_Folder;

/// 实时完整路径
@property (nonatomic, copy) NSString *realtimeFullPath;

@end

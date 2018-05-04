//
//  SYDownloadDefine.h
//  AFNTest
//
//  Created by 谷胜亚 on 2017/7/5.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYDownloadDefine : NSObject

@end

#pragma mark <-----------  下载的增删改查参数 ----------->
/// 传入的文件夹完整路径
extern NSString *const SYDownloadParameterFolderPath;
/// 传入的下载进度block
extern NSString *const SYDownloadParameterProgress;
/// 传入的下载状态block
extern NSString *const SYDownloadParameterState;
/// 传入的下载速度block
extern NSString *const SYDownloadParameterSpeed;
/// 创建的下载操作operation
extern NSString *const SYDownloadCreateOperation;

/// 下载参数类型
typedef NS_ENUM(NSUInteger, SYDownloadParameterType) {
    /// 资源保存文件夹名
    SYDownloadParameterTypeFolderPath,
    /// 资源下载进度block
    SYDownloadParameterTypeProgress,
    /// 资源下载状态改变block
    SYDownloadParameterTypeStateChange,
    /// 资源下载速度block
    SYDownloadParameterTypeSpeed,
    /// 资源下载操作
    SYDownloadParameterTypeOperation,
};

/// 单个资源下载状态
typedef NS_ENUM(NSUInteger, SYSourceDownloadState) {
    /// 资源初始状态
    SYSourceDownloadNone,
    /// 资源等待下载状态
    SYSourceDownloadWaiting,
    /// 资源下载中状态
    SYSourceDownloading,
    /// 资源取消下载状态 -- 暂停状态同样以该状态显示
    SYSourceDownloadCancel,
    /// 资源下载错误状态
    SYSourceDownloadFailed,
    /// 资源下载完成状态
    SYSourceDownloadCompleted,
    /// 链接失效
    SYSourceDownloadLinksExpired
};


#pragma mark <-----------  声明  ----------->
#define DOWNLOAD_RECORD_FILE_NAME @"downloadRecordFile.data"  // 下载记录文件名

@class SYDownloadRecord;
/// 完成回调block
typedef void(^Block_CompletionHandle)();

/** 下载状态回调block */
typedef void(^Block_DownloadStateChanged)(SYSourceDownloadState state);
/**
 *  下载进度回调block
 *
 *  @param totalBytesWritten 已经下载到本地的字节数
 */
typedef void(^Block_DownloadProgress)(int64_t totalBytesWritten, int64_t totalBytes);

/// 下载速度回调block -- 参数是一秒内下载的大小
typedef void(^Block_DownloadSpeed)(int64_t secondDownloadSize);

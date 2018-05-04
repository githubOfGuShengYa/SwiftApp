//
//  SYDownloadManager.h
//  AFNTest
//
//  Created by 谷胜亚 on 2017/5/15.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "SYDownloadDefine.h"

@class SYDownloadModel;
@interface SYDownloadManager : NSObject




/// 已保存的下载记录模型数组
@property (nonatomic, strong) NSMutableArray *downloadRecordArray;

/// 下载记录文件名
@property (nonatomic, copy, readonly) NSString *downloadRecordFileName;



#pragma mark ===初始化 -- 单例====
/**单例类方法*/
+ (instancetype)shared;

- (SYDownloadModel *)findDownloadModelWithSourceURL:(NSString *)url;

#pragma mark <-----------  操作方法  ----------->

/**
 添加下载任务

 @param url 资源下载地址
 @param folderPath 保存到文件夹的路径
 */
- (void)addDownloadTaskWithURL:(NSString *)url saveTo:(NSString *)folderPath;


/**
 展示下载任务

 @param model 资源下载模型
 @param progressBlock 回调下载进度(已下载进度, 总大小)
 @param stateBlock 回调下载状态(下载模型, 是否错误)
 @param speedBlock 回调下载速度(1s内下载字节, 下载速度字符串1MB/s)
 */
- (void)showDownloadTaskWithModel:(SYDownloadModel *)model progress:(Block_DownloadProgress)progressBlock state:(Block_DownloadStateChanged)stateBlock speed:(Block_DownloadSpeed)speedBlock;

/**
 *  取消对应下载操作
 *
 *  @param url 资源url字符串
 *
 *  @param completion 取消事件完成回调block
 */
- (void)cancelOperationByDownloadURL:(NSString *)url completion:(void(^)())completion;


/// 取消所有下载操作
- (void)cancelAllOperationsWithCompletionHandle:(void(^)())completion;

// 全部开始下载
- (void)allStartDownload;

/**
 *  重置取消下载或下载失败操作
 *
 *  @param url 下载资源url
 */
- (void)resetCancelOrFailedOperationWithSourceURL:(NSString *)url;

/**
 *  通过下载记录模型删除指定资源文件
 *
 *  @param url 资源链接
 */
- (void)deleteSourceFileBySourceURL:(NSString *)url completion:(void (^)(BOOL isSuccess))completion;



#pragma mark <-----------  M3U8下载时必须保证这两个值为YES  ----------->
/// 在不实现断点续传的情况下允许下载 -- YES可以 / NO不可以
@property (nonatomic, assign) BOOL allowDownloadWithoutContinue;

/// 不需要重置就允许下载 -- 默认为NO也就是需要重置
@property (nonatomic, assign) BOOL allowDownloadWithoutReset;




@end

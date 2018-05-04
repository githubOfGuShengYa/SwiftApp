//
//  SYDownloadOperation.h
//  AFNTest
//
//  Created by 谷胜亚 on 2017/5/15.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//  自定义并发NSOperation
/*
 *自定义并发的NSOperation需要以下步骤：
 1.start方法：该方法必须实现，
 2.main:该方法可选，如果你在start方法中定义了你的任务，则这个方法就可以不实现，但通常为了代码逻辑清晰，通常会在该方法中定义自己的任务
 3.isExecuting  isFinished 主要作用是在线程状态改变时，产生适当的KVO通知
 4.isConcurrent :必须覆盖并返回YES;
 */

#import <Foundation/Foundation.h>

#import "SYDownloadDefine.h"

@interface SYDownloadOperation : NSOperation<NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

/**资源url字符串*/
@property (nonatomic, copy) NSString *sourceURL;

@property (nonatomic, strong, readonly) NSURLSessionTask *dataTask;


@property (nonatomic, copy) Block_CompletionHandle completionHandle;


#pragma mark <-----------  初始化方法  ----------->
/**
 *  初始化方法
 *
 *  @param request URL请求对象
 *
 *  @param session 该操作所在会话对象
 *
 *  @param folderPath 该资源保存到的文件夹路径
 *
 *  @return 初始化的操作对象
 */
- (instancetype)initWithRequest:(NSURLRequest *)request inSession:(NSURLSession *)session saveTo:(NSString *)folderPath;

/**
 *  取消任务
 */
- (void)cancelTaskCompletionHandle:(Block_CompletionHandle)completion;

/**
 *  设置回调block -- 下载进度和下载完成状态
 *
 *  @param progressBlock 下载进度block
 *
 *  @param downloadStateBlock 下载完成状态block
 *
 *  @param size 下载速度block
 */
- (void)settingCallbackBlockOfProgress:(Block_DownloadProgress)progressBlock downloadState:(Block_DownloadStateChanged)downloadStateBlock SecondDownloadSize:(Block_DownloadSpeed)size;





@end

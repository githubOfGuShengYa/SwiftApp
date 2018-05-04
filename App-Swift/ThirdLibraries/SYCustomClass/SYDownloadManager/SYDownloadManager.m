//
//  SYDownloadManager.m
//  AFNTest
//
//  Created by 谷胜亚 on 2017/5/15.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

#import "SYDownloadManager.h"
#import "SYDownloadOperation.h"
#import <UIKit/UIKit.h>
#import "SYFileManager.h"
#import "SYDownloadModel.h"


#define MaxOperationCount 1 // 最大并发数



@interface SYDownloadManager ()<NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (strong, nonatomic, nullable) dispatch_queue_t barrierQueue;

#pragma mark <-----------  下载队列控制  ----------->
@property (nonatomic, strong) NSMutableArray *downloadingQueue;
@property (nonatomic, strong) NSMutableArray *waitingQueue;
@property (nonatomic, strong) NSMutableArray *cancelQueue;
@property (nonatomic, strong) NSMutableArray *failedQueue;
@property (nonatomic, strong) NSMutableArray *invalidLinkQueue;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;

#pragma mark <-----------  新版属性  ----------->
@property (nonatomic, strong) NSMutableDictionary *downloadFileParametersDic;




@end
@implementation SYDownloadManager

#pragma mark =======初始化方法=======

+ (instancetype)shared
{
    static SYDownloadManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SYDownloadManager alloc] init];
    });
    
    return _instance;
}


- (instancetype)init
{
    return [self initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}


- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super init];
    if (self) {
        
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = MaxOperationCount;
        _downloadQueue.name = @"com.gushengya";
        configuration.timeoutIntervalForRequest = 15;
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        _barrierQueue = dispatch_queue_create("com.gushengya.SYDownloadManagerBarrierQueue", DISPATCH_QUEUE_CONCURRENT);

        self.downloadingQueue = [NSMutableArray array];
        self.waitingQueue = [NSMutableArray array];
        self.cancelQueue = [NSMutableArray array];
        self.failedQueue = [NSMutableArray array];
        self.invalidLinkQueue = [NSMutableArray array];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (SYDownloadModel *)findDownloadModelWithSourceURL:(NSString *)url
{
    return [SYDownloadModel findFirstByCriteria: [NSString stringWithFormat:@"where Path_SourceDownload='%@';", url]];
}

- (SYDownloadModel *)insertDownloadModelWithSourceURL:(NSString *)url FolderPath:(NSString *)folderPath
{
    NSAssert(url, @"传入的资源url不能为空");
    NSAssert(folderPath, @"传入的文件夹路径不能为空");
    
    SYDownloadModel *model = [[SYDownloadModel alloc] init];
    // 下载路径
    model.Path_SourceDownload = url;
    // 文件夹相对路径
    model.Path_FolderRelative = @"";
    // 保存的相对路径
    model.Path_FileRelative = @"";
    // 已写入字节数
    model.Bytes_TotalWritten = 0;
    // 总字节数
    model.Bytes_Total = 0;
    // 下载状态
    model.state = SYSourceDownloadNone;
    
    
    NSAssert([folderPath hasPrefix:[SYFileManager relativeBasePath]], @"插入下载模型传入的保存路径不对");
    
    model.Path_FolderRelative = [folderPath substringFromIndex:[SYFileManager relativeBasePath].length];
    

    [model save];
    
    return model;
}





#pragma mark <-----------  下载删除等操作方法  ----------->
// 添加下载任务 -- 并传入保存的文件夹路径
- (void)addDownloadTaskWithURL:(NSString *)url saveTo:(NSString *)folderPath
{
    NSMutableDictionary *parameters = self.downloadFileParametersDic[url];
    if (parameters == nil) {
        // 根据url保存相应属性
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:folderPath forKey:SYDownloadParameterFolderPath]; // 保存到该文件夹路径下
        [self.downloadFileParametersDic setValue:dic forKey:url];
    }else {
        [parameters setValue:folderPath forKey:SYDownloadParameterFolderPath]; // 保存到该文件夹路径下
    }

    SYDownloadModel *model = [self findDownloadModelWithSourceURL:url];
    if (!model) {
        model = [self insertDownloadModelWithSourceURL:url FolderPath:folderPath];
    }
    
    // 判断下载记录的状态
    switch (model.state) {
            
        case SYSourceDownloadNone:
        case SYSourceDownloadWaiting:
        case SYSourceDownloading:
            [self setupOperationWithDownloadModel:model];
            break;
            
        case SYSourceDownloadCancel:
            if (self.allowDownloadWithoutReset) {
                [self setupOperationWithDownloadModel:model];
            }else {
                
                [self.cancelQueue addObject:url];
            }
            
            break;
            
        case SYSourceDownloadFailed:
            if (self.allowDownloadWithoutReset) {
                [self setupOperationWithDownloadModel:model];
            }else {
                
                [self.failedQueue addObject:url];
            }
            
            break;
            
        case SYSourceDownloadLinksExpired:
        {
            
        }
            break;
            
        case SYSourceDownloadCompleted:
        {

        }
            break;
            
        default:
            break;
    }
}

// 设置操作
- (void)setupOperationWithDownloadModel:(SYDownloadModel *)model
{
    __weak SYDownloadManager *weakSelf = self;
    
    [weakSelf addOperationByURL:model.Path_SourceDownload downloadOperation:^SYDownloadOperation *{

        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:model.Path_SourceDownload]];
        
        if (!strongSelf.allowDownloadWithoutContinue) {
            long long currentSize = model.Bytes_TotalWritten;
            if (currentSize > 0) {
                NSString *range = [NSString stringWithFormat:@"bytes=%zd-", currentSize];
                [mutableRequest setValue:range forHTTPHeaderField:@"Range"];
            }
        }else {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:model.realtimeFullPath error:nil];
        }
        
        SYDownloadOperation *downloadOperation = [[SYDownloadOperation alloc] initWithRequest:mutableRequest inSession:strongSelf.session saveTo:model.Path_FolderRelative];

        if (model.state == SYSourceDownloading) {
            [strongSelf.downloadingQueue addObject:downloadOperation];
            [strongSelf.downloadQueue addOperation:downloadOperation];
        }else if (model.state == SYSourceDownloadWaiting) {
            [strongSelf.waitingQueue addObject:downloadOperation];
            model.state = SYSourceDownloadWaiting;
            [model update];
        }else {
            if (self.downloadingQueue.count < MaxOperationCount) {
                [strongSelf.downloadingQueue addObject:downloadOperation];
                [strongSelf.downloadQueue addOperation:downloadOperation];
                
            }else {
                
                [strongSelf.waitingQueue addObject:downloadOperation];
                
                model.state = SYSourceDownloadWaiting;
                [model update];
            }
        }
        
        [self downloadStateChangedWithDownloadModel:model];
        
        return downloadOperation;
    }];
}

/**
 *  通过资源url字符串添加SYDownloadOperation操作对象到下载队列中
 */
- (void)addOperationByURL:(NSString *)url downloadOperation:(SYDownloadOperation *(^)())operationSettingBlock
{
    __weak typeof(self) weakSelf = self;

    dispatch_barrier_sync(weakSelf.barrierQueue, ^{
        
        NSMutableDictionary *dic = weakSelf.downloadFileParametersDic[url];
        SYDownloadOperation *op = dic[SYDownloadCreateOperation];
        
        if (op == nil) {

            op = operationSettingBlock();
            
            __block Block_DownloadProgress progressBlock = [weakSelf get_parameterByURL:url type:SYDownloadParameterTypeProgress];
            __block Block_DownloadStateChanged stateBlock = [weakSelf get_parameterByURL:url type:SYDownloadParameterTypeStateChange];
            __block Block_DownloadSpeed speedBlock = [weakSelf get_parameterByURL:url type:SYDownloadParameterTypeSpeed];
            if (progressBlock != nil || stateBlock != nil || speedBlock != nil) {
                [op settingCallbackBlockOfProgress:progressBlock downloadState:stateBlock SecondDownloadSize:speedBlock];
            }
            
            dic[SYDownloadCreateOperation] = op;
            
            __weak SYDownloadOperation *weakOperation = op;
            op.completionBlock = ^{
                if (!weakOperation) return ;
                
                if (dic[SYDownloadCreateOperation] == weakOperation) {
                    [dic removeObjectForKey:url];
                }

                if (weakOperation.completionHandle) {
                    weakOperation.completionHandle();
                }
                
                
                [weakSelf changeDownloadQueueWithURL:url];
            };
        }
    });
}

// 展示下载任务 -- 并回调下载进度、下载状态、下载速度
- (void)showDownloadTaskWithModel:(SYDownloadModel *)model progress:(Block_DownloadProgress)progressBlock state:(Block_DownloadStateChanged)stateBlock speed:(Block_DownloadSpeed)speedBlock
{
    NSAssert(model, @"传入的model不能为空");
    NSMutableDictionary *parameters = self.downloadFileParametersDic[model.Path_SourceDownload];
    if (parameters != nil) {
        
        [parameters setValue:progressBlock forKey:SYDownloadParameterProgress];
        [parameters setValue:stateBlock forKey:SYDownloadParameterState];
        [parameters setValue:speedBlock forKey:SYDownloadParameterSpeed];
    }else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:progressBlock forKey:SYDownloadParameterProgress];
        [dic setValue:stateBlock forKey:SYDownloadParameterState];
        [dic setValue:speedBlock forKey:SYDownloadParameterSpeed];
        [self.downloadFileParametersDic setValue:dic forKey:model.Path_SourceDownload];
    }
    
    SYDownloadOperation *op = [self get_parameterByURL:model.Path_SourceDownload type:SYDownloadParameterTypeOperation];
    
    if (op != nil) {
        NSLog(@"---------");
        [op settingCallbackBlockOfProgress:progressBlock downloadState:stateBlock SecondDownloadSize:speedBlock];
    }
    
    if (stateBlock) {
        stateBlock(model.state);
    }
    if (progressBlock) {
        progressBlock(model.Bytes_TotalWritten, model.Bytes_Total);
    }
    if (speedBlock) {
        speedBlock(0);
    }
}

// 重置取消或下载失败操作
- (void)resetCancelOrFailedOperationWithSourceURL:(NSString *)url
{
    SYDownloadModel *model = [self findDownloadModelWithSourceURL:url];

    model.state = SYSourceDownloadNone;

    [self setupOperationWithDownloadModel:model];
}

// 取消所有下载操作和等待下载操作
- (void)cancelAllOperationsWithCompletionHandle:(void(^)())completion
{
    for (SYDownloadOperation *op in self.waitingQueue) {
        
        @synchronized (self) {
            [self.cancelQueue addObject:op.sourceURL];
        
            SYDownloadModel *model = [self findDownloadModelWithSourceURL:op.sourceURL];
            model.state = SYSourceDownloadCancel;
            [model update];

            NSMutableDictionary *dic = self.downloadFileParametersDic[op.sourceURL];
            [dic removeObjectForKey:SYDownloadCreateOperation];

            Block_DownloadStateChanged state = [self get_parameterByURL:op.sourceURL type:SYDownloadParameterTypeStateChange];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (state) {
                    state(model.state);
                }
            });

        }
    }

    [self.waitingQueue removeAllObjects];

    NSArray *operationArr = [NSArray arrayWithArray:self.downloadingQueue];
    for (SYDownloadOperation *op in operationArr) {
        
        @synchronized (self) {
            
            [op cancelTaskCompletionHandle:^{
                
                [self.cancelQueue addObject:op.sourceURL];
                
                [self.downloadingQueue removeObject:op];

                NSMutableDictionary *dic = self.downloadFileParametersDic[op.sourceURL];
                [dic removeObjectForKey:SYDownloadCreateOperation];

                SYDownloadModel *model = [self findDownloadModelWithSourceURL:op.sourceURL];
                model.state = SYSourceDownloadCancel;
                [model update];

                Block_DownloadStateChanged state = [self get_parameterByURL:op.sourceURL type:SYDownloadParameterTypeStateChange];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (state) {
                        state(model.state);
                    }

                    if (self.downloadingQueue.count == 0) {
                        if (completion) {
                            completion();
                        }
                    }
                });
            }];
        }
    }
}


// 根据资源url字符串取消对应下载操作 -- 只要暂停了任务, 任务就会取消不会挂起 再次启动任务只能重新添加
- (void)cancelOperationByDownloadURL:(NSString *)url completion:(void(^)())completion
{
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_barrier_async(weakSelf.barrierQueue, ^{
    
        NSArray *copyDownloadingQueue = [NSArray arrayWithArray:weakSelf.downloadingQueue];
        for (SYDownloadOperation *op in copyDownloadingQueue) {
            
            __weak SYDownloadOperation *weakOp = op;
            if ([weakOp.sourceURL isEqualToString:url]) {
        
                [weakOp cancelTaskCompletionHandle:^{

                    [weakSelf.downloadingQueue removeObject:weakOp];
                    
                    NSMutableDictionary *dic = weakSelf.downloadFileParametersDic[url];
                    [dic removeObjectForKey:SYDownloadCreateOperation];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion();
                            NSLog(@"完成block");
                        }
                        
                    });
                }];

                break;
            }
        }
        
        for (SYDownloadOperation *op in weakSelf.waitingQueue) {
            if ([op.sourceURL isEqualToString:url]) {
                
                [weakSelf.waitingQueue removeObject:op];

                SYDownloadModel *model = [self findDownloadModelWithSourceURL:url];
                [model setState:SYSourceDownloadCancel];

                [model update];

                NSMutableDictionary *dic = weakSelf.downloadFileParametersDic[url];
                [dic removeObjectForKey:SYDownloadCreateOperation];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });

                break;
            }
        }
        
        [self.cancelQueue addObject:url];
    });
    

}


// 通过下载记录模型删除指定资源文件
- (void)deleteSourceFileBySourceURL:(NSString *)url completion:(void (^)(BOOL isSuccess))completion
{
    if (url == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(NO);
        });
        
        return;
    }
    
    SYDownloadModel *model = [self findDownloadModelWithSourceURL:url];
    
    if (model.state == SYSourceDownloadNone) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(NO);
        });

        [self.downloadRecordArray removeObject:model];
        NSLog(@"想要删除的资源不在下载记录中");
        
        return;
    }
    
    switch (model.state) {
        case SYSourceDownloading:
        {
         
            [self cancelOperationByDownloadURL:model.Path_SourceDownload completion:^{
         
                [self deleteFileAndRecordWithDownloadModel:model completion:^(NSError *error) {
                    
                    if (error) {
                        completion(NO);
                    }else {
                        completion(YES);
                        
                        [self.cancelQueue removeObject:model.Path_SourceDownload];
                    }
                }];
            }];
        }
            break;
            
        case SYSourceDownloadCancel:
        {
            [self deleteFileAndRecordWithDownloadModel:model completion:^(NSError *error) {
                if (error) {
                    completion(NO);
                }else {
                    completion(YES);
                    
                    [self.cancelQueue removeObject:model.Path_SourceDownload];
                }
            }];
        }
            break;
            
        case SYSourceDownloadFailed:
        {
            [self deleteFileAndRecordWithDownloadModel:model completion:^(NSError *error) {
                if (error) {
                    completion(NO);
                }else {
                    completion(YES);
                    [self.failedQueue removeObject:model.Path_SourceDownload];
                }
            }];
        }
            break;
            
        case SYSourceDownloadLinksExpired:
        {
            [self deleteFileAndRecordWithDownloadModel:model completion:^(NSError *error) {
                if (error) {
                    completion(NO);
                }else {
                    completion(YES);
                    [self.failedQueue removeObject:model.Path_SourceDownload];
                }
            }];
        }
            break;
            
        case SYSourceDownloadWaiting:
        {
            [self deleteFileAndRecordWithDownloadModel:model completion:^(NSError *error) {
                if (error) {
                    completion(NO);
                }else {
                    completion(YES);
                    
                    SYDownloadOperation *op = [self valueFromWaitingQueueForKey:model.Path_SourceDownload];
                    if (op != nil) {
                        [self.waitingQueue removeObject:op];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{//用GCD的方式，保证在主线程上更新UI
                            completion(YES);
                        });
                    }
                }
            }];
        }
            break;
            
        case SYSourceDownloadCompleted:
        {
            [self deleteFileAndRecordWithDownloadModel:model completion:^(NSError *error) {
                if (error) {
                    completion(NO);
                }else {
                    completion(YES);
                }
            }];
        }
            break;
            
        default:
            break;
    }
    
//    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1/*延迟执行时间*/ * NSEC_PER_SEC));
//    
//    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//        
    [SYDownloadModel deleteObjectsByCriteria:[NSString stringWithFormat:@"where Path_SourceDownload='%@';", url]];
//    });

}

// 删除下载的文件以及相应记录
- (void)deleteFileAndRecordWithDownloadModel:(SYDownloadModel *)model completion:(void (^)(NSError *error))completion
{
    @synchronized (self) {
        
        [[SYFileManager defaultManager] clearCache:model.realtimeFullPath completion:^(NSError *error) {
            if (error) {
                NSLog(@"删除文件错误原因: %@", error.localizedDescription);
            }else {
                
                [self.downloadFileParametersDic removeObjectForKey: model.Path_SourceDownload];
//                NSMutableArray *models = self.downloadRecordArray;
                [self.downloadRecordArray removeObject:model];
            }
            
            completion(error);
        }];
    }
}

// 全部开始下载
- (void)allStartDownload
{
    NSMutableArray *newTask = [NSMutableArray array];
    [newTask addObjectsFromArray:self.cancelQueue];
    [newTask addObjectsFromArray:self.failedQueue];
    [self.cancelQueue removeAllObjects];
    [self.failedQueue removeAllObjects];

    for (NSString *url in newTask) {
        
        @synchronized (self) {
            
            [self resetCancelOrFailedOperationWithSourceURL:url];
        }
    }
}



#pragma mark <-----------  操作方法附带调用方法----------->

/**
 *  等待队列里的操作开始下载
 */
- (void)waitingOperationBeginDownloading
{
    if ((self.downloadingQueue.count < MaxOperationCount) && self.waitingQueue.count) {
        SYDownloadOperation *op = self.waitingQueue.firstObject;
        [self.downloadingQueue addObject:op];
        [self.waitingQueue removeObject:op];
        [self.downloadQueue addOperation:op];
    }
}


/// 改变下载队列情况
- (void)changeDownloadQueueWithURL:(NSString *)url
{
    
    SYDownloadModel *model = [self findDownloadModelWithSourceURL:url];
    
    if (model.state == SYSourceDownloadCompleted) {

        for (SYDownloadOperation *op in self.downloadingQueue) {
            if ([model.Path_SourceDownload isEqualToString:op.sourceURL]) {
                
                [self.downloadingQueue removeObject:op];
                break;
            }
        }

        [self waitingOperationBeginDownloading];
        
    }else if (model.state == SYSourceDownloadCancel) {
        for (SYDownloadOperation *op in self.downloadingQueue) {
            if ([model.Path_SourceDownload isEqualToString:op.sourceURL]) {
                [self.downloadingQueue removeObject:op];
                break;
            }
        }
        
        [self waitingOperationBeginDownloading];
        
    }else if (model.state == SYSourceDownloadFailed) {
        
        for (SYDownloadOperation *op in self.downloadingQueue) {
            if ([model.Path_SourceDownload isEqualToString:op.sourceURL]) {
                [self.downloadingQueue removeObject:op];
                
                break;
            }
        }
        
        [self waitingOperationBeginDownloading];
    }
}



#pragma mark =======私有方法=======
// 根据会话对象获得操作对象
- (SYDownloadOperation *)get_OperationWithDataTask:(NSURLSessionTask *)task
{
    SYDownloadOperation *result = nil;
    for (SYDownloadOperation *oper in self.downloadQueue.operations) {
        if (oper.dataTask.taskIdentifier == task.taskIdentifier) {
            result = oper;break;
        }
    }
    return result;
}

#pragma mark =======NSURLSessionDataDelegate代理方法=======
/** 1. 接收到服务器的响应
 * 收到了Response，这个Response包括了HTTP的header（数据长度，类型等信息），这里可以决定DataTask以何种方式继续（继续，取消，转变为Download）
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    SYDownloadOperation *oper = [self get_OperationWithDataTask:dataTask];
    
    [oper URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

//// 2. DataTask已经转变成DownloadTask
//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
//{
//    SYLog(@"DataTask已经转变成DownloadTask");
//}

// 3. 接收到服务器返回的数据会调用多次 -- 每收到一次Data时候调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
 
    SYDownloadOperation *oper = [self get_OperationWithDataTask:dataTask];
 
    [oper URLSession:session dataTask:dataTask didReceiveData:data];
}

// 4. 是否把Response存储到Cache中
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler{

    SYDownloadOperation *oper = [self get_OperationWithDataTask:dataTask];

    [oper URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
}


#pragma mark =====NSURLSessionTaskDelegate代理方法======
// 5. 请求完成调用 -- 请求错误也调用
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    SYDownloadOperation *oper = [self get_OperationWithDataTask:task];
    [oper URLSession:session task:task didCompleteWithError:error];
}



#pragma mark ======dealloc销毁方法======
- (void)dealloc
{
    // 1. 释放会话 -- 随便一个就可以
    [self.session invalidateAndCancel];
    self.session = nil;
    
    
    // 2. 让操作队列取消所有任务
    [self.downloadQueue cancelAllOperations];
    
    NSLog(@"%@", @"SYDownloadManager类已销毁");
}


#pragma mark -  NSNotification
// 应用将要终止
- (void)applicationWillTerminate:(NSNotification *)not {
//    [self setAllStateToNone];
//    [self saveAllDownloadReceipts];
}

// 应用已经接收到内存警告
- (void)applicationDidReceiveMemoryWarning:(NSNotification *)not {
//    [self saveAllDownloadReceipts];
}

// 应用将要辞去活跃
- (void)applicationWillResignActive:(NSNotification *)not {
//    [self saveAllDownloadReceipts];
    /// 捕获到失去激活状态后
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
    if (hasApplication) {
        __weak __typeof__ (self) wself = self;
        UIApplication * app = [UIApplicationClass performSelector:@selector(sharedApplication)];
        self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
            __strong __typeof (wself) sself = wself;
            
            if (sself) {
//                [sself setAllStateToNone];
//                [sself saveAllDownloadReceipts];
                
                [app endBackgroundTask:sself.backgroundTaskId];
                sself.backgroundTaskId = UIBackgroundTaskInvalid;
            }
        }];
    }
}

// 应用已经开始活跃
- (void)applicationDidBecomeActive:(NSNotification *)not {
    
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
}


#pragma mark <-----------  Get / Set  ----------->

// 下载记录数组的懒加载
- (NSMutableArray *)downloadRecordArray
{
    if (!_downloadRecordArray) {
        NSArray *array = [SYDownloadModel findAll];
        
        _downloadRecordArray = array ? array.mutableCopy : [NSMutableArray array];
    }
    
    return _downloadRecordArray;
}

- (NSMutableDictionary *)downloadFileParametersDic
{
    if (!_downloadFileParametersDic) {
        _downloadFileParametersDic = [NSMutableDictionary dictionary];
    }
    
    return _downloadFileParametersDic;
}

#pragma mark <-----------  根据url获得保存的文件夹名 / 进度block / 状态改变block----------->
- (id)get_parameterByURL:(NSString *)url type:(SYDownloadParameterType)type
{
    // 1. 从字典中找到对应key的value
    NSDictionary *dic = self.downloadFileParametersDic[url];
    
    if (dic == nil) return nil;
    
    // 2. 返回对应参数
    switch (type) {
        case SYDownloadParameterTypeFolderPath:
            return dic[SYDownloadParameterFolderPath];
            
        case SYDownloadParameterTypeProgress:
            return dic[SYDownloadParameterProgress];
            
        case SYDownloadParameterTypeStateChange:
            return dic[SYDownloadParameterState];
            
        case SYDownloadParameterTypeSpeed:
            return dic[SYDownloadParameterSpeed];

        case SYDownloadParameterTypeOperation:
            return dic[SYDownloadCreateOperation];
            
        default:
            break;
    }
}


/// 下载状态改变回调
- (void)downloadStateChangedWithDownloadModel:(SYDownloadModel *)model
{
    Block_DownloadStateChanged change = [self get_parameterByURL:model.Path_SourceDownload type:SYDownloadParameterTypeStateChange];
    dispatch_async(dispatch_get_main_queue(), ^{//用GCD的方式，保证在主线程上更新UI
        // 调用下载状态改变为下载中block
        if (change) {
            change(model.state);
        }
    });
}

#pragma mark <-----------  各队列根据url获得对应操作或地址  ----------->
- (SYDownloadOperation *)valueFromWaitingQueueForKey:(NSString *)url
{
    for (SYDownloadOperation *op in self.waitingQueue) {
        if ([op.sourceURL isEqualToString:url]) {
            return op;
        }
    }
    
    return nil;
}

- (SYDownloadOperation *)valueFromDownloadingQueueForKey:(NSString *)url
{
    for (SYDownloadOperation *op in self.downloadingQueue) {
        if ([op.sourceURL isEqualToString:url]) {
            return op;
        }
    }
    
    return nil;
}

@end



//
//  SYDownloadOperation.m
//  AFNTest
//
//  Created by 谷胜亚 on 2017/5/15.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

#import "SYDownloadOperation.h"
#import "SYDownloadManager.h"
#import "SYFileManager.h"
#import <UIKit/UIKit.h>
#import "SYDownloadModel.h"

/// 操作的状态
typedef NS_ENUM(NSUInteger, SYOperationState) {
    /// 暂停状态
    SYOperationPaused,
    /// 准备下载状态
    SYOperationReady,
    /// 执行中状态
    SYOperationExecuting,
    /// 完成状态
    SYOperationFinished,
};

@interface SYDownloadOperation ()
{
    NSURLRequest *_request; // 下载请求对象
    NSURLSession *_session; // 会话对象
    
    int64_t _lastSecondSize; // 上一秒文件的大小
}

/// 操作状态
@property (readwrite, nonatomic, assign) SYOperationState state;

/// 锁
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

/// 下载记录对象
@property (nonatomic, strong) SYDownloadModel *model; // 下载记录对象

/// 数据任务对象
@property (nonatomic, strong) NSURLSessionTask *dataTask; // 数据任务

/// 输出流对象
@property (nonatomic, strong) NSOutputStream *outputStream; // 输出流

/// 下载进度回调block
@property (nonatomic, copy) Block_DownloadProgress progressBlock;

/// 下载状态改变回调block
@property (nonatomic, copy) Block_DownloadStateChanged stateBlock;

/// 下载速度回调block
@property (nonatomic, copy) Block_DownloadSpeed speedBlock;

/// 资源所属文件夹的相对路径
@property (nonatomic, copy) NSString *relativeFolderPath;

/// 下载速度定时器
@property (nonatomic, strong) NSTimer *speedTimer;

@end
@implementation SYDownloadOperation

#pragma mark ====实例化方法====
// 初始化操作对象
- (instancetype)initWithRequest:(NSURLRequest *)request inSession:(NSURLSession *)session saveTo:(NSString *)folderPath
{
    self = [super init];
    if (self) {
        self.relativeFolderPath = folderPath;
        self.model = [SYDownloadModel findFirstByCriteria:[NSString stringWithFormat:@"where Path_SourceDownload='%@';",request.URL.absoluteString]];
        
        _sourceURL = request.URL.absoluteString;

        _request = request;

        _session = session;

        _state = SYOperationReady;

        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = @"gushengya";
    }
    
    return self;
}





/**
 与重写 main 方法不同的是，如果我们重写了 start 方法或者对 NSOperation 类做了大量定制的话，我们需要保证自定义的 operation 在这些 key paths 上仍然支持 KVO 通知。比如，当我们重写了 start 方法时，我们需要特别关注的是 isExecuting 和 isFinished 这两个 key paths ，因为这两个 key paths 最可能受重写 start 方法的影响
 */
//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        _executing = NO;
//        _finished = NO;
//    }
//    
//    return self;
//}


#pragma mark <-----------  操作方法 开始 / 取消  ----------->

//- (BOOL)startWithOperation:(SYDownloadOperation *)op
//{
//    BOOL ranIt = NO;
//    if ([op isReady] && ![op isCancelled])
//    {
//        if (![op isConcurrent])
//            [op start];
//        else
//            [NSThread detachNewThreadSelector:@selector(start)
//                                     toTarget:op withObject:nil];
//        ranIt = YES;
//        
//    }
//    else if ([op isCancelled])
//    {
//        // If it was canceled before it was started,
//        //  move the operation to the finished state.
//        [self willChangeValueForKey:@"isFinished"];
//        [self willChangeValueForKey:@"isExecuting"];
////        _executing = NO;
////        _finished = YES;
//        [self didChangeValueForKey:@"isExecuting"];
//        [self didChangeValueForKey:@"isFinished"];
//        // Set ranIt to YES to prevent the operation from
//        // being passed to this method again in the future.
//        ranIt = YES;
//    }
//    return ranIt;
//}

/**
 必须的，所有并发执行的 operation 都必须要重写这个方法，替换掉 NSOperation 类中的默认实现。start 方法是一个 operation 的起点，我们可以在这里配置任务执行的线程或者一些其它的执行环境。另外，需要特别注意的是，在我们重写的 start 方法中一定不要调用父类的实现；
 */
- (void)start
{
    @synchronized (self) {

        if (self.isCancelled) {

            self.state = SYOperationFinished;
            return;
        }

        self.dataTask = [_session dataTaskWithRequest:_request];

        self.state = SYOperationExecuting;
    }

    [self.dataTask resume];
    
    [self.model setState:self.dataTask ? SYSourceDownloading : SYSourceDownloadFailed];
    [self.model update];
    [self downloadStateChanged];
}

// 手动取消任务
- (void)cancelTaskCompletionHandle:(Block_CompletionHandle)completion
{
    self.completionHandle = completion;

    [self.model setState:SYSourceDownloadCancel];
    
    [self.model update];

    [self downloadStateChanged];
    
    [self cancel];

    self.state = SYOperationFinished;
}



// 系统取消任务方法 -- 1. 手动取消会调用  2. 下载失败会调用  3. 下载完成会调用
- (void)cancel
{
    @synchronized (self) {
        
        if (self.isCancelled) return;
        
        [super cancel];
        
        if (self.dataTask) {
            [self.dataTask cancel];
        }

        self.dataTask = nil;

        [self.speedTimer invalidate];
        self.speedTimer = nil;

        dispatch_async(dispatch_get_main_queue(), ^{//用GCD的方式，保证在主线程上更新UI
            if (_speedBlock) {
                _speedBlock(0);
            }
        });
    }
}


/**
 可选的，通常这个方法就是专门用来实现与该 operation 相关联的任务的。尽管我们可以直接在 start 方法中执行我们的任务，但是用 main 方法来实现我们的任务可以使设置代码和任务代码得到分离，从而使 operation 的结构更清晰
 */
//- (void)main
//{
//}



#pragma mark =======返回值为YES表示允许并发=======
/**
 必须的，这个方法的返回值用来标识一个 operation 是否是并发的 operation ，我们需要重写这个方法并返回 YES
 */
- (BOOL)isConcurrent
{
    return YES;
}


#pragma mark ======Get / Set方法======
/**
 isExecuting 和 isFinished ：必须的，并发执行的 operation 需要负责配置它们的执行环境，并且向外界客户报告执行环境的状态。因此，一个并发执行的 operation 必须要维护一些状态信息，用来记录它的任务是否正在执行，是否已经完成执行等。此外，当这两个方法所代表的值发生变化时，我们需要生成相应的 KVO 通知，以便外界能够观察到这些状态的变化
 */
//- (void)setExecuting:(BOOL)executing
//{
//    [self willChangeValueForKey:@"isExecuting"];
//    _executing = executing;
//    [self willChangeValueForKey:@"isExecuting"];
//}
//
//- (void)setFinished:(BOOL)finished
//{
//    [self willChangeValueForKey:@"isFinished"];
//    _finished = finished;
//    [self willChangeValueForKey:@"isFinished"];
//}









- (BOOL)isReady {
    return self.state == SYOperationReady && [super isReady];
}

- (BOOL)isExecuting {
    return self.state == SYOperationExecuting;
}

- (BOOL)isFinished {
    return self.state == SYOperationFinished;
}

- (void)setState:(SYOperationState)state {

    // 如果状态改变是无效的就直接返回
    if (![self stateTransitionIsValidFrom:self.state To:state isCanceled:[self isCancelled]]) {
        return;
    }

    
    @synchronized (self) {

        NSString *oldStateKey = [self systemVariableNameByOperationState:self.state];
        NSString *newStateKey = [self systemVariableNameByOperationState:state];
        
        [self willChangeValueForKey:newStateKey];
        [self willChangeValueForKey:oldStateKey];
        _state = state;
        [self didChangeValueForKey:oldStateKey];
        [self didChangeValueForKey:newStateKey];
    }
}

#pragma mark =======NSURLSessionDataDelegate代理方法=======
/** 1. 接收到服务器的响应
 * 收到了Response，这个Response包括了HTTP的header（数据长度，类型等信息），这里可以决定DataTask以何种方式继续（继续，取消，转变为Download）
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // ’304 没有修改‘ 是一个异常 -- ('304 Not Modified' is an exceptional one)
    // 如果response没有实现statusCode属性或方法  或者  (NSHTTPURLResponse *)response的statusCode状态码小于400并且不等于304 -- 表示成功
    if (![response respondsToSelector:@selector(statusCode)] || (((NSHTTPURLResponse *)response).statusCode < 400 && ((NSHTTPURLResponse *)response).statusCode != 304)) {
        
        
        // 1. 获得求取文件的总长度
        int64_t expected = response.expectedContentLength;

        self.model.Bytes_Total = self.model.Bytes_TotalWritten + expected;

        [self.model update];
        
        
        if (expected != -1) {
            
            // 2. 拼接保存到该目录下的下载文件的全路径
            NSString *fileFullPath = [[NSString stringWithFormat:@"%@%@", [SYFileManager relativeBasePath], self.relativeFolderPath] stringByAppendingPathComponent:self.model.Name_File];
            self.model.Path_FileRelative = [self.relativeFolderPath stringByAppendingPathComponent:self.model.Name_File];
            [self.model update];
            
            // 3. 创建输出流 -- 意味着下载下来的文件拼接到该路径的文件后
            self.outputStream = [[NSOutputStream alloc] initToFileAtPath:fileFullPath append:YES];
            
            // 4. 打开输出流
            [self.outputStream open];
            dispatch_async(dispatch_get_main_queue(), ^{//用GCD的方式，保证在主线程上更新UI
                // 5. 打开计时器
                self.speedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(speedTimerAction) userInfo:nil repeats:YES];
                
                [[NSRunLoop currentRunLoop] addTimer:self.speedTimer forMode:UITrackingRunLoopMode];
            });

            _lastSecondSize = self.model.Bytes_TotalWritten;
            
        }else {
            completionHandler(NSURLSessionResponseCancel);//如果Response里不包括数据长度的信息，就取消数据传输
            [self.model setState:SYSourceDownloadFailed];
            [self.model update];

            // 回调状态
            [self downloadStateChanged];
        }

        // 5. 是否接收服务器的响应
        /*
         NSURLSession在接收到响应的时候要先对响应做允许处理:completionHandler(NSURLSessionResponseAllow);,才会继续接收服务器返回的数据,进入后面的代理方法.值得一提的是,如果在接收响应的时候需要对返回的参数进行处理(如获取响应头信息等),那么这些处理应该放在前面允许操作的前面.
         */
        if (completionHandler) {
            completionHandler(NSURLSessionResponseAllow);
        }
    }
    else if (![response respondsToSelector:@selector(statusCode)] || (((NSHTTPURLResponse *)response).statusCode == 416))
    {
        // response没有实现statusCode属性或方法  或者  (NSHTTPURLResponse *)response的statusCode状态码是416 表示 该资源已经被下载完了

        // 2. 改变下载状态为完成 并 归档下载记录文件  并  调用下载状态改变block
        [self.model setState:SYSourceDownloadCompleted];
        [self.model update];
        
        // 回调
        [self downloadStateChanged];
        
        // 5. 是否接收服务器的响应
        /*
         NSURLSession在接收到响应的时候要先对响应做允许处理:completionHandler(NSURLSessionResponseAllow);,才会继续接收服务器返回的数据,进入后面的代理方法.值得一提的是,如果在接收响应的时候需要对返回的参数进行处理(如获取响应头信息等),那么这些处理应该放在前面允许操作的前面.
         */
        if (completionHandler) {
            completionHandler(NSURLSessionResponseCancel);
        }
    }else if ([(NSHTTPURLResponse *)response statusCode] == 404) { // 请求的资源不存在或链接失效
        
//        [self.model setState:SYSourceDownloadLinksExpired];
        [self.model deleteObject];
//        [self.model update];
        
//        [self downloadStateChanged];
        if (completionHandler) {
            completionHandler(NSURLSessionResponseCancel);
        }
        
    }else
    {
        // 1. 发送下载停止(取消)通知
        // 2. 调用下载完成回调block
        [self.model setState:SYSourceDownloadCancel];
        [self.model update];
        
        [self downloadStateChanged];
        
        // 5. 是否接收服务器的响应
        /*
         NSURLSession在接收到响应的时候要先对响应做允许处理:completionHandler(NSURLSessionResponseAllow);,才会继续接收服务器返回的数据,进入后面的代理方法.值得一提的是,如果在接收响应的时候需要对返回的参数进行处理(如获取响应头信息等),那么这些处理应该放在前面允许操作的前面.
         */
        if (completionHandler) {
            completionHandler(NSURLSessionResponseAllow);
        }
    }
}

//// 2. DataTask已经转变成DownloadTask
//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
//{
//    SYLog(@"DataTask已经转变成DownloadTask");
//}

// 3. 接收到服务器返回的数据会调用多次 -- 每收到一次Data时候调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{

    [self.outputStream write:data.bytes maxLength:data.length];

    self.model.Bytes_TotalWritten += data.length;
    [self.model update];

    dispatch_async(dispatch_get_main_queue(), ^{//用GCD的方式，保证在主线程上更新UI
        if (self.progressBlock) {
            self.progressBlock(self.model.Bytes_TotalWritten, self.model.Bytes_Total);
        }
    });
}

// 4. 是否把Response存储到Cache中
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler{

    NSCachedURLResponse *cachedResponse = proposedResponse;
    
    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}


#pragma mark =====NSURLSessionTaskDelegate代理方法======
// 5. 请求完成调用 -- 请求错误也调用
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
#warning 如果没网的情况下调用回调函数可能在处理的地方出现崩溃
    [self didCompleteWithError:error];

    @synchronized (self) {
        
        self.dataTask = nil;

        self.state = SYOperationFinished;
        
        [self cancel];
    }
    [self.outputStream close];

    self.outputStream = nil;
}


- (void)didCompleteWithError:(NSError *)error
{
    if (error) {
        [self.model setState:SYSourceDownloadFailed];
        [self.model update];
        
        [self downloadStateChanged];

    }else {
        [self.model setState:SYSourceDownloadCompleted];
        [self.model update];
        
        [self downloadStateChanged];
    }
}

#pragma mark <-----------  设置进度回调block和下载状态改变回调block  ----------->
// 设置回调block -- 下载进度和下载完成状态
- (void)settingCallbackBlockOfProgress:(Block_DownloadProgress)progressBlock downloadState:(Block_DownloadStateChanged)downloadStateBlock SecondDownloadSize:(Block_DownloadSpeed)size
{
    _progressBlock = progressBlock;
    _stateBlock = downloadStateBlock;
    _speedBlock = size;
}


#pragma mark <-----------  下载状态改变回调block  ----------->
/// 下载状态改变回调
- (void)downloadStateChanged
{
    dispatch_async(dispatch_get_main_queue(), ^{//用GCD的方式，保证在主线程上更新UI
        // 调用下载状态改变为下载中block
        if (self.stateBlock) {
            self.stateBlock(self.model.state);
        }
    });
}




#pragma mark <-----------  定时器执行事件  ----------->
- (void)speedTimerAction
{
    int64_t currentSecondSize = self.model.Bytes_TotalWritten;

    int64_t size = currentSecondSize - _lastSecondSize;

    dispatch_async(dispatch_get_main_queue(), ^{//用GCD的方式，保证在主线程上更新UI
        if (_speedBlock) {
            _speedBlock(size);
        }
    });
    
    _lastSecondSize = self.model.Bytes_TotalWritten;
}



#pragma mark <-----------  改变操作状态所需的方法  ----------->
/// 获得对应操作状态的系统变量名
- (NSString *)systemVariableNameByOperationState:(SYOperationState)state
{
    switch (state) {
        case SYOperationReady:
            return @"isReady";
            break;
            
        case SYOperationExecuting:
            return @"isExecuting";
            break;
            
        case SYOperationFinished:
            return @"isFinished";
            break;
            
        case SYOperationPaused:
            return @"isPaused";
            break;
            
        default:
            break;
    }
}

/// 判断状态过渡是否有效
- (BOOL)stateTransitionIsValidFrom:(SYOperationState)from To:(SYOperationState)to isCanceled:(BOOL)isCanceled
{
    switch (from) {
        case SYOperationReady:
        {
            switch (to) {
                case SYOperationPaused:
                case SYOperationExecuting:
                    return YES;
                    
                case SYOperationFinished:
                    return isCanceled;
                    
                default:
                    return NO;
            }
        }
         
        case SYOperationExecuting:
        {
            switch (to) {
                case SYOperationPaused:
                case SYOperationFinished:
                    return YES;

                default:
                    return NO;
            }
        }
            
        case SYOperationFinished:
        {
            return NO;
        }
            
        case SYOperationPaused:
        {
            return to == SYOperationReady;
        }
            
        default:
            break;
    }
}

#pragma mark ====该类销毁=====
- (void)dealloc
{
    
    NSLog(@"SYDownloadOperation类销毁了");
}

@end

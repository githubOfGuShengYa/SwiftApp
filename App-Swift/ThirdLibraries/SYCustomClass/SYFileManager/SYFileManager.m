//
//  SYFileManager.m
//  AFNTest
//
//  Created by 谷胜亚 on 2017/5/8.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

#import "SYFileManager.h"



typedef NS_ENUM(NSUInteger, SYDirectoryType) {
    SYDirectoryTypeDocument,  // Documents，苹果建议将程序中创建的或在程序中浏览到的文件数据保存在该目录下，iTunes备份和恢复的时候会包括此目录；
    SYDirectoryTypeCaches, // Library/Caches：存放缓存文件，iTunes不会备份此目录，此目录下文件不会在应用退出删除
    SYDirectoryTypeLibrary // Library，存储程序的默认设置或其它状态信息
};

@implementation SYFileManager
/**单例*/
+ (instancetype)defaultManager
{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}


#pragma mark ========计算指定文件/文件夹的大小========
/// 计算指定路径文件的大小
+ (long long)fileSizeAtPath:(NSString *)path
{
    // 1. 获得文件管理者单利对象
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 2. 判断该路径下是否存在文件
    if ([fileManager fileExistsAtPath:path]) {
        long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
        
        return size;
    }
    
    return 0;
}

/**
 * 计算指定路径文件夹的大小
 */
+ (long long)folderSizeAtPath:(NSString *)path
{
    // 1. 获得文件管理者单例对象
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 2. 创建总长度
    long long totalSize = 0.0;
    
    // 3. 判断该路径下是否有文件存在
    if ([fileManager fileExistsAtPath:path]) {
        // 4. 创建一个数组来接收该文件夹下的文件
        NSArray *subFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in subFiles) {
            NSString *subPath = [path stringByAppendingPathComponent:fileName];
            totalSize += [SYFileManager fileSizeAtPath:subPath];
        }
        
        return totalSize;
    }
    
    return 0;
}

#pragma mark ========清除指定文件/文件夹的内容==========
/**
 *  清理单个目录的文件
 *
 *  @param path 单个路径
 */
- (void)clearCache:(NSString *)path completion:(void (^)(NSError *error))completion
{
    // 1. 获得文件管理者单例对象
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //    // 2. 判断该路径下是否存在文件
    //    if ([fileManager fileExistsAtPath:path]) {
    //        // 3. 获得该路径下所有的文件数组
    //        NSArray *subFiles = [fileManager subpathsAtPath:path];
    //        for (NSString *fileName in subFiles) {
    //            // 4. 拼接字符串得到该目录下完整的路径名
    //            NSString *subPath = [path stringByAppendingPathComponent:fileName];
    //
    //            // 5. 调用删除方法删除该路径文件
    //            NSError *error;
    //            [fileManager removeItemAtPath:subPath error:&error];
    //
    //            completion(error);
    //        }
    //    }
    
    BOOL isPath = YES; // 是路径
    if ([fileManager fileExistsAtPath:path isDirectory:&isPath]) {
        // 5. 调用删除方法删除该路径文件
        NSError *error;
        [fileManager removeItemAtPath:path error:&error];
        
        completion(error);
    }
}




/**
 *  移动某个文件或文件夹到另一位置
 *
 *  @param atPath 移动前的路径
 *
 *  @param toPath 移动后的路径
 */
- (void)moveFileAtPath:(NSString *)atPath ToPath:(NSString *)toPath success:(void(^)(NSString *newPath))success failed:(void(^)())failed
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        NSError *error;
        [fileManager moveItemAtPath:atPath toPath:toPath error:&error];
        if (error) { // 出现错误了
            dispatch_async(dispatch_get_main_queue(), ^{//用GCD的方式，保证在主线程上更新UI
                failed();
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{//用GCD的方式，保证在主线程上更新UI
                success(toPath);
            });
        }
    });
}

#pragma mark ========创建文件夹=========
/**
 *  根据自定义名称创建文件夹
 *
 *  @param path 根路径
 *
 *  @param name 文件夹名称
 *
 *  @return 该文件夹的路径
 */
+ (NSString *)createDirectoryAtPath:(NSString *)path AndName:(NSString *)name
{
    // 1. 根据传入的路径拼接字符串，即在传入的路径后面创建文件夹
    NSString *directoryPath = [NSString stringWithFormat:@"%@/%@",path,name];
    
    // 2. 判断该路径下是否已经有文件夹或文件
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        
        // 3. 如果该路径下还没有文件那么就创建文件夹 -- 第三个参数attributes表示对该文件夹的一些设置如：创建时间，是否只读等等
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }else {
        NSLog(@"已经存在该文件夹");
    }
    
    return directoryPath;
}

/**
 *  根据传入的文件夹名称创建处于Library/Caches目录下的文件夹 -- 该路径下文件不会被itunes同步
 *
 *  @param folderName 自定义的文件夹名
 *
 *  @return 完整的文件夹路径 -- 可能为空
 */
+ (NSString *)createCacheFolderWithFolderName:(NSString *)folderName
{
    return [SYFileManager createFolderWithType:SYDirectoryTypeCaches FolderName:folderName];
}


/**
 *  根据传入的文件夹名称创建处于Document目录下的文件夹 -- iTunes备份和恢复的时候会包括此目录
 *
 *  @param folderName 自定义的文件夹名
 *
 *  @return 完整的文件夹路径 -- 可能为空
 */
+ (NSString *)createDocumentFolderWithFolderName:(NSString *)folderName
{
    return [SYFileManager createFolderWithType:SYDirectoryTypeDocument FolderName:folderName];
}

/**
 *  根据传入的文件夹名称创建处于Library目录下的文件夹 -- 存储程序的默认设置或其它状态信息
 *
 *  @param folderName 自定义的文件夹名
 *
 *  @return 完整的文件夹路径 -- 可能为空
 */
+ (NSString *)createLibraryFolderWithFolderName:(NSString *)folderName
{
    return [SYFileManager createFolderWithType:SYDirectoryTypeLibrary FolderName:folderName];
}


/**
 *  根据传入的目录类型和文件夹名称创建对应文件夹路径
 *
 *  @param type 目录类型 -- SYDirectoryType枚举
 *
 *  @param folderName 自定义的文件夹名
 *
 *  @return 完整的文件夹路径 -- 可能为空
 */
+ (NSString *)createFolderWithType:(SYDirectoryType)type FolderName:(NSString *)folderName
{
    // 1. 创建文件管理者
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 2. 创建一个文件路径字符串指针 -- 如果改为static想变为Directory路径就不行了
    __block NSString *filePath;
    
    // 4. 判断该类型是什么目录
    NSSearchPathDirectory pathDirectory;
    switch (type) {
        case SYDirectoryTypeDocument:
            pathDirectory = NSDocumentDirectory;
            break;
        case SYDirectoryTypeCaches:
            pathDirectory = NSCachesDirectory;
            break;
        case SYDirectoryTypeLibrary:
            pathDirectory = NSLibraryDirectory;
            break;
        default:
            break;
    }
    // 5. 获得cache路径
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(pathDirectory, NSUserDomainMask, YES).firstObject;
    // 6. 拼接路径
    // 6.1 去除目录字符串中的空格
    folderName = [folderName stringByReplacingOccurrencesOfString:@" " withString:@""];
    // 6.2 如果此时的目录字符串不为空则拼接到cache路径后
    if (folderName && ![folderName isEqualToString:@""]) {
        filePath = [cachePath stringByAppendingPathComponent:folderName];
    }else {
        filePath = cachePath;
    }
    
    // 7. 判断是否可以成功创建该路径
    NSError *error;
    if (![fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error]) {
        // 如果不能成功创建打印错误信息并把路径置空
        NSLog(@"创建路径失败: %@", filePath);
    }
    
    return filePath;
}





#pragma mark ======创建指定文件夹文件名的文件=======
+ (NSString *)g_CreateFileWithFolderName:(NSString *)folder fileName:(NSString *)file
{
    return [[SYFileManager createCacheFolderWithFolderName:folder] stringByAppendingPathComponent:file];
}

+ (NSString *)relativeBasePath
{
    NSString *base = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSRange range = [base rangeOfString:@"/Document"];
    
    return [base substringToIndex:range.location];
}

@end

//
//  SYFileManager.h
//  AFNTest
//
//  Created by 谷胜亚 on 2017/5/8.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface SYFileManager : NSObject

/**单例*/
+ (instancetype)defaultManager;

#pragma mark ========计算指定文件/文件夹的大小========
// 计算指定路径文件的大小
+ (long long)fileSizeAtPath:(NSString *)path;

/**
 * 计算指定路径文件夹的大小
 */
+ (long long)folderSizeAtPath:(NSString *)path;

#pragma mark ========清除指定文件/文件夹的内容==========

/**
 *  清理单个目录的文件
 *
 *  @param path 单个路径
 */
- (void)clearCache:(NSString *)path completion:(void (^)(NSError *error))completion;

#pragma mark <-----------  移动文件夹 / 文件  ----------->

/**
 *  移动某个文件或文件夹到另一位置
 *
 *  @param atPath 移动前的路径
 *
 *  @param toPath 移动后的路径
 */
- (void)moveFileAtPath:(NSString *)atPath ToPath:(NSString *)toPath success:(void(^)(NSString *newPath))success failed:(void(^)())failed;


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
+ (NSString *)createDirectoryAtPath:(NSString *)path AndName:(NSString *)name;

/**
 *  根据传入的文件夹名称创建处于Library目录下的文件夹 -- 存储程序的默认设置或其它状态信息
 *
 *  @param folderName 自定义的文件夹名
 *
 *  @return 完整的文件夹路径 -- 可能为空
 */
+ (NSString *)createLibraryFolderWithFolderName:(NSString *)folderName;

/**
 *  根据传入的文件夹名称创建处于Document目录下的文件夹 -- iTunes备份和恢复的时候会包括此目录
 *
 *  @param folderName 自定义的文件夹名
 *
 *  @return 完整的文件夹路径 -- 可能为空
 */
+ (NSString *)createDocumentFolderWithFolderName:(NSString *)folderName;

/**
 *  根据传入的文件夹名称创建处于Library/Caches目录下的文件夹 -- 该路径下文件不会被itunes同步
 *
 *  @param folderName 自定义的文件夹名
 *
 *  @return 完整的文件夹路径 -- 可能为空
 */
+ (NSString *)createCacheFolderWithFolderName:(NSString *)folderName;

#pragma mark ======创建指定文件夹文件名的文件=======
+ (NSString *)g_CreateFileWithFolderName:(NSString *)folder fileName:(NSString *)file;

/// 相对路径的根路径
+ (NSString *)relativeBasePath;
@end

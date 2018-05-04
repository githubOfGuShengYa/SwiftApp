//
//  SYFileManager.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/7/26.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

import Foundation

class SYFileManager {
    
    /// 路径的类型
    ///
    /// - document: Documents, 苹果建议将程序中创建的或在程序中浏览到的文件数据保存在该目录下，iTunes备份和恢复的时候会包括此目录
    /// - caches: Library/Caches：存放缓存文件，iTunes不会备份此目录，此目录下文件不会在应用退出删除
    /// - library: Library，存储程序的默认设置或其它状态信息
    enum SYDirectoryType {
        case document
        case caches
        case library
    }
    
    
    
    /// 获取某个文件夹的路径(如果不传文件夹名,则返回基于type的根路径)
    ///
    /// - Parameters:
    ///   - type: 根路径的类型: 1. Document  2. Library/Caches  3. Library
    ///   - folderName: 被创建或获取的文件夹名(为空则返回基于type的根路径)
    /// - Returns: 返回完整路径
    private class func folderPath(type: SYDirectoryType, folderName: String?) ->String {
        
        // 初始化文件管理者
        let fileManager = FileManager.default
        
        // 创建一个最后结果路径指针
        var path: String
        
        // 创建一个寻找目录枚举指针
        var pathDirectory: FileManager.SearchPathDirectory
        
        // 判断路径的类型
        switch type {
        case .document:
            pathDirectory = .documentDirectory
        case .caches:
            pathDirectory = .cachesDirectory
        case .library:
            pathDirectory = .libraryDirectory
        }
        
        // 初始化一个该类型根路径的URL
        let directoryURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(pathDirectory, .userDomainMask, true)[0])
        
        // 去除文件名字符串中的空格后判断传入的文件夹名是否为空
        let name = folderName?.replacingOccurrences(of: " ", with: "")
        if name?.isEmpty != true {
            // 如果传入的文件夹名不为空拼接到根路径上
            path = directoryURL.appendingPathComponent(folderName!).path
            
            // 判断是否可以成功创建该路径
            do {
                // 该路径已存在或者创建成功都不会调起catch
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print("创建失败, 失败原因: \(error.localizedDescription)")
            }
        }else {
            // 为空则让结果路径指针指向已知类型的根路径
            path = directoryURL.path
        }
        
        return path
    }
    
    /// 获得document目录下的路径
    ///
    /// - Parameter folderName: 文件夹名
    /// - Returns: 当folderName为nil时返回document目录路径
    class func documentPath(folderName: String?) ->String {
        return SYFileManager.folderPath(type: .document, folderName: folderName)
    }

    /// 获得library/caches目录下的路径
    ///
    /// - Parameter folderName: 文件夹名
    /// - Returns: 当folderName为nil时返回library/caches目录路径
    class func cachesPath(folderName: String?) ->String {
        return SYFileManager.folderPath(type: .caches, folderName: folderName)
    }
    
    /// 获得library目录下的路径
    ///
    /// - Parameter folderName: 文件夹名
    /// - Returns: 当folderName为nil时返回library目录路径
    class func libraryPath(folderName: String?) ->String {
        return SYFileManager.folderPath(type: .library, folderName: folderName)
    }
    
    
    
    /// 创建目录
    ///
    /// - Parameters:
    ///   - base: 根目录
    ///   - folder: 文件夹名
    /// - Returns: 创建后的完整路径(如果创建失败, 返回nil)
    class func createDirectory(base: String, folder: String) ->String? {
        
        let url = URL(fileURLWithPath: base).appendingPathComponent(folder)
        
        do {
            // 该路径已存在或者创建成功都不会调起catch
            try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("创建失败, 失败原因: \(error.localizedDescription)")
            return nil
        }
        
        return url.path
    }
}

//
//  Array+SYExtension.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/6/27.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

import Foundation

extension Array {
    
    /// 反转数组
    var reverseValue: Array {
        
        var array = Array(self)
        
        for i in 0..<array.count / 2 {
            
            swap(&array[i], &array[count - i - 1])
        }
        
        return array
    }
    
    /// 存放纯字符串的数组的排序
    ///
    ///     let chineseNames = ["谷胜亚", "张三", "李四", "王五", "赵六", "陈七", "张伟", "李青", "王龙", "赵凯", "陈赫", "周助", "姜中", "魏湖", "冯希", "卢宵", "勾况", "重庆"]
    ///     let result = chineseNames.stringSort{$0 < $1}
    ///     print(result!)
    ///
    /// - Parameter rule: 排序函数
    /// - Returns: 返回排序后的字符串数组
    public func stringSort(rule: (String, String) ->Bool) ->[String]? {
        
        if let array = self as? [String] {
            
            // 创建一个可变字典保存数组中的值
            var dic = [String : String]()
            var sortedArray = [String]()
            var result = [String]()
            
            for item in array {
                // 转为拼音字符串
                let pinyin = item.pinyin
                
                // 保存到字典中
                dic[pinyin] = item
                
                // 保存到排序数组中
                sortedArray.append(pinyin)
            }
            
            // 对拼音数组进行排序
            let sort = sortedArray.sorted(by: rule)
            
            // 对排序完的keys遍历获得对应字典中的
            for item in sort {
                // 取出对应字典中value
                if let value = dic[item] {
                    // 添加到结果数组中
                    result.append(value)
                }
            }
            
            return result
        }
        
        return nil
    }
}



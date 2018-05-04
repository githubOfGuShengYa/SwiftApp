//
//  Nibloadable.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/8/29.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//  协议测试

import Foundation

/// 协议声明中无法附加限制性条件
protocol Nibloadable {
    
}

/// 非限制性协议
extension Nibloadable {
    
    
    /// 加载Xib, 注意: 必须存在该xib才能加载, 否则编译会崩溃在loadNibNamed方法
    ///
    /// - Returns: 返回由xib创建的对象
    static func loadFromNib() ->Self {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.first as! Self
    }
}

/// 限制性协议 -- 限制该协议只能被UIViewController及其子类实现
extension Nibloadable where Self: UIViewController {
    
}

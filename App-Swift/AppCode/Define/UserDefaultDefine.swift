//
//  UserDefaultDefine.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/8/29.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//  用户偏好设置

import Foundation




fileprivate enum SYUserDefault: String {
    /// 自动跳过片头片尾
    case headerSkip             = "headerSkip"
    /// 允许运营商网络下载
    case downloadUseWWAN        = "downloadUseWWAN"
    /// 允许非wifi网络下自动播放
    case autoPlayWithoutWIFI    = "autoPlayWithoutWIFI"
    /// 新消息通知
    case newMassageNotice       = "newMassageNotice"
    /// 搜索历史缓存
    case cacheSearchHistory     = "cacheSearchHistory"
}

/// 自动跳过片头片尾
var UserDefault_headerSkip = UserDefaults.standard.value(forKey: SYUserDefault.headerSkip.rawValue) as? Bool ?? false {
    didSet {
        UserDefaults.standard.set(UserDefault_headerSkip, forKey: SYUserDefault.headerSkip.rawValue)
    }
}

/// 允许运营商网络下载
var UserDefault_downloadUseWWAN = UserDefaults.standard.value(forKey: SYUserDefault.downloadUseWWAN.rawValue) as? Bool ?? false {
    didSet {
        UserDefaults.standard.set(UserDefault_downloadUseWWAN, forKey: SYUserDefault.downloadUseWWAN.rawValue)
    }
}

/// 允许非wifi网络下自动播放
var UserDefault_autoPlayWithoutWIFI = UserDefaults.standard.value(forKey: SYUserDefault.autoPlayWithoutWIFI.rawValue) as? Bool ?? false {
    didSet {
        UserDefaults.standard.set(UserDefault_autoPlayWithoutWIFI, forKey: SYUserDefault.autoPlayWithoutWIFI.rawValue)
    }
}

/// 新消息通知
var UserDefault_newMessageNotice = UserDefaults.standard.value(forKey: SYUserDefault.newMassageNotice.rawValue) as? Bool ?? false {
    didSet {
        UserDefaults.standard.set(UserDefault_newMessageNotice, forKey: SYUserDefault.newMassageNotice.rawValue)
    }
}

// MARK:- <-----------  搜索本地数据  ----------->
/// 搜索历史缓存
var UserDefault_cacheSearchHistory = UserDefaults.standard.value(forKey: SYUserDefault.cacheSearchHistory.rawValue) as? [String] ?? [String]() {
    didSet {
        UserDefaults.standard.set(UserDefault_cacheSearchHistory, forKey: SYUserDefault.cacheSearchHistory.rawValue)
    }
}




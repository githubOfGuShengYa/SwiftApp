//
//  AppTool.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2018/6/22.
//  Copyright © 2018年 谷胜亚. All rights reserved.
//

import Foundation

class AppTool {
    /// 当前应用跳转到App Store
    ///
    ///     AppTool.switchToAppStore(url: "http://www.baidu.com")
    ///
    /// - Parameter url: 即将跳转的链接, 不填默认首页
    public class func switchToAppStore(url: String?) ->Void {
        if let Url = URL.init(string: url ?? "itms-apps://itunes.apple.com") {
            UIApplication.shared.openURL(Url)
            return
        }
        
        UIApplication.shared.openURL(URL.init(string: "itms-apps://itunes.apple.com")!)
    }
}

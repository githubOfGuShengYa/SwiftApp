//
//  DeviceTool.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2018/6/22.
//  Copyright © 2018年 谷胜亚. All rights reserved.
//  设备方面

import UIKit

class DeviceTool {
    
    /// 防止app在前台期间手机到时间自动锁屏
    ///
    ///     DeviceTool.screenLockDisabel()
    ///
    public class func screenLockDisabel() {
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    
}

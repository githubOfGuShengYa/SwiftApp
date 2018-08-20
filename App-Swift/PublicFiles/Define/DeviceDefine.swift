//
//  DeviceDefine.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/7/25.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//  设备的一些定义

import Foundation
import UIKit

// MARK:- <-----------  设备信息  ----------->
/// 设备名称 -- 例: 谷胜亚的iPhone
let deviceName = UIDevice.current.name

/// 设备唯一标识符 -- 例: FBF2306E-A0D8-4F4B-BDED-9333B627D3E6
let deviceUUID = (UIDevice.current.identifierForVendor?.uuidString)!

/// 设备的型号 -- 例: iPhone
let deviceModel = UIDevice.current.model

/// 系统版本 -- 例: 10.3
let systemVersion = UIDevice.current.systemVersion

/// 系统名称 -- 例: iPhone OS
let systemName = UIDevice.current.systemName

/// 设备区域化型号 -- 例: A1533
let deviceLocalizedModel = UIDevice.current.localizedModel

/// 设备详细型号 -- 例: iPhone 6s
var deviceDetailedModel: String {
    get {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1":                               return "iPhone 7"
        case "iPhone9,2":                               return "iPhone 7 Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}

// MARK:- <-----------  应用信息  ----------->
/// 应用名称
let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"]

/// 程序版本号 -- 主版本号
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

/// 程序版本号 -- 内部标示
let appVersionMark = Bundle.main.infoDictionary?["CFBundleVersion"] as! String








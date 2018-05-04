//
//  GlobalDefine.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/6/26.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

import Foundation
import UIKit


// MARK: <-----------  封装打印方法  ----------->
/// 封装的日志输出方法(T表示不指定日志信息参数类型)(打印调用该方法所在的打印值、文件、方法、行数)
///
///     SYLog("谷胜亚")
///     打印的格式:
///     <文件名:ViewController.swift><方法名:viewDidLoad()><行数:32>打印内容: 谷胜亚
///
/// - Parameter message: 泛型值, 想要打印的值
/// - Parameter file: 被调用打印方法所在文件名
/// - Parameter function: 被调用打印方法所在方法名
/// - Parameter line: 被调用打印方法所在行
func SYLog(_ items: Any..., file:String = #file, function:String = #function,
           line:Int = #line) {
    #if DEBUG   // 如果在编译状态就打印, 否则不做处理
        //获取文件名
        let fileName = (file as NSString).lastPathComponent
        //打印日志内容
        let fileLog: String = String.init(format: "<文件名:%@>", fileName)
        let funcLog: String = String.init(format: "<方法名:%@>", function)
        let lineLog: String = String.init(format: "<行数:%d>", line)
        
        var itemString: String = String()
        for item: Any in items {
            itemString.append("\(item) ")
        }
        
        print("\(fileLog)\(funcLog)\(lineLog)打印内容: ", itemString)
    #endif
}

/// 应用版本号
var APP_VERSION: String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
}

/// 设备名
var DEVICE_NAME: String {
    return UIDevice.current.model
}

/// 系统版本号
var SYSTEM_VERSION: String {
    return UIDevice.current.systemVersion
}

/// 设备用户名
var DEVICE_USER_NAME: String {
    return UIDevice.current.name
}

//func getIFAddresses() -> [String] {
//    var addresses = [String]()
//    
//    // Get list of all interfaces on the local machine:
//    var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
//    if getifaddrs(&ifaddr) == 0 {
//        
//        // For each interface ...
//        for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
//            let flags = Int32(ptr.memory.ifa_flags)
//            var addr = ptr.memory.ifa_addr.memory
//            
//            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
//            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
//                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
//                    
//                    // Convert interface address to a human readable string:
//                    var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
//                    if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
//                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
//                        if let address = String.fromCString(hostname) {
//                            addresses.append(address)
//                        }
//                    }
//                }
//            }
//        }
//        freeifaddrs(ifaddr)
//    }
//    
//    return addresses
//}



struct Address {
    static func address<T: Any>(_ object: T) -> String {
        
        return String.init(format: "%018p", unsafeBitCast(object, to: object as! CVarArg.Protocol))
    }    
}


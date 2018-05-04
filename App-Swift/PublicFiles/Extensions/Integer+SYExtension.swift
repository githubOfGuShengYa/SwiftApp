//
//  Integer+SYExtension.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/8/18.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

import Foundation

enum RandomSource {
    
    static let file = fopen("/dev/urandom", "r")!
    static let queue = DispatchQueue(label: "random")
    
    static func get(count: Int) -> [Int8] {
        let capacity = count + 1 // fgets adds null termination
        var data = UnsafeMutablePointer<Int8>.allocate(capacity: capacity)
        defer {
            data.deallocate(capacity: capacity)
        }
        let _ = queue.sync {
            fgets(data, Int32(capacity), file)
        }
        return Array(UnsafeMutableBufferPointer(start: data, count: count))
    }
}

extension Integer {
    
    
    static var randomized: Self {
        let numbers = RandomSource.get(count: MemoryLayout<Self>.size)
        return numbers.withUnsafeBufferPointer { bufferPointer in
            return bufferPointer.baseAddress!.withMemoryRebound(to: Self.self, capacity: 1) {
                return $0.pointee
            }
        }
    }
    
    
    var MB:String {
        // GB
        let GB = (self as! Int) / 1000 / 1000 / 1000
        // MB
        let MB = ((self as! Int) % (1000 * 1000 * 1000)) / 1000 / 1000
        // KB
        let KB = (((self as! Int) % (1000 * 1000 * 1000)) % (1000 * 1000)) / 1000
        // B
        let B = (((self as! Int) % (1000 * 1000 * 1000)) % (1000 * 1000)) % 1000
        
        if GB != 0 {
            // 1.0GB↑
            return String(format: "%ld.%ldGB", GB, MB / 100)
        }else if MB != 0 {
            // 1.0MB~99.9MB
            if MB < 100 {
                return String(format: "%ld.%ldMB", MB, KB / 100)
            }
            // 100MB~999MB
            return String(format: "%ldMB", MB)
        }else if KB != 0 {
            // 1KB~999KB
            return String(format: "%ldKB", KB)
        }else if B != 0 {
            // 1B~999B
            return String(format: "%ldB", B)
        }
        
        return "0B"
    }

    
    
    /// 时间戳转变为固定格式字符串
    var time: String {
        
        var number = self
        
        // 当前时间
        var date = Date()
        let timezone = TimeZone(abbreviation: "GMT+0800")
        let interval = timezone?.secondsFromGMT(for: date)
        date = date.addingTimeInterval(TimeInterval(interval!))
        // 当前时间戳
        let timeInterval = date.timeIntervalSince1970
        // 判断本数字的长度
        let length = number.length
        if length > 10 {
            for _ in 0..<(length - 10) {
                number = number / 10
            }
        }else if length < 10 {
            return "非法时间戳"
        }
        
        let totalSecond = timeInterval - (number as! TimeInterval)
        
        if totalSecond < 60 * 60 {
            return String(format: "%ld分钟前", totalSecond / 60)
        }else if totalSecond < 60 * 60 * 24 {
            return String(format: "%ld小时前", totalSecond / 60 / 60)
        }else if totalSecond < 60 * 60 * 24 * 30 {
            return String(format: "%ld天前", totalSecond / 60 / 60 / 24)
        }else if totalSecond < 60 * 60 * 24 * 365 {
            return String(format: "%ld月前", totalSecond / 60 / 60 / 24 / 30)
        }else {
            return String(format: "%ld年前", totalSecond / 60 / 60 / 24 / 365)
        }
    }
    
    /// 判断该数字是多少位数
    var length: UInt {
        guard self >= 0 else {
            return 0
        }
        
        // x表示当前数值, sum表示位数, j表示每一位的值
        var x = self, sum = 0, j = 1
        while( x >= 1 ) {
            //            NSLog(@"%zd位数是 : %zd\n",j,x%10);
            x = x / 10;
            sum += 1;
            j = j * 10;
        }
        //        NSLog(@"你输入的是一个%zd位数\n",sum);
        return UInt(sum);
    }
    
    /// 映射成字符串
    var numberString: String {
        assert(self >= 0, "暂时不能转化负值")
        let number = NSNumber.init(value: self as! Int)
        return NumberFormatter.localizedString(from: number, number: .spellOut)
    }
    
    // MARK: <-----------  数学函数  ----------->
    
    /// 获得对应自身值做为度数的sin值
    var sinValue: CGFloat {
        assert(self >= 0, "暂时不能转化负值")
        
        let double = sin(Double.pi * Double(self as! Int) / 180)
        
        return CGFloat(double)
    }
    
    /// 获得对应自身值做为度数的cos值
    var cosValue: CGFloat {
        assert(self >= 0, "暂时不能转化负值")
        
        let double = cos(Double.pi * Double(self as! Int) / 180)
        
        return CGFloat(double)
    }
}


extension Double {
    
    
    
    /// 传入一个弧度值, 即π前的数值, 返回其sin值
    var sinValue: CGFloat {
        
        let double = sin(self)
        
        return CGFloat(double)
    }
    
    /// 传入一个弧度值, 即π前的数值, 返回其cos值
    var cosValue: CGFloat {
        
        let double = cos(self)
        
        return CGFloat(double)
    }
}


//
//  String+SYExtension.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/6/27.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

import Foundation



/// 正则类型
public enum SYRegularType: String {
    /// 邮箱号
    case email          = "邮箱号"
    /// 手机号
    case phoneNum       = "手机号"
    /// 联通号
    case unicomNum      = "联通号"
    
    /// 纯数字
    case pureNum        = "纯数字"
}

extension String {
    
    // MARK: <-----------  属性  ----------->
    // MARK: <-----------  字符串中中文转拼音  ----------->
    /// 字符串中的中文转为拼音不带音标
    var pinyin: String {
        let pinyin = NSMutableString(string: self) as CFMutableString
        if CFStringTransform(pinyin, nil, kCFStringTransformMandarinLatin, false) == true {
            if CFStringTransform(pinyin, nil, kCFStringTransformStripCombiningMarks, false) == true {
                return pinyin as String
            }
        }
        return self
    }
    
    /// 字符串中的中文转为拼音并带音标
    var pinyinWithSymbol: String {
        let pinyin = NSMutableString(string: self) as CFMutableString
        if CFStringTransform(pinyin, nil, kCFStringTransformMandarinLatin, false) == true {
            return pinyin as String
        }
        return self
    }
    
    
    /// 字符串中是否包含中文
    var containChinese: Bool {
        for (_, value) in self.characters.enumerated() {
            
            if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                return true
            }
        }
        
        return false
    }
    
    /// 字符串的反转
    var reverseString: String {
        
        var arr = Array(self.characters)
        
        let count:Int = arr.count
        
        for i in 0..<count / 2 {
            swap(&arr[i], &arr[count - i - 1])
        }
        
        return String(arr)
    }
    
    
    // MARK: <-----------  正则表达式方面  ----------->
    
    /// 字符串是否符合传入类型的正则规则
    ///
    ///     print("gushengya@qq.com".meetRegularRule(type: .Email))
    ///
    /// - Parameter type: SYVerifyType枚举的值
    /// - Returns: 返回Bool值
    public func isMeet(type: SYRegularType) ->Bool {
        var point: String
        switch type {
        case .email: // 邮箱号
            point = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        case .phoneNum: // 手机号
            point = "^1(3[0-9]|4[579]|5[012356789]|7[01678]|8[0-9])\\d{8}$"
        case .unicomNum: // 联通号
            point = "^1(3[0-2]|4[5]|5[56]|7[0156]|8[56])\\d{8}$"
        case .pureNum: // 纯数字 该字符串是否是纯数字 (纯数字字符串不包含 空格/符号/字母等)
            point = "^[0-9]+$"  // 或  "^\\d+$" 其中\\d 是因为转义字符\ 需要转义\d
        }
        
        // 创建正则判断对象
        let pre: NSPredicate = NSPredicate(format: "SELF MATCHES %@", point)
        
        return pre.evaluate(with: self)
    }
    
    // MARK:- <-----------  格式化  ----------->
    
    /// 字符串自身(要转变的格式字符串)通过调用该方法返回对应格式的字符串
    ///
    ///     var mulArray: [String] = []
    ///     mulArray += (0...9).map({"%02d".formatted($0)})
    ///
    /// - Parameter argument: 传入一个CVarArg协议的值 如(0..9)区间的一个值
    /// - Returns: 返回指定格式的字符串
    public func formatted( _ argument: CVarArg) -> String {
        
        return String(format: self, argument)
    }
    
    
    
    /// 对数字进行格式化
    ///
    ///     let result = "12345.6j".formatNumber(style: .currency, locale: "zh_CN")
    ///     print(result ?? "")
    ///
    /// - Parameter style: NumberFormatter.Style类型
    /// - Returns: 格式化后的字符串
    public func formatNumber(style: NumberFormatter.Style, locale: String) ->String? {
        
        let format: NumberFormatter = NumberFormatter()
        
        // 设置style和local
        format.numberStyle = style
        
        format.locale = Locale.init(identifier: locale)
        
        if let double = Double(self) {
            return format.string(from: NSNumber.init(value: double))
        }
        
        return nil
    }
    
    /// 把数字转化为人民币的样式 - ¥123.45
    /// - Returns: 人民币样式的字符串
    public func formatNumberToRMBStyle() ->String? {
        return self.formatNumber(style: .currency, locale: "zh_CN")
    }
    
    // MARK: <-----------  分割字符串获得数组  ----------->
    /// 根据关键字符串拆分字符串
    ///
    ///     print("1234567890".split(byKey: "2"))
    ///
    /// - Parameter byKey: 关键字
    /// - Returns: 除去关键字后获得的数组
    public func split(byKey: String) ->NSArray {
        
        return NSArray.init(array: self.components(separatedBy: byKey))
    }
    
    /// 根据字符集合拆分字符串
    ///
    ///     print("1234567890".split(byChars: "28"))
    ///
    /// - Parameter byChars: 字符集合
    /// - Returns: 除去字符集合中的数获得的数组
    public func split(byChars: String) ->NSArray {
        
        let chars = CharacterSet.init(charactersIn: byChars)
        
        let array = NSArray.init(array: self.components(separatedBy: chars))
        
        return array
    }
    
////     MARK: <-----------  字符串倒叙输出 -- 反转  ----------->
    
    func trim() ->String {
        // 删除前后的空格, 内部的空格没有影响
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        /** CharacterSet枚举中的值
         controlCharacters      ：控制符
         whitespaces            ：空格
         newlines               ：换行符
         whitespacesAndNewlines ：空格换行
         decimalDigits          ：小数
         letters                ：文字
         lowercaseLetters       ：小写字母
         uppercaseLetters       ：大写字母
         nonBaseCharacters      ：非基础
         alphanumerics          ：字母数字
         decomposables          ：可分解
         illegalCharacters      ：非法
         punctuationCharacters  ：标点
         capitalizedLetters     ：大写
         symbols                ：符号
         */
    }
}


// MARK:- <-----------  MD5加密  ----------->
extension String {

    /// 密码长度32
    var md5: String {
        // 1. 让字符串转化为UTF8格式字符串
        let str = self.cString(using: .utf8)
        
        // 2. 计算该UTF8字符串的字节长度
        let strLen = CC_LONG(self.lengthOfBytes(using: .utf8))
        
        // 3. 把MD5加密字符数组长度宏转变为Int类型 -- 此时是字符数组中包含16个字符空间
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        
        // 4. 创建对应长度的字符数组 -- MD5格式貌似只能是8位Int值
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        // 5. 调用MD5加密方法，参数分别是UTF8格式的被加密字符串、被加密字符串的字节长度、对应加密长度的字符数组
        CC_MD5(str!, strLen, result) // 第三个参数必须是8位Int值的字符数组
        
        // 6. 调用自定义的方法获得加密后的字符串
        return stringFromBytes(bytes: result, length: digestLen)
    }
    
    /// 密码长度40
    var sha1: String {
        // 1. 让字符串转化为UTF8格式字符串
        let str = self.cString(using: .utf8)
        
        // 2. 计算该UTF8字符串的字节长度
        let strLen = CC_LONG(self.lengthOfBytes(using: .utf8))
        
        // 3. 把MD5加密字符数组长度宏转变为Int类型 -- 此时是字符数组中包含20个字符空间
        let digestLen = Int(CC_SHA1_DIGEST_LENGTH)
        
        // 4. 创建一个字符数组包含20个字符
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        // 5. 调用SHA1方法，其中参数依次表示: 被加密的UTF8格式字符串、该UTF8字符串的长度、包含20个字符的字符数组
        CC_SHA1(str!, strLen, result)
        
        // 7. 调用把字符数组转为16进制字符的方法拼接成完整的加密字符串
        return stringFromBytes(bytes: result, length: digestLen)
    }
    
    /// 密码长度64
    var sha256String: String {
        
        // 1. 让字符串转化为UTF8格式字符串
        let str = self.cString(using: .utf8)
        
        // 2. 计算该UTF8字符串的字节长度 -- 32位UInt值
        let strLen = CC_LONG(self.lengthOfBytes(using: .utf8))
        
        // 3. 把MD5加密字符数组长度宏转变为Int类型 -- 此时表示32
        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        
        // 4. 创建一个包含32个字符的字符数组
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        // 5. 调用SHA256方法，其中参数依次表示: 被加密的UTF8格式字符串、该UTF8字符串的长度、包含32个字符的字符数组
        CC_SHA256(str!, strLen, result)
        
        // 7. 调用把字符数组转为16进制字符的方法拼接成完整的加密字符串
        return stringFromBytes(bytes: result, length: digestLen)
    }
    
    /// 密码长度128
    var sha512String: String {
        // 1. 让字符串转化为UTF8格式字符串
        let str = self.cString(using: .utf8)
        
        // 2. 计算该UTF8字符串的字节长度 -- 32位UInt值
        let strLen = CC_LONG(self.lengthOfBytes(using: .utf8))
        
        // 3. 把MD5加密字符数组长度宏转变为Int类型 -- 此时表示64
        let digestLen = Int(CC_SHA512_DIGEST_LENGTH)
        
        // 4. 创建一个包含64个字符的8位字符数组
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        // 5. 调用SHA512方法，其中参数依次表示: 被加密的UTF8格式字符串、该UTF8字符串的长度、包含64个字符的8位字符数组
        CC_SHA512(str!, strLen, result)
        
        // 7. 调用把字符数组转为16进制字符的方法拼接成完整的加密字符串
        return stringFromBytes(bytes: result, length: digestLen)
    }
    
    func stringFromBytes(bytes: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        
        // 1. 初始化一个可变字符串、初始化一个保存CUnsignedChar的数组
        let hash = NSMutableString()
        var hashValues = Array<CUnsignedChar>()
        
        // 2. for循环对应加密长度，依次取得字符数组中的值拼接到可变字符串上
        for i in 0..<length {
            hashValues.append(bytes[i])
        }
        
        // 3. 如果不做处理则直接拼接该哈希值数组
        for value in hashValues {
            hash.appendFormat("%02x", value)
            //            print(value, String.init(format: "%02x", value))
        }
        
        // 4. 释放字符数组
        bytes.deallocate(capacity: length)
        
        // 5. 返回加密后的字符串
        return String(format: hash as String)
    }
    
    func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
        
        // 1. 让字符串转化为UTF8格式字符串
        let str = self.cString(using: .utf8)
        
        // 2. 计算该UTF8字符串的字节长度
        let strLen = Int(self.lengthOfBytes(using: .utf8))
        
        // 3. 根据传入的类型获得字符数组的长度 -- 加密的字符数组的长度
        let digestLen = algorithm.digestLength
        
        // 4. 根据获得的长度初始化一个对应长度的字符数组
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        // 5. 让关键字转化为UTF8格式字符串
        let keyStr = key.cString(using: .utf8)
        
        // 6. 计算该关键字UTF8格式的字符串的长度
        let keyLen = Int(key.lengthOfBytes(using: .utf8))
        
        // 7. 参数依次表示: 1.设置HMAC算法  2.设置API秘钥  3.秘钥长度  4.被加密UTF8字符串  5.被加密字符串长度  6.返回的哈希值 -- 传入对应长度字符数组,会自动更改字符数组对应索引的值
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        
        // 8. 调用把字符数组转为16进制字符的方法拼接成完整的加密字符串
        return stringFromBytes(bytes: result, length: digestLen)
    }
}

enum CryptoAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        case .SHA224:   result = kCCHmacAlgSHA224
        case .SHA256:   result = kCCHmacAlgSHA256
        case .SHA384:   result = kCCHmacAlgSHA384
        case .SHA512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

// MARK: <-----------  时间格式  ----------->
extension String {
    
    /// 根据传入的时间戳(TimeInterval类型)格式化为YYYY-MM-dd HH:mm格式字符串
    ///
    ///     let time = Date().timeIntervalSince1970
    ///     print(String.init(timeInterval: time))
    ///
    /// - Parameter timeInterval: 时间戳
    /// - Returns: 默认格式的时间字符串
    public init(timeInterval: TimeInterval) {
        // 获得时间差
        let date = Date(timeIntervalSince1970: timeInterval)
        
        // 时间格式化对象
        let formatter = DateFormatter()
        
        // 设置默认格式化类型
        formatter.dateFormat = "YYYY-MM-dd HH:mm"
        
        // 返回格式化后的字符串
        self.init(format: "%@", formatter.string(from: date))
    }
    
    
    /// 根据传入的时间戳(字符串类型)格式化为YYYY-MM-dd HH:mm格式字符串
    ///
    ///     let time = Date().timeIntervalSince1970
    ///     print(String.init(timeInterval: "\(time)"))
    ///
    /// - Parameter timeInterval: 时间戳
    /// - Returns: 默认格式的时间字符串
    public init(timeInterval: String) {
        var result: String = "数据错误"
        if Double.init(timeInterval) != nil {
            let time: TimeInterval = TimeInterval(timeInterval)!
            result = String.init(timeInterval: time)
        }
        
        self.init(format: "%@", result)
    }
    
    /// 根据传入的时间戳(字符串类型)格式化为YYYY-MM-dd HH:mm格式字符串
    ///
    ///     let time = Date().timeIntervalSince1970
    ///     print(String.init(timeInterval: "\(time)"))
    ///
    /// - Parameter timeInterval: 时间戳
    /// - Parameter format: 输出格式
    /// - Returns: 默认格式的时间字符串
    public init(timeInterval: String, format: String) {
        var result: String = "数据错误"
        if Double.init(timeInterval) != nil {
            let time: TimeInterval = TimeInterval(timeInterval)!
            
            // 获得时间差
            let date = Date(timeIntervalSince1970: time)
            
            // 时间格式化对象
            let formatter = DateFormatter()
            
            // 设置默认格式化类型
            formatter.dateFormat = format
            
            // 返回格式化后的字符串
            result = formatter.string(from: date)
        }
        
        self.init(format: "%@", result)
    }
    
    /// 由时间戳获得年
    var year: String {
        guard let timeInterval = TimeInterval(self) else {
            print("该字符串不能转化为时间戳")
            return ""
        }
        
        let date = Date.init(timeIntervalSince1970: timeInterval)
        let format = DateFormatter()
        format.dateFormat = "yyyy"
        return format.string(from: date)
    }
    
    /// 由时间戳获得yyyy-MM-dd
    var y_M_d: String {
        guard let timeInterval = TimeInterval(self) else {
            print("该字符串不能转化为时间戳")
            return ""
        }
        
        let date = Date.init(timeIntervalSince1970: timeInterval)
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: date)
    }
}


// MARK:- <-----------  截取字符串  ----------->
extension String {
    
    /// 截取字符串截止指定索引位置, 截取后的字符串不包括索引位置的字符(索引为0时表示截取""字符, 索引为字符串长度时表示截取全部字符串)
    ///
    ///     str = str.sub(to: 3)
    ///
    /// - Parameter to: 指定索引位置(索引为从0开始)
    /// - Returns: 返回截取后的字符串
    public func sub(to: Int) ->String {
        // 判断截取到的索引是否超出范围
        assert(to <= self.characters.count && to >= 0, "截取超出范围")
        
        // 获取字符d的索引
        let index = self.index(self.startIndex, offsetBy:to)
        
        // 从起始截取到索引的所有字符串,即abc,注意不包含d
        let result = self.substring(to: index)
        
        // 返回截取后的字符串
        return result
    }
    
    
    /// 从指定索引位置开始截取字符串到末尾, 截取部分包括指定索引位置字符(当索引为0时表示截取全部, 为字符串长度时表示截取""字符串)
    ///
    ///     str = str.sub(from: 3)
    ///
    /// - Parameter from: 指定索引位置
    /// - Returns: 截取后的字符串
    public func sub(from: Int) ->String {
        // 判断截取到的索引是否超出范围
        assert(from <= self.characters.count && from >= 0, "截取超出范围")
        
        // 获取字符d的索引
        let index = self.index(self.startIndex, offsetBy: from)
        
        // 从d的索引开始截取后面所有的字符串即defghi
        let result = self.substring(from: index)
        
        // 返回截取后的字符串
        return result
    }

    
    /// 截取指定范围内的字符串
    /// 
    ///     str = str.sub(3..<8)
    ///
    /// - Parameter range: 半开区间, 截取的字符串为起始索引位置(包含)到结束索引位置(不包含)
    /// - Returns: 截取后的字符串
    public func sub(_ range: CountableRange<Int>) ->String {
        
        assert(range.lowerBound >= 0 && range.lowerBound < self.characters.count, "起始位置超出了字符串的索引")
        assert(range.lowerBound < range.upperBound, "半开区间不能最小值等于最大值")
        assert(range.upperBound <= self.characters.count, "半开区间最大值不能超过字符数")
        
        // 获取截取开始的索引
        let startIndex = self.index(self.startIndex, offsetBy:range.lowerBound)
        
        // 从d的索引开始往后两个,即获取f的索引
        let endIndex = self.index(self.startIndex, offsetBy:range.upperBound)
        
        // 输出d的索引到f索引的范围,注意..<符号表示输出不包含f
        let result = self.substring(with: startIndex..<endIndex)
        
        // 返回截取后的字符串
        return result
    }
    
    
    
    /// 替换指定半开区间的字符为指定字符串(区间包括最小位索引但不包括最大位索引)
    ///
    ///     str = str.replacing(3..<8, with: "谷胜亚")
    ///
    /// - Parameters:
    ///   - range: Int类型的区间
    ///   - with: 替换的字符串
    /// - Returns: 替换完成后新的字符串
    public func replacing(_ range: CountableRange<Int>, with: String) ->String {

        assert(range.lowerBound >= 0 && range.lowerBound < self.characters.count, "起始位置超出了字符串的索引")
        assert(range.lowerBound < range.upperBound, "半开区间不能最小值等于最大值")
        assert(range.upperBound <= self.characters.count, "半开区间最大值不能超过字符数")

        // 字符串的起始索引(包含该索引位置的字符)
        let startIndex = self.index(self.startIndex, offsetBy:range.lowerBound)

        // 字符串的结束索引
        let endIndex = self.index(self.startIndex, offsetBy:range.upperBound)

        // 替换该范围字符串为另一字符
        let result = self.replacingCharacters(in: startIndex..<endIndex, with: with)
        
        // 返回替换成功后的字符串
        return result
    }
}

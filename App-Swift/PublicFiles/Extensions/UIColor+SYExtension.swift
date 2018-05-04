//
//  UIColor+SYExtension.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/6/27.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

import Foundation
import UIKit
// 题外话: class与static的异同点, 相同的是两个修饰的func都表示类方法, 不同的是class修饰的func可以被子类重写, 而static修饰的func不能被子类重写,因为static隐式包括final关键字,表示该方法不可被重写
extension UIColor {
    
    // MARK:- <-----------  生成颜色  ----------->
    /// color为16进制色值例:0xffffff, alpha为透明度0.0~1.0
    ///
    ///     UIColor.rgbHex(0x999999, 1.0)
    ///
    /// - Parameter color: 16进制颜色值
    /// - Parameter alpha: 颜色的透明度
    /// - Returns: 返回16进制代表的颜色
    class func rgbHex(_ color: NSInteger, _ alpha: CGFloat) ->UIColor {
        let red = CGFloat((color & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((color & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(color & 0xFF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// color为16进制色值例:0xffffff, 默认透明度为1
    ///
    ///     UIColor.rgbHex(0x999999)
    ///
    /// - Parameter color: 16进制rgb色值
    /// - Returns: 16进制色值代表的颜色
    class func rgbHex(_ color: NSInteger) ->UIColor {
        
        return rgbHex(color, 1.0)
    }
    
    /// 输入指定红绿蓝三色获得对应颜色
    ///
    ///     UIColor.color(22, 33, 44)
    ///
    /// - Parameter red: 红色非负色值 范围0~255
    /// - Parameter green: 绿色非负色值 范围0~255
    /// - Parameter blue: 蓝色非负色值 范围0~255
    /// - Returns: 对应三色值的颜色
    class func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) ->UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
    }
    
    
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        // 0xff0000
        // 1.判断字符串的长度是否符合
        guard hex.characters.count >= 6 else { return nil }
        
        // 2.将字符串转成大写
        var tempHex = hex.uppercased()
        
        // 3.判断开头: 0x/#/##
        if tempHex.hasPrefix("0X") || tempHex.hasPrefix("##") {
            tempHex = (tempHex as NSString).substring(from: 2)
        } else if tempHex.hasPrefix("#") {
            tempHex = (tempHex as NSString).substring(from: 1)
        }
        
        // 4.分别取出RGB
        // FF --> 255
        guard tempHex.characters.count == 6 else { return nil }
        var range = NSRange(location: 0, length: 2)
        let rHex = (tempHex as NSString).substring(with: range)
        range.location = 2
        let gHex = (tempHex as NSString).substring(with: range)
        range.location = 4
        let bHex = (tempHex as NSString).substring(with: range)
        
        // 5.将十六进制转成数字 emoji表情
        var r: UInt32 = 0, g: UInt32 = 0, b: UInt32 = 0
        Scanner(string: rHex).scanHexInt32(&r)
        Scanner(string: gHex).scanHexInt32(&g)
        Scanner(string: bHex).scanHexInt32(&b)
        self.init(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b), alpha: alpha)
    }
    
    // 在extension中给系统的类扩充构造函数, 只能扩充 '便利构造函数'
    convenience init(r : CGFloat, g : CGFloat, b : CGFloat, alpha : CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    
    
    /**
     * 随机色
     */
    /// 随机颜色
    ///
    ///     UIColor.random()
    ///
    /// - Returns: 返回随机生成的颜色
    class func random() -> UIColor {
//        let red   = CGFloat(arc4random() % 255) / 255.0
//        let green = CGFloat(arc4random() % 255) / 255.0
//        let blue  = CGFloat(arc4random() % 255) / 255.0
//        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
//        
        return UIColor(r: CGFloat(arc4random_uniform(256)), g: CGFloat(arc4random_uniform(256)), b: CGFloat(arc4random_uniform(256)))
    }
    
    
    class func color(hex: String, alpha: CGFloat? = 1.0) -> UIColor {
        
        // 去掉字符串两边的空格和换行，并且全部替换成大写字母
        var cString: String = hex.trimmingCharacters(in:.whitespacesAndNewlines).uppercased()
        
        // 该字符是否是以"#"字符开头的
        if (cString.hasPrefix("#")) {
            
            // 如果是以"#"字符开头, 去掉"#"字符
            cString = cString.substring(from: cString.index(after: cString.startIndex))
        }else if cString.hasPrefix("0x") {
            // 如果是以"0x"字符开头, 去掉"0x"字符
            let index = cString.index(cString.startIndex, offsetBy: 2)
            cString = cString.substring(from: index)
        }
        
        // 判断裁剪后的字符串是否是6位数
        if (cString.characters.count != 6) {
            return UIColor.clear
        }
        
        // 分别获取前两位、中间两位、后两位字符
        let rString = cString.substring(to: cString.index(cString.startIndex, offsetBy: 2))
        let gString = cString.substring(with: cString.index(cString.startIndex, offsetBy: 2)..<cString.index(cString.startIndex, offsetBy: 4))
        let bString = cString.substring(from: cString.index(cString.endIndex, offsetBy: -2))
        
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha!)
    }

    
    // MARK:- <-----------  由颜色生成图片  ----------->
    /// 通过颜色生成一张纯色图片
    class func image(color: UIColor) ->UIImage {
        // 设置画布的大小
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        // 开启上下文
        UIGraphicsBeginImageContext(rect.size)
        
        // defer关键字的解释: 声明一个 block，当前代码执行的闭包退出时会执行该 block
        defer {
            // 结束上下文
            UIGraphicsEndImageContext()
        }
        
        // 获得当前上下文
        let context = UIGraphicsGetCurrentContext()
        
        // 设置填充色
        context?.setFillColor(color.cgColor)
        
        // 设置填充rect
        context?.fill(rect)
        
        // 从上下文获得图片
        let image = UIGraphicsGetImageFromCurrentImageContext()

        
        // 返回获得的图片
        return image!
    }
}

//
//  UIImage+SYExtension.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/8/18.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

import Foundation
import UIKit

// MARK:- <-----------  二维码颜色渐变  ----------->
extension UIImage {
    /// 某个纯色二维码图片调用该方法获得渐变色二维码图片返回
    public func qrCode() {
        // 每组8位
        let bitsPerComponent = MemoryLayout<Int>.size
        
        // 每像素4字节
        let bytesPerPixel = 4
        
        // 获得图片的宽高
        let width:Int = Int(self.size.width)
        let height:Int = Int(self.size.height)
        
        // 图片转化为二进制文件
        let imageData = UnsafeMutableRawPointer.allocate(bytes: Int(width * height * bytesPerPixel), alignedTo: 8)
        defer {
            imageData.deallocate(bytes: Int(width * height * bytesPerPixel), alignedTo: 8)
        }
//        var addin = sockaddr_in()
//        withUnsafeMutablePointer(to: &addin) { (ptr) -> Result in
//            
//        }
        
        // 将原始黑白二维码图片绘制到像素格式为ARGB的图片上，绘制后的像素数据在imageData中。
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let imageContext = CGContext.init(data: imageData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: bitsPerComponent, bytesPerRow: width * bytesPerPixel, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue )
        UIGraphicsPushContext(imageContext!)
        imageContext?.translateBy(x: 0, y: CGFloat(height))
        imageContext?.scaleBy(x: 1, y: -1)
        self.draw(in: CGRect.init(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
    }
    
    // MARK:- <-----------  由颜色生成图片  ----------->
    /// 通过颜色生成一张纯色图片
    class func image(color: UIColor) ->UIImage? {
        
        // 获取颜色的值
        guard let components = color.cgColor.components else {
            return nil
        }
        
        guard components.count == 4 else {
            print("暂不支持rgba之外的color")
            return nil
        }
        
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
        //        context?.setFillColor(color.cgColor)
        context?.setFillColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
        
        // 设置填充rect
        context?.fill(rect)
        
        // 从上下文获得图片
        let image = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
        
        
        // 返回获得的图片
        return image
    }
    
    /// 类方法来根据颜色数组初始化一个渐变色图片
    ///
    ///     let image = UIImage.image(colorList: [UIColor.red, UIColor.green, UIColor.blue], size: CGSize.init(width: 200, height: 40), cornerRadius: 20)
    ///
    /// - Parameter colorList: 颜色数组(当只传入一个时表示没有渐变效果, 不传入时默认为白色)
    /// - Parameter size: 待生成图片的大小(不传入时默认为100x100)
    /// - Parameter cornerRadius: 圆角弧度(不传入时默认为没有圆角)
    /// - Returns: 生成的图片
    class func image(colorList:[UIColor] = [UIColor.white], size:CGSize = CGSize.init(width: 100, height: 100), cornerRadius:CGFloat = 0) ->UIImage? {
        
        assert(cornerRadius >= 0 && cornerRadius <= size.height / 2 && cornerRadius <= size.width / 2, "圆角弧度应大于等于0,且小于等于高度(假如高度小于等于宽度)一半")
        assert(size.width > 0 && size.height > 0, "size应当设置一个大于0的有效值")
        
        // 开启上下文(并设置上下文的大小)
        UIGraphicsBeginImageContext(size)
        
        // 获得当前上下文
        let context = UIGraphicsGetCurrentContext()
        
        // 给上下文填充路径(直到关闭路径为止,设置的闭合路径就是生成图片的样子)
        context?.fillPath()
        
        /** 路径开始点从左上角圆角的右侧点开始沿着想要的路径逆时针画路径
         以指定圆角半径画1/4圆弧(其中X轴正方向为0, Y轴正方向为-π/2, X轴负方向为π, Y轴负方向为π/2)
         */
        // 左上角
        context?.move(to: CGPoint.init(x: cornerRadius, y: 0))
        context?.addArc(center: CGPoint.init(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle:-CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: true)
        context?.addLine(to: CGPoint.init(x: 0, y: size.height - cornerRadius))
        
        // 左下角
        context?.addArc(center: CGPoint.init(x: cornerRadius, y: size.height - cornerRadius), radius: cornerRadius, startAngle:CGFloat(Double.pi), endAngle: CGFloat(Double.pi / 2), clockwise: true)
        context?.addLine(to: CGPoint.init(x: size.width - cornerRadius, y: size.height))
        
        // 右下角
        context?.addArc(center: CGPoint.init(x: size.width - cornerRadius, y: size.height - cornerRadius), radius: cornerRadius, startAngle:CGFloat(Double.pi / 2), endAngle: 0, clockwise: true)
        context?.addLine(to: CGPoint.init(x: size.width, y: cornerRadius))
        
        // 右上角
        context?.addArc(center: CGPoint.init(x: size.width - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle:0, endAngle: -CGFloat(Double.pi / 2), clockwise: true)
        context?.addLine(to: CGPoint.init(x: cornerRadius, y: 0))
        
        // 关闭自定义的路径
        context?.closePath()
        
        // 按关闭的路径裁剪上下文
        context?.clip()
        
        // 判断颜色数量, 假如是一种颜色的话, 不用开启颜色空间
        if colorList.count == 1 {
            // 设置填充颜色
            context?.setFillColor(colorList.first!.cgColor)
            // 填充范围(必填否则不显示颜色)
            context?.fill(CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
            // 从上下文中获取图片
            let image = UIGraphicsGetImageFromCurrentImageContext()
            // 关闭上下文
            UIGraphicsEndImageContext()
            // 返回图片
            return image
        }
        
        
        // 开启颜色空间
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 颜色转变
        let cfArray = colorList.map{return $0.cgColor} as CFArray
        
        // 设置颜色梯度
        let gradient = CGGradient.init(colorsSpace: colorSpace, colors: cfArray, locations: nil)
        
        // 绘制线性渐变
        if gradient == nil {
            // 关闭上下文
            UIGraphicsEndImageContext()
            return nil
        }
        
        context?.drawLinearGradient(gradient!, start: CGPoint.init(x: 0, y: size.height / 2), end: CGPoint.init(x: size.width, y: size.height / 2), options: .drawsAfterEndLocation)
        
        // 上下文设置颜色空间
        context?.setFillColorSpace(colorSpace)
        
        // 从上下文中获得图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        // 关闭上下文
        UIGraphicsEndImageContext()
        
        return image
    }
}

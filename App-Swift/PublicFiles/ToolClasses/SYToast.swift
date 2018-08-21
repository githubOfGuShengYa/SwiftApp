//
//  SYToast.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2018/8/21.
//  Copyright © 2018年 谷胜亚. All rights reserved.
//

import Foundation

// MARK:- <-----------  toast定义字段  ----------->
/// 富文本是否垂直居中对齐 - true居中false默认(如果设置为居中需要保证富文本的每个range都设置了font)
fileprivate let ToastDefineAttributedTextVerticalCenter = false

/// 转屏时是否隐藏toast - YES隐藏NO不隐藏
fileprivate let ToastDefineDismissWhenDeviceOrientationDidChange = true

/// 默认文案颜色
fileprivate let ToastDefineTextColor = UIColor.white

/// 默认文案字体
fileprivate let ToastDefineTextFont = UIFont.systemFont(ofSize: 15)

/// 文本与边框的间距
fileprivate let ToastDefineEdgeInsets = UIEdgeInsetsMake(15, 20, 15, 20)

/// 遮罩默认圆角
fileprivate let ToastDefineCoverCornerRadius: CGFloat = 5.0

/// 遮罩默认背景色
fileprivate let ToastDefineBackgroundColor = UIColor.black

/// 文本最大宽度
fileprivate var ToastDefineMaxToastWidth: CGFloat {
    get{
        return (UIScreen.main.bounds.size.width - 40 - ToastDefineEdgeInsets.left - ToastDefineEdgeInsets.right)
    }
}

class SYToast {
    // MARK:- <-----------  属性  ----------->
    /// 文本控件
    var textLabel: UILabel?
    /// 遮罩控件
    var coverView: UIButton?
    /// 显示时长
    var duration: CGFloat = 2.0
    /// 遮罩在window上的偏移量
    var edgeInsets: UIEdgeInsets = UIEdgeInsets.zero

    /// 有效屏幕方向
    var validOrientation: UIDeviceOrientation = .unknown
    /// 上次屏幕方向
    var lastOrientation: UIDeviceOrientation = .unknown
    
    // MARK:- <-----------  toast操作方法  ----------->
    /// 展示常规文本自定义位置显示自定义时长
    public class func show(_ text: String, edgeinsets: UIEdgeInsets = UIEdgeInsets.zero, duration: CGFloat = 2.0) {
        let toast = SYToast.init(text: text)
        toast.edgeInsets = edgeinsets
        toast.duration = duration
        toast.add()
    }
    
    /// 展示富文本居中显示默认时长
    public class func show(_ attributedText: NSMutableAttributedString, edgeinsets: UIEdgeInsets = UIEdgeInsets.zero, duration: CGFloat = 2.0) {
        let toast = SYToast.init(attributedText: attributedText)
        toast.edgeInsets = edgeinsets
        toast.duration = duration
        toast.add()
    }
    
    // MARK:- <-----------  初始化方法  ----------->
    /// 常规文本初始化方法
    init(text: String) {
        
        let textLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: ToastDefineMaxToastWidth, height: 0))
        textLabel.backgroundColor = UIColor.clear
        textLabel.textColor = ToastDefineTextColor
        textLabel.textAlignment = .center
        textLabel.font = ToastDefineTextFont
        textLabel.text = text
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byCharWrapping
        textLabel.sizeToFit()
        textLabel.frame = CGRect.init(x: 0, y: 0, width: textLabel.bounds.size.width, height: textLabel.bounds.size.height)
        
        // 遮罩
        let coverView = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: textLabel.bounds.size.width + ToastDefineEdgeInsets.left + ToastDefineEdgeInsets.right, height: textLabel.bounds.size.height + ToastDefineEdgeInsets.top + ToastDefineEdgeInsets.bottom))
        coverView.layer.cornerRadius = ToastDefineCoverCornerRadius
        coverView.backgroundColor = ToastDefineBackgroundColor
        coverView.alpha = 0.0
        coverView.addSubview(textLabel)
        textLabel.center = coverView.center
        coverView.addTarget(self, action: #selector(toastDismiss), for: .touchDown)
        
        self.textLabel = textLabel
        self.coverView = coverView
        self.validOrientation = UIDevice.current.orientation
        self.lastOrientation = UIDevice.current.orientation
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    /// 富文本初始化方法
    init(attributedText: NSMutableAttributedString) {
        
        let textLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: ToastDefineMaxToastWidth, height: 0))
        textLabel.backgroundColor = UIColor.clear
        textLabel.textAlignment = .center
        textLabel.textColor = ToastDefineTextColor
        textLabel.attributedText = attributedText
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byCharWrapping
        textLabel.sizeToFit()
        textLabel.frame = CGRect.init(x: 0, y: 0, width: textLabel.bounds.size.width, height: textLabel.bounds.size.height)
        
        // 遮罩
        let coverView = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: textLabel.bounds.size.width + ToastDefineEdgeInsets.left + ToastDefineEdgeInsets.right, height: textLabel.bounds.size.height + ToastDefineEdgeInsets.top + ToastDefineEdgeInsets.bottom))
        coverView.layer.cornerRadius = ToastDefineCoverCornerRadius
        coverView.backgroundColor = ToastDefineBackgroundColor
        coverView.alpha = 0.0
        coverView.addSubview(textLabel)
        textLabel.center = coverView.center
        
        // 富文本文字是否垂直居中对齐
        if ToastDefineAttributedTextVerticalCenter {
            textLabel.attributedText = attributedText.alignCenterText(maxWidth: ToastDefineMaxToastWidth)
        }

        coverView.addTarget(self, action: #selector(endAnimation), for: .touchDown)
        
        self.textLabel = textLabel
        self.coverView = coverView
        self.validOrientation = UIDevice.current.orientation
        self.lastOrientation = UIDevice.current.orientation
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK:- <-----------  逻辑方法  ----------->
    /// 展示遮罩到window上
    public func add() {
        let window = (UIApplication.shared.delegate as! AppDelegate).window!
        coverView?.center = centerPoint()
        window.addSubview(coverView!)
        
        beginAnimation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(duration + 0.3)) {
            self.endAnimation()
        }
    }
    
    /// 计算遮罩中心点的位置
    private func centerPoint() ->CGPoint {
        let window = (UIApplication.shared.delegate as! AppDelegate).window!
        var centerX = window.center.x
        var centerY = window.center.y
        
        if edgeInsets.top > 0 {
            edgeInsets.bottom = 0
            centerY = edgeInsets.top + coverView!.bounds.size.height / 2
        }
        
        if edgeInsets.left > 0 {
            edgeInsets.right = 0
            centerX = edgeInsets.left + coverView!.bounds.size.width / 2
        }
        
        if edgeInsets.bottom > 0  {
            edgeInsets.top = 0
            centerY = window.bounds.size.height - edgeInsets.bottom - coverView!.bounds.size.height / 2
        }
        
        if edgeInsets.right > 0 {
            edgeInsets.left = 0
            centerX = window.bounds.size.width - edgeInsets.right - coverView!.bounds.size.width / 2
        }
        
        return CGPoint.init(x: centerX, y: centerY)
    }
    
    /// 开始动画
    private func beginAnimation() {
        UIView.beginAnimations("begin", context: nil)
        UIView.setAnimationCurve(.easeIn)
        UIView.setAnimationDuration(0.3)
        coverView?.alpha = 1.0
        UIView.commitAnimations()
    }
    
    /// 结束动画
    @objc private func endAnimation() {
        UIView.beginAnimations("end", context: nil)
        UIView.setAnimationCurve(.easeOut)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStop(#selector(toastDismiss))
        UIView.setAnimationDuration(0.3)
        coverView?.alpha = 0.0
        UIView.commitAnimations()
    }
    
    /// 从window上移除遮罩
    @objc private func toastDismiss() {
        coverView?.removeFromSuperview()
    }
    
    /// 屏幕发生转变
    @objc private func deviceOrientationDidChange() {
        
        if transformIsValidated() == false {
            return
        }
        
        // 屏幕方向转变时是否销毁遮罩
        if ToastDefineDismissWhenDeviceOrientationDidChange {
            endAnimation()
        } else {
            
            textLabel?.frame = CGRect.init(x: 0, y: 0, width: ToastDefineMaxToastWidth, height: 10)
            textLabel?.sizeToFit()
            
            UIView.animate(withDuration: 0.3) {
                self.textLabel?.frame.size = CGSize.init(width: self.textLabel!.bounds.size.width, height: self.textLabel!.bounds.size.height)
                self.coverView?.frame = CGRect.init(x: 0, y: 0, width: self.textLabel!.bounds.size.width + ToastDefineEdgeInsets.left + ToastDefineEdgeInsets.right, height: self.textLabel!.bounds.size.height + ToastDefineEdgeInsets.top + ToastDefineEdgeInsets.bottom)
                self.textLabel?.center = self.coverView!.center
                self.coverView?.center = self.centerPoint()
            }
        }
    }
    
    /// 屏幕状态变化是否有效
    private func transformIsValidated()->Bool {
        
        // 当前改变后的屏幕状态
        let orient = UIDevice.current.orientation
        var status: Bool = true
        
        // 无效状态: 1. 正面向上、2.正面向下、3.倒向竖屏
        let invalidList:[UIDeviceOrientation] = [UIDeviceOrientation.faceUp, UIDeviceOrientation.faceDown, UIDeviceOrientation.portraitUpsideDown]
        
        if invalidList.contains(orient) // 无效状态
        {
            lastOrientation = orient
            status = false
        }
        else
        {
            // 起始状态为正面向上或向下, 无效
            if invalidList.contains(validOrientation)
            {
                validOrientation = orient
                status = false
            }
            else if validOrientation == orient // 与有效状态保持一致, 无效
            {
                status = false
            }
            else // 其他状态, 有效
            {
                validOrientation = orient
            }
            
            lastOrientation = orient
        }
        
        return status
    }
    
    // MARK:- <-----------  销毁对象  ----------->
    deinit {
        print("[SYToast]已销毁")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
}

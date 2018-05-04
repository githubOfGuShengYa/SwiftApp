//
//  UIView+SYExtension.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/7/10.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

import Foundation
import UIKit

// 声明一个全局变量,编制了一个独特的地址作为assoc对象句柄也就是地址空间
struct AssociatedObjectKey {
    static var stringTagKey: String = "stringTagKey"  // assoc更改的是地址空间 跟类型无关
}

extension UIView {
    
    /// 给视图添加string类型的tag
    var stringTag: String {
        
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.stringTagKey) as! String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.stringTagKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 视图的控制器
    var sy_viewController: UIViewController? {
        get  {
            
            // 创建个属性持有self
            var superView: UIView? = self
            
            // 循环遍历子视图
            repeat{
                // 获得响应者链中的下一个响应者，或者nil没有下一个响应者。
                if let responder = superView?.next ,responder.isKind(of: UIViewController.self) {
                    // 如果该响应者属于UIViewController类, 则立即返回
                    return (responder as! UIViewController)
                }
                
                // 没找到UIViewController类, 则从其父视图开始寻找
                superView = superView?.superview
            }while next != nil
            
            // 当该view的所有下一响应者都不属于UIViewController类的时候返回nil
            return nil
        }
    }
}

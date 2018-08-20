//
//  SYTabbarItem.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2018/6/15.
//  Copyright © 2018年 谷胜亚. All rights reserved.
//

import UIKit

class SYTabbarItem: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 1.高亮时不自动调整图标
        adjustsImageWhenHighlighted = false
        // 2.文本框的文字颜色
        setTitleColor(UIColor.init(hex: "0x666666"), for: .normal)
        setTitleColor(UIColor.init(hex: "0xe64c65"), for: .selected)
        // 3.文本框文字字体
        tintColor = .white
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        // 4.文本框文字对其方式
        titleLabel?.textAlignment = .center
        // 5.图片框内容model
        imageView?.contentMode = .center
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleRect = super.titleRect(forContentRect: contentRect)
        if titleRect.size.width == 0 {
            return super.imageRect(forContentRect: contentRect)
        }
        
        // 自己调整图片大小
        let height = (bounds.size.height - 10 - 5 - 2) / 3 * 2
        let width = height
        let x = (bounds.size.width - width) / 2
        let y:CGFloat = 10.0
        return CGRect.init(x: x, y: y, width: width, height: height)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let height = (bounds.size.height - 10 - 5 - 2) / 3
        let width = contentRect.size.width
        
        let x = (bounds.size.width - width) / 2
        let y = bounds.size.height - 5 - height
        return CGRect.init(x: x, y: y, width: width, height: height)
    }
}

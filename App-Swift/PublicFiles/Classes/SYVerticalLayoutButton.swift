//
//  SYVerticalButton.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/9/8.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//  图片与文字垂直布局按钮

import Foundation

class SYVerticalLayoutButton: UIButton {
    
    // 图片框与文本框的间距, 默认是5
    private var margin: CGFloat
    
    
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - frame: 传个CGRect.zero即可
    ///   - margin: 图片框与文本框的间距, 默认是5
    init(frame: CGRect = CGRect.zero, margin: CGFloat = 5.0) {
        
        self.margin = margin
        

        
        super.init(frame: frame)
        
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.lineBreakMode = .byClipping
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 图片框的布局
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        
        return relayout(contentRect: contentRect, isImageView: true)
    }
    
    // 标签的布局
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        
        return relayout(contentRect: contentRect, isImageView: false)
    }
    
    /// 重新布局图片框和标签框
    private func relayout(contentRect: CGRect, isImageView: Bool) ->CGRect {
        
        // 获取按钮的实际宽高
        let width = contentRect.size.width
        let height = contentRect.size.height
        
        // 获取按钮的中心点坐标
        let center = CGPoint(x: width / 2, y: height / 2)
        
        // 获得自适应后的图片框的rect
        let imageRect = super.imageRect(forContentRect: contentRect)
        // 获得自适应后的文本框的rect
        let titleRect = super.titleRect(forContentRect: contentRect)
        
        // 图片框和文本框的宽高
        let imageW = imageRect.size.width
        let imageH = imageRect.size.height
        let titleW = titleRect.size.width
        let titleH = titleRect.size.height

        // 假设把两个控件组成一个组合控件
        // 组合控件的W、H
        let totalH = imageH + titleH + margin
        let totalW = imageW > titleW ? imageW : titleW

        // 组合控件的X、Y
        let totalX = center.x - totalW / 2
        let totalY = center.y - totalH / 2
        
        
        var rect: CGRect
        if isImageView { // 图片框
            // 单一的图片框的X、Y
            let imageX = totalX + (totalW - imageW) / 2
            let imageY = totalY
            rect = CGRect(x: imageX, y: imageY, width: imageW, height: imageH)
        }else {
            // 单一的标签的X、Y
            let titleX: CGFloat = 0 // 即使文本框的宽度小于图片框的宽度, 仍然可以让文本框的宽度等于组合控件的宽度
            let titleY = totalY + totalH - titleH
            rect = CGRect(x: titleX, y: titleY, width: width, height: titleH)
        }
        
        return rect
    }
}

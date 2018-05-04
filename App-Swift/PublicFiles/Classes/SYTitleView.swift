//
//  SYChooseableView.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/8/29.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//  可选择的视图

import UIKit
/// 点击事件回调协议
protocol SYTitleViewDelegate {
    /// 点击某个视图之后调起block -- 传入当前视图以及被点中的视图的索引
    func clickCallback(dependon: SYTitleView, selectedIndex: Int)
}

/// 选择视图的风格
class SYTitleStyle {
    /// 标题普通颜色
    var titleNormalColor    : UIColor   = .black
    /// 标题高亮颜色
    var titleHighlightColor : UIColor   = .red
    /// 标题字体大小
    var titleFont           : UIFont    = UIFont.systemFont(ofSize: 14)
    /// 标题之间X方向的间距
    var titlesMargin        : CGFloat   = 20.0
    
    /// 是否可以滚动
    var scrollEnable        : Bool      = true
    /// 标题最小宽度
    var titleMinWidth       : CGFloat   = 30
    /// 选中视图放大比例
    var zoomScale           : CGFloat   = 1.2
    /// 是否放大
    var zoomEnable          : Bool      = true
    
    /// 底部相同颜色线条是否显示
    var isBaseLineShow      : Bool      = true
    /// 底部线条的高度
    var baseLineHeight      : CGFloat   = 3.0
    /// 底部线条的宽度
    var baseLineWidth       : CGFloat   = 20.0
    /// 底部线条的宽度是否根据文本宽度自动调整
    var baseLineWidthToFit  : Bool      = true
    /// 底部线条的颜色
    var baseLineColor       : UIColor   = UIColor.red
    
    /// 背景遮罩是否显示
    var isCoverShow         : Bool      = true
    /// 遮罩背景颜色
    var coverColor          : UIColor   = UIColor.lightGray
    /// 背景遮罩的高度
    var coverHeight         : CGFloat   = 25.0
    /// 第一个跟最后一个距离滚动框左右间距
    var leftMargin          : CGFloat   = 15.0
    /// 遮罩圆角
    var radius              : CGFloat   = 12.5
}

class SYTitleView: UIView {
    
    /// 传入的标题数组
    fileprivate var titles: [String]!
    /// 传入的风格
    fileprivate var style: SYTitleStyle!
    /// 协议对象
    var myDelegate: SYTitleViewDelegate?
    
    /// 滚动框
    fileprivate var scrollView: UIScrollView!
    /// 底部横条
    fileprivate var baseLine: UIView!
    /// 底部移动的视图
    fileprivate var coverView: UIView!
    /// 用户设置title的frame的数组
    fileprivate var titleLabelArray = [UILabel]()
    /// 当前高亮的label
    fileprivate var highlightLabel: UILabel!

    /// 自定义构造函数
    init(frame: CGRect, titles: [String], style: SYTitleStyle) {
        super.init(frame: frame)
        
        assert(titles.count > 0, "传入的标签名数组不能为空")
        self.titles = titles
        self.style = style
        
        // 初始化UI
        uiInitializeSetting()
        // 设置frame
        uiFrameSetting()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK:- <-----------  UI设置  ----------->
extension SYTitleView {
    /// 控件初始化
    fileprivate func uiInitializeSetting() {
        // 滚动框
        scrollView = UIScrollView()
        scrollView.frame = bounds
        scrollView.showsVerticalScrollIndicator = false // 垂直
        scrollView.showsHorizontalScrollIndicator = false // 水平
        addSubview(scrollView)
        
        // 设置title
        titlesUISetting()
        
        // 设置底部随点击事件移动的横条
        if style.isBaseLineShow {
            baseLineUISetting()
        }

        // 设置背景移动的视图
        if style.isCoverShow {
            coverViewUISetting()
        }
    }
    
    /// 设置标题
    private func titlesUISetting() {
        // 遍历title数组
        for (index, text) in titles.enumerated() {
            // 创建label
            let label = UILabel()
            label.tag = index
            label.text = text
            label.textColor = index == 0 ? style.titleHighlightColor : style.titleNormalColor
            label.font = style.titleFont
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            // 添加手势
            let gesture = UITapGestureRecognizer(target: self, action: #selector(titleLabelClickAction(sender:)))
            label.addGestureRecognizer(gesture)
            label.sizeToFit()
            titleLabelArray.append(label)
            scrollView.addSubview(label)
        }
    }
    
    /// 设置底部随点击事件移动的横条
    private func baseLineUISetting() {
        baseLine = UIView()
        baseLine.backgroundColor = style.baseLineColor
        scrollView.addSubview(baseLine)
    }
    
    // 设置背景移动的视图
    private func coverViewUISetting() {
        coverView = UIView()
        coverView.backgroundColor = style.coverColor
        coverView.layer.cornerRadius = style.radius
        coverView.layer.masksToBounds = true
        // 插入到最底层
        scrollView.insertSubview(coverView, at: 0)
    }
    
    /// 控件frame设置
    fileprivate func uiFrameSetting() {
        
        var labelX: CGFloat = 0.0
        var labelY: CGFloat = 0.0
        var labelW: CGFloat = 0.0
        var labelH: CGFloat = 0.0
        
        var maxX: CGFloat = style.leftMargin
        // 所有label的总宽度
        let totalW: CGFloat = titleLabelArray.reduce(0) { (sum, label) -> CGFloat in
            return sum + (label.bounds.width > style.titleMinWidth ? label.bounds.width : style.titleMinWidth)
        }
        
        if style.scrollEnable { // 可以滚动

            for label in titleLabelArray {
                labelW = (label.bounds.width > style.titleMinWidth ? label.bounds.width : style.titleMinWidth)
                labelH = label.bounds.height
                
                labelX = maxX
                labelY = (self.bounds.height - labelH) / 2
                
                maxX = maxX + labelW + style.titlesMargin
                
                label.frame = CGRect.init(x: labelX, y: labelY, width: labelW, height: labelH)
            }
            
            // 计算最后一个label的宽度
            let lastLabel = titleLabelArray.last!

            // 设置滚动框的可滚动范围
            scrollView.contentSize = CGSize.init(width: maxX, height: lastLabel.bounds.height)
            
        }else { // 不可以滚动
            
            // 计算出每个title之间的间距
            let newMargin = (self.bounds.width - totalW - 2 * style.leftMargin) / CGFloat(titleLabelArray.count - 1)
            assert(newMargin >= 10, "标题之间没有了足够间距, 建议使用可以滚动式")
            
            
            for label in titleLabelArray {
                labelW = (label.bounds.width > style.titleMinWidth ? label.bounds.width : style.titleMinWidth)
                labelH = label.bounds.height
                
                labelX = maxX
                labelY = (self.bounds.height - labelH) / 2
                
                maxX = maxX + labelW + newMargin
                
                label.frame = CGRect.init(x: labelX, y: labelY, width: labelW, height: labelH)
            }
        }
        
        if style.isCoverShow {
            // coverView的frame
            let firstLabel = titleLabelArray.first!
            var coverViewSize = firstLabel.frame.size
            coverViewSize.height = style.coverHeight
            coverViewSize.width += style.coverHeight / 2 + 5
            
            let coverViewCenter = firstLabel.center
            coverView.frame = CGRect.init(x: 0, y: 0, width: coverViewSize.width, height: coverViewSize.height)
            coverView.center = coverViewCenter
        }

        if style.isBaseLineShow {
            // 设置下侧随点击事件滚动的线条的frame
            let firstLabel = titleLabelArray.first!
            var baseLineSize = firstLabel.frame.size
            var baseLineOrigin = firstLabel.frame.origin
            if !style.baseLineWidthToFit {
                baseLineSize.width = style.baseLineWidth
            }
            baseLineSize.height = style.baseLineHeight
//            let baseLineMaxY = firstLabel.frame.maxY
            baseLineOrigin.y = scrollView.bounds.height - style.baseLineHeight
            baseLineOrigin.x += (firstLabel.frame.width - baseLineSize.width) / 2
            
            baseLine.frame = CGRect.init(x: baseLineOrigin.x, y: baseLineOrigin.y, width: baseLineSize.width, height: baseLineSize.height)
        }
        
        // 把第一个label持有
        highlightLabel = titleLabelArray.first!
        
        // 设置放大
        if style.zoomEnable {
            // 让新视图放大
            highlightLabel.transform = CGAffineTransform(scaleX: style.zoomScale, y: style.zoomScale)
        }
    }
    
    /// 底线frame改变
    fileprivate func baseLineFrameChange(to: UILabel) {
        UIView.animate(withDuration: 0.3) { 
            var baseLineSize = to.frame.size
            var baseLineOrigin = to.frame.origin
            if !self.style.baseLineWidthToFit {
                baseLineSize.width = self.style.baseLineWidth
            }
            baseLineSize.height = self.style.baseLineHeight
            let baseLineMaxY = to.frame.maxY
            baseLineOrigin.y = baseLineMaxY + 5
            baseLineOrigin.x += (to.frame.width - baseLineSize.width) / 2
            
            self.baseLine.frame = CGRect.init(x: baseLineOrigin.x, y: baseLineOrigin.y, width: baseLineSize.width, height: baseLineSize.height)
        }
    }
    
    /// 背景视图frame改变
    fileprivate func coverViewFrameChange(to: UILabel) {
        // 动画的形式移动到指定位置
        UIView.animate(withDuration: 0.3) { 
            var coverViewSize = to.frame.size
            coverViewSize.height = self.style.coverHeight
            coverViewSize.width += self.style.coverHeight / 2 + 5
            
            let coverViewCenter = to.center
            self.coverView.frame = CGRect.init(x: 0, y: 0, width: coverViewSize.width, height: coverViewSize.height)
            self.coverView.center = coverViewCenter
        }
    }
    
    /// 让点击的label移动到中间显示
    fileprivate func clickViewScrollToCenter() {
        // 判断是否不用滚动
        guard style.scrollEnable else {return}
        
        // 查看contentSize的宽是否大于滚动框的宽度
        guard scrollView.contentSize.width > scrollView.bounds.width else{return}
        
        // 计算中间位置的偏移量
        var offset = highlightLabel.center.x - bounds.width / 2
        
        // 偏移量如果小于0则不作偏移
        offset = offset < 0 ? 0 : offset
        offset = offset > scrollView.contentSize.width - scrollView.bounds.width ? scrollView.contentSize.width - scrollView.bounds.width : offset

        // 滚动滚动框
        scrollView.setContentOffset(CGPoint.init(x: offset, y: 0), animated: true)
    }
}

// MARK:- <-----------  事件  ----------->
extension SYTitleView {
    @objc fileprivate func titleLabelClickAction(sender: UITapGestureRecognizer) {
        // 获得手势所在的视图
        guard let gestureView = sender.view as? UILabel else {
            print("找不到该手势所在的视图")
            return
        }
        
        // 判断当前点击的label是否是已经高亮的label
        guard gestureView != highlightLabel else {
            print("点击的是同一个视图")
            return
        }
        
        // 设置放大
        if style.zoomEnable {
            // 让原视图变回原来大小
            highlightLabel.transform = CGAffineTransform.identity
            // 让新视图放大
            gestureView.transform = CGAffineTransform(scaleX: style.zoomScale, y: style.zoomScale)
        }
        
        // 改变颜色
        highlightLabel.textColor = style.titleNormalColor
        gestureView.textColor = style.titleHighlightColor
        highlightLabel = gestureView
        
        // 让点击的按钮滚动到中间
        clickViewScrollToCenter()
        
        // 移动底线
        if style.isBaseLineShow {
            baseLineFrameChange(to: highlightLabel)
        }
        
        // 移动底部视图
        if style.isCoverShow {
            coverViewFrameChange(to: highlightLabel)
        }
        
        // 调起回调
        if myDelegate != nil {
            myDelegate?.clickCallback(dependon: self, selectedIndex: highlightLabel.tag)
        }
    }
}

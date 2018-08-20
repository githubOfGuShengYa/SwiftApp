//
//  SYTabbar.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2018/6/15.
//  Copyright © 2018年 谷胜亚. All rights reserved.
//

import UIKit

class SYTabbarModel: NSObject {
    var tabbarItem: SYTabbarItem? = nil
    var itemOffset: CGPoint = CGPoint.zero
    var clickBlock: (() ->Void)? = nil
}

class SYTabbar: UITabBar {
    
    /// 模型list
    var itemList: [SYTabbarModel] = Array()
    /// 当前选中项
    var currentSelected: SYTabbarItem? = nil;

    override init(frame: CGRect) {
        super.init(frame: frame)
//        barTintColor = .white
        if let color = UIColor.color(hex: "0xffffff") {
            // 分页控制条的背景图片与barTintColor(背景颜色)冲突(且设置了该值其他值就无效了)，只需要设置这一个属性就可以了
            // 当设置了该值后_UIBarBackground属性中就只剩了分页条上侧分割线图片框和背景图片框了
            backgroundImage = UIImage.image(color: color)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTabbarItem(normal: String, selected: String, title: String, overstep: CGFloat = 0.0, action: @escaping ()->Void) {
        // 0. item模型
        let model = SYTabbarModel()
        model.itemOffset.y = overstep
        model.clickBlock = action
        
        // 1. 初始化item并设置相应属性
        let item = SYTabbarItem(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        item.setTitle(title, for: .normal)
        item.setTitle(title, for: .selected)
        item.setImage(UIImage.init(named: normal), for: .normal)
        item.setImage(UIImage.init(named: selected), for: .selected)
        item.imageView?.contentMode = .center
        item.addTarget(selected, action: #selector(tabbarItemClickAction(sender:)), for: .touchUpInside)
        model.tabbarItem = item
        
        // 2. 保存该item并添加到父视图上
        addSubview(item)
        itemList.append(model)
    }
    
    /// 重写子控件布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 1. 移除系统自动创建的tabbarButton
        for child in subviews {
            if child.isKind(of: UIControl.self) {
                if child.isKind(of: SYTabbarItem.self) {continue}
                child.removeFromSuperview()
            }
        }
        
        // 2. 获取tabbar的size
        let tabbarSize = bounds.size
        
        // 3. 数组中没有数据则返回
        if itemList.count == 0 {return}
        
        // 4. 平均每个item的宽度
        let averageWidth = tabbarSize.width / CGFloat(itemList.count)
        
        // 5. 遍历数组并布局每个item的frame
        for i in 0..<itemList.count {
            let model = itemList[i]
            let item = model.tabbarItem
            item?.tag = i
            item?.frame = CGRect.init(x: CGFloat(i) * averageWidth, y: model.itemOffset.y, width: averageWidth, height: 49 - model.itemOffset.y)
            
            if i == 0 {currentSelected = item; currentSelected?.isSelected = true}
        }
    }
    
    @objc private func tabbarItemClickAction(sender: UIButton) {
        // 判断点击的是否已选中
        if sender.isSelected {return}
        
        // 根据tag值取得对应model
        let model = itemList[sender.tag]
        
        if model.clickBlock != nil {
            model.clickBlock!()
        }
        
        if model.itemOffset.y != 0 {return}
        
        currentSelected?.isSelected = false
        currentSelected = sender as? SYTabbarItem
        currentSelected?.isSelected = true
    }
    
    /// 点击超出tabbar部分内容时仍然有效
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //这一个判断是关键，不判断的话push到其他页面，点击发布按钮的位置也是会有反应的，这样就不好了
        //self.isHidden == NO 说明当前页面是有tabbar的，那么肯定是在导航控制器的根控制器页面
        //在导航控制器根控制器页面，那么我们就需要判断手指点击的位置是否在发布按钮身上
        //是的话让发布按钮自己处理点击事件，不是的话让系统去处理点击事件就可以了
        if isHidden {
            // tabbar隐藏了那么说明不需要判断是否点击tabbar内容, 因此让系统去判断合适view进行处理
            return super.hitTest(point, with: event)
        }
        
        // 将当前tabbar的触摸点转换坐标系, 转换到中间按钮的身上, 生成一个新的坐标点
        for model in itemList {
            if model.itemOffset.y == 0 {continue}
            
            let convertPoint = convert(point, to: model.tabbarItem)
            
            guard let item = model.tabbarItem else {
                return super.hitTest(point, with: event)
            }
            
            if item.point(inside: convertPoint, with: event) {
                return model.tabbarItem
            }
        }
        
        // 如果点不在中间按钮身上则直接让系统处理
        return super.hitTest(point, with: event)
    }
}


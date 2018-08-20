//
//  SYBaseTabbarController.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2018/6/15.
//  Copyright © 2018年 谷胜亚. All rights reserved.
//

import UIKit

class SYBaseTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        resetTabbar()
        // Do any additional setup after loading the view.
    }
    
    private func resetTabbar() {
        // 初始化自己的tabbar并替换系统的tabbar
        let tabbar = SYTabbar.init()
        self.setValue(tabbar, forKeyPath: "tabBar")
        
        // 对self弱引用
        weak var weakSelf = self
        
        // 添加自定义的tabbar子控件
        tabbar.addTabbarItem(normal: "home_normal", selected: "home_selected", title: "第一页") {
            weakSelf?.selectedIndex = 0
        }
        tabbar.addTabbarItem(normal: "course_normal", selected: "course_selected", title: "第二页") {
            weakSelf?.selectedIndex = 1
        }
        tabbar.addTabbarItem(normal: "add_normal", selected: "add_normal", title: "", overstep: -10) {
            
        }
        tabbar.addTabbarItem(normal: "task_normal", selected: "task_selected", title: "第三页") {
            weakSelf?.selectedIndex = 2
        }
        tabbar.addTabbarItem(normal: "community_normal", selected: "community_selected", title: "第一页") {
            weakSelf?.selectedIndex = 3
        }
        
        var array: [UIViewController] = Array()
        var colors: [UIColor] = [.white, .red, .orange, .blue, .green]
        for i in 0..<5 {
            let vc = UIViewController()
            vc.view.backgroundColor = colors[i]
            array.append(vc)
        }
        
        viewControllers = array
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

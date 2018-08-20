//
//  ViewController.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/6/15.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//  控制器

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        AppTool.switchToAppStore(url: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let imgV = UIImageView.init()
        let color = UIColor.init(r: 255, g: 0, b: 0, alpha: 0.1)
//        imgV.image = UIImage.image(colorList: [color, UIColor.green], size: CGSize.init(width: 100, height: 10), cornerRadius: 0)
        imgV.image = UIImage.image(color: color)
        imgV.frame = CGRect.init(x: 40, y: 80, width: 100, height: 10)
        view.addSubview(imgV)
        
//        let btn = SYVerticalLayoutButton()
//        btn.setImage(UIImage.init(named: "normalPlayerBtn"), for: .normal)
//        btn.setTitle("我是一个标题", for: .normal)
//        btn.setTitleColor(.white, for: .normal)
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//        btn.backgroundColor = .gray
//        btn.imageView?.contentMode = .center
//        self.view.addSubview(btn)
//
//        btn.snp.makeConstraints { (make) in
//            make.top.equalTo(50)
//            make.left.equalTo(50)
//            make.width.height.equalTo(100)
//        }
//        let image = UIImage.image()
        
        
        
//        let style = SYPolygonStyle()
//        style.filletDegree = 10
//        style.borderWidth = 10
//        style.borderColor = .orange
//        style.roundedCornersEnable = true
//        style.offset = Double.pi / 4
//        style.sides = 5
//
//        let liubianxing = SYPolygonButton(frame: CGRect.zero, style: style)
//        liubianxing.setImage(UIImage.init(named: "zhbd_qq_icon"), for: .normal)
//        liubianxing.setImage(UIImage.init(named: "zhbd_weibo_icon"), for: .selected)
//        liubianxing.addTarget(self, action: #selector(btnClickAction(sender:)), for: .touchUpInside)
//        view.addSubview(liubianxing)
//        liubianxing.snp.makeConstraints { (make) in
//            make.top.left.equalTo(100)
//            make.width.height.equalTo(100)
//        }
        

    }
    
    @objc func btnClickAction(sender: SYPolygonButton) {
        print(sender, "按钮点击")
        sender.isSelected = !sender.isSelected
    }

    func test() {
        // 1. 数组的map函数测试
        let array = ["first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", ""]
        let counts = array.map{$0.characters.count}
        print(counts)  // [5, 6, 5, 6, 5, 5, 7, 6, 5, 0]
        
        // 2. flatMap的测试 
        // flatMap返回后的数组中不存在nil 同时它会把Optional解包
        let nilNotable = array.flatMap { (str) -> Int? in
            if str.characters.count > 0 {
                return str.characters.count
            }
            
            return nil
        }
        print(nilNotable) // [5, 6, 5, 6, 5, 5, 7, 6, 5]
        
        //  flatMap 还能把数组中存有数组的数组 一同打开变成一个新的数组
        let oldArray = [["1", "2", "3"], ["3", "4", "5"], ["5", "6", "7"]]
        let newArray = oldArray.flatMap{$0}
        print(newArray) // ["1", "2", "3", "3", "4", "5", "5", "6", "7"]
        
        // flatMap也能把两个不同的数组合并成一个数组 这个合并的数组元素个数是前面两个数组元素个数的乘积 -- 矩阵样式
        // 横向
        let horizontal = [1, 2, 3]
        // 纵向
        let vertical = ["a", "b", "c"]
        // 矩阵
        let matrix = horizontal.flatMap { itemX in
            vertical.map{ itemY in
                // 两数相合
                itemY + "\(itemX)" // ["a1", "b1", "c1", "a2", "b2", "c2", "a3", "b3", "c3"]
                // 返回矩阵的子值
//                (itemX, itemY) // [(1, "a"), (1, "b"), (1, "c"), (2, "a"), (2, "b"), (2, "c"), (3, "a"), (3, "b"), (3, "c")]
            }
        }
        print(matrix)
        
        
        // 3. Filter筛选函数的使用
        // filter 可以取出数组中符合条件的元素 重新组成一个新的数组
        let  oddNumber = array.filter{$0.characters.count % 2 == 1}
        print(oddNumber) // ["first", "third", "fifth", "sixth", "seventh", "ninth"]
        
        // 4. Reduce合并数组为一个值 -- 把所有元素的值合并成一个新的值
        let numbers = [1, 2, 3, 4, 5]
        let sum = numbers.reduce(0) {$0 + $1} // 15
        let compose = numbers.reduce("") {"\($0)" + "\($1)"} // "12345"
        print("总和的值: \(sum), 组合的值: \(compose)")
        
        print(01.numberString)
        
        
    }
}


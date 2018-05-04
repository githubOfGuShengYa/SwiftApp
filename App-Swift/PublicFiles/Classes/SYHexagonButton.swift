//
//  SYPolygonButton.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/9/7.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//  正多边形按钮

import Foundation


/// 六边形按钮的风格
class SYPolygonStyle {
    /// 是否可以圆角
    var roundedCornersEnable: Bool = false
    /// 圆角程度 - 值越大,角越平滑
    var filletDegree: Double = 5.0
    
    /// 边界宽度(边线的宽度)
    var borderWidth: CGFloat = 0.0
    /// 边界颜色
    var borderColor: UIColor = UIColor.gray
    
    /// 多边形最大半径 -- 如果不设置该值, 默认是按钮中可显示的最大多边形的半径
    var Max_Radius: CGFloat = 0.0
    
    /// 整个路径以按钮的中心点为中心按顺时针方向偏移的弧度(需要传入一个带π的弧度) -- 默认六边形顶点为水平方向, 如果设置该值为π/2则顶点为竖直方向
    var offset: Double = 0
    /// 多边形的边数 - 默认是正六边形
    var sides: Int = 6
}


/// 六边形按钮
class SYPolygonButton: UIButton {
    
    private var style: SYPolygonStyle
    
    init(frame: CGRect = CGRect.zero, style: SYPolygonStyle = SYPolygonStyle()) {
        
        self.style = style
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        hexagon()
    }
    
    // 创建六边形
    private func hexagon() {
        
        // 最大半径
        var Max_R: CGFloat
        if style.Max_Radius == 0 {
            // 获取当前按钮的宽和高
            let W = bounds.width
            let H = bounds.height
            assert(W > 0 && H > 0, "此时宽或者高没有值")
//            // 判断根号3倍的宽是否大于高
//            let isWBigger: Bool = W * sqrt(3.0) > H
//            // 获得多边形的R
//            Max_R = isWBigger ? H / 2 : sqrt(3.0) / 3 * W
            Max_R = H > W ? W / 2 : H / 2
        }else {
            Max_R = style.Max_Radius
        }
        
        assert(Max_R > style.borderWidth, "多边形最大半径不能小于边界宽度")
        
        // 删除子layer
        for (index, layer) in self.layer.sublayers!.enumerated() {
            if index != 0 {
                layer.removeFromSuperlayer()
            }
        }
        
        // 创建底层layer
        let topLayer = CAShapeLayer()
        // 设置路径
        topLayer.path = drawPath(radius: Max_R)
        // 设置线条颜色
        topLayer.strokeColor = style.borderColor.cgColor
        // 设置被圈定部分填充色
        topLayer.fillColor = UIColor.clear.cgColor
        // 设置边线宽度
        topLayer.lineWidth = style.borderWidth
//        topLayer.lineCap = kCALineCapRound
//        topLayer.lineJoin = kCALineJoinBevel
        
        // 创建上层layer
        let bottomLayer = CAShapeLayer()
        // 设置上层layer的path
        bottomLayer.path = drawPath(radius: Max_R)
        
        // mask图层定义了父图层的部分可见区域,mask层的颜色属性是无关紧要的.mask图层实心的部分会被保留下来，其他的则会被抛弃。
        self.layer.mask = bottomLayer // 如果mask设置为有strokeColor的layer, 则显示的部分只有边界线条部分
        self.layer.insertSublayer(topLayer, above: bottomLayer)
    }

    
    
    /// 绘制多边形路径
    ///
    /// - Parameter radius: 传入的多边形的半径
    /// - Returns: 返回绘制好的路径
    private func drawPath(radius: CGFloat) ->CGPath {
        
        // 获取当前按钮的宽和高
        let W = bounds.width
        let H = bounds.height
        assert(W > 0 && H > 0, "此时宽或者高没有值")
        // 判断根号3倍的宽是否大于高
        let isWBigger: Bool = W * sqrt(3.0) > H
        // 获得六边形的R
        var r = isWBigger ? H / 2 : sqrt(3.0) / 3 * W
        assert(radius <= r, "传入的半径超过可以显示的最大半径")
        if radius < r {
            r = radius
        }
        
        // 创建贝塞尔曲线
        let path = UIBezierPath()
        
        
        
        if style.roundedCornersEnable { // 显示圆角
            
            let points = regularPolygonCoordinatesWithRoundedCorner(sides: style.sides, radius: r, offset: style.offset)
            
            // 持有顶点
            var temPoint: CGPoint!
            
            for (index, point) in points.enumerated() {
                
                if index == 0 {
                    path.move(to: point)
                }else {
                    
                    // 先看索引对3求余
                    let remainder = index % 3
                    
                    switch remainder {
                    case 0: // 顶点左侧点
                        path.addLine(to: point)
                    case 1: // 顶点
                        temPoint = point
                    case 2: // 顶点右侧点
                        path.addQuadCurve(to: point, controlPoint: temPoint)
                    default:
                        break
                    }
                }
            }
            path.close()
            
        }else { // 不显示圆角
            
            // 顺时针设置各个点
            let points = regularPolygonCoordinates(sides: style.sides, radius: r, offset: style.offset)

            for (index, point) in points.enumerated() {
                if index == 0 {
                    path.move(to: point)
                }else {
                    path.addLine(to: point)
                }
            }
            path.close()
        
        }
        
        
        // 返回路径
        return path.cgPath
    }
    
    
    
    
    /// 根据传入的半径、弧度以及偏移量计算出该点的坐标
    ///
    /// - Parameters:
    ///   - radius: 某个多边形的半径
    ///   - angle: 该点相对于中心点的弧度
    ///   - offset: 以按钮的中心点为中心按顺时针方向偏移的弧度(需要传入一个带π的弧度)
    /// - Returns: 计算好的该点的坐标
    private func vertexCoordinates(radius: CGFloat, angle: Double, offset: Double = 0) ->CGPoint {
        // 获得按钮的中心点
        let centerPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
        // x值
        let X = centerPoint.x + radius * (angle + offset).cosValue
        
        // y值
        let Y = centerPoint.y + radius * (angle + offset).sinValue
        
        // 返回点坐标
        return CGPoint(x: X, y: Y)
    }
    
    
    
    /// 正多边形各顶点的计算
    ///
    /// - Parameters:
    ///   - sides: 正多边形的边数
    ///   - radius: 正多边形的半径长度
    ///   - offset: 以按钮的中心点为中心按顺时针方向偏移的弧度(需要传入一个带π的弧度)
    /// - Returns: 返回一组按顺时针方向计算好的各顶点的坐标
    private func regularPolygonCoordinates(sides: Int, radius: CGFloat, offset: Double = 0) ->[CGPoint] {
        
        assert(sides >= 3, "多边形最少为3边")
        assert(radius > 0, "多边形半径必须大于0")
        
        // 坐标数组
        var coordinates = [CGPoint]()

        // 循环设置正多边形的每个顶点坐标
        for i in 0..<sides {
            
            // 获得多边形最小三角单元的角度
            let corner = Double(360) / Double(sides)
            // 计算出该角度对应的弧度数(自身带π)
            let radian = corner / Double(180) * Double.pi
            // 获得对应索引顶点的弧度
            let radianOfPoint = Double(i) * radian
            
            let point = vertexCoordinates(radius: radius, angle: radianOfPoint, offset: offset)
            coordinates.append(point)
        }
        
        // 返回坐标数组
        return coordinates
    }
    
    
    
    
    
    /// 正多边形的圆角设置
    ///
    /// - Parameters:
    ///   - sides: 该正多边形的边数
    ///   - radius: 半径长度
    ///   - offset: 以按钮的中心点为中心按顺时针方向偏移的弧度(需要传入一个带π的弧度)
    /// - Returns: 返回一组按顺时针方向计算好的各关键点的坐标(索引为0的点为第一个顶点的贝塞尔曲线的开始点, 索引为1的点为贝塞尔曲线控制点, 索引为2的点为贝塞尔曲线的结束点, 3个点为一个循环)
    private func regularPolygonCoordinatesWithRoundedCorner(sides: Int, radius: CGFloat, offset: Double = 0) ->[CGPoint] {
        assert(sides >= 3, "多边形最少为3边")
        assert(radius > 0, "多边形半径必须大于0")
        
        
        // 中心点与任意相邻两点形成的三角形的角度对应的弧度(自身带π)
        let CAB = Double(360) / Double(sides) / Double(180) * Double.pi
        // 斜边一半长度
        let EC = Double(radius * (CAB / 2).sinValue)
        // 以斜边为底边对应的高的长度
        let AE = Double(radius * (CAB / 2).cosValue)
        
        // 斜边一半减去圆角值
        let ED = EC - style.filletDegree
        
        // 角EAD的对应的弧度(自身带π)
        let EAD = atan(ED / AE)
        
        // 对应圆角值的角的弧度(自身带π)
        let DAC = CAB / 2 - EAD
        
        // 对应圆角值新形成的边的长度 -- 也就是小圆的半径
        let newRadius = sqrt(pow(AE, 2) + pow(ED, 2))
        
        
        // 坐标数组
        var coordinates = [CGPoint]()
        
        // 循环设置正多边形的每个顶点坐标
        for i in 0..<sides {
            
            // 顶点的方向表示的弧度(自身带π)
            let direction = Double(i) * Double(360) / Double(sides) / Double(180) * Double.pi
            
            // 顶点坐标
            let point = vertexCoordinates(radius: radius, angle: direction, offset: offset)
            
            // 顶点左侧点坐标
            let leftAngle = direction - DAC
            let leftPoint = vertexCoordinates(radius: CGFloat(newRadius), angle: leftAngle, offset: offset)
            
            // 顶点右侧点坐标
            let rightAngle = direction + DAC
            let rightPoint = vertexCoordinates(radius: CGFloat(newRadius), angle: rightAngle, offset: offset)
            
            // 添加到数组中
            coordinates.append(leftPoint)
            coordinates.append(point)
            coordinates.append(rightPoint)
        }
        
        // 返回坐标数组
        return coordinates
    }
}

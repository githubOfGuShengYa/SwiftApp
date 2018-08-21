//
//  NSAttributedString+SYExtension.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2018/8/20.
//  Copyright © 2018年 谷胜亚. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    // MARK:- <-----------  富文本的文字垂直居中对齐  ----------->
    public func alignCenterText(maxWidth:CGFloat) ->NSMutableAttributedString {
        let framesetter = CTFramesetterCreateWithAttributedString(self)
        let path = CGMutablePath.init()
        path.addRect(CGRect.init(x: 0.0, y: 0.0, width: maxWidth, height: CGFloat(MAXFLOAT)), transform: .identity)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        
        // 获取CTLine
        let lineList = CTFrameGetLines(frame) as NSArray
        // CTLine的数量
        let lineCount = CFArrayGetCount(lineList)
        // 循环
        for index in 0..<lineCount {
            // 获取指定索引的CTLine
            let line = lineList[index] as! CTLine
            // 一行内CTRun的数组
            let runList = CTLineGetGlyphRuns(line) as NSArray
            // 一行内CTRun的数量
            let runCount = runList.count

            var maxHeight: CGFloat = 0.0
            let tmpArray = NSMutableArray()
            
            for j in 0..<runCount {
                // 获取指定索引CTRun
                let run = runList[j] as! CTRun
                // 获取run处于该字符串的位置
                let runRange = CTRunGetStringRange(run)
                // 获取该range的文字, 如果是空格的话不判定高低
                let start = self.string.index(self.string.startIndex, offsetBy: runRange.location)
                let end = self.string.index(self.string.startIndex, offsetBy: runRange.location + runRange.length)
                let word = self.string.substring(with: start..<end)
                if word.contains(" ") {
                    continue
                }
                
                // 位置信息
                var runRect = CGRect.init(x: 0, y: 0, width: 0, height: 0)
                let ascent = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
                let descent = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
                let leading = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
                
                // run的宽度(并可获得该段字体的上行高、下行高、对齐高)
                let wid = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), ascent, descent, leading)
                
                // rect的组成(x:起始索引、y:字符数量、w:该字体字符长度、h:该字体字符高度)
                runRect.size.width = CGFloat(wid)
                runRect.size.height = ascent.pointee
                runRect.origin.x = CGFloat(runRange.location)
                runRect.origin.y = CGFloat(runRange.length)
                tmpArray.add(runRect)
                
                if runRect.size.height > maxHeight {
                    maxHeight = runRect.size.height
                }
            }
            
            
            for rect in tmpArray {
                let rect1 = rect as! CGRect
                if maxHeight > rect1.size.height {
                    self.addAttribute(NSBaselineOffsetAttributeName, value: (maxHeight - rect1.size.height) / 2, range: NSRange.init(location: Int(rect1.origin.x), length: Int(rect1.origin.y)))
                }
            }
        }
        
        return self
    }
}

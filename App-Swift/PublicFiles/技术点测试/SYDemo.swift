//
//  SYDemo.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/8/31.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

import Foundation

enum SYError: Error {
    case timeout
    case invalidHeader
    case missingParam(String)
    case responseFailure(code: Int, message: Data)
}

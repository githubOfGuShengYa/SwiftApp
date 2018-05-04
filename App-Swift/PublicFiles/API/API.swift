//
//  API.swift
//  WoLiveVideo
//
//  Created by 谷胜亚 on 2017/7/7.
//  Copyright © 2017年 ZhangKuLianDong. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

enum ZKError: Error {
    case Alamofire(Error?)
    case API(SYHeadMessage)
}
extension ZKError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .Alamofire(let error):
            return error?.localizedDescription ?? "没有Alamofire的error信息"
        case .API(let message):
            return message.rspMsg ?? "没有API的error信息"
        }
    }
    var errorDescription: String? {
        return localizedDescription
    }
}
extension ZKError {
    var AlamofireError: Error? {
        switch self {
        case .Alamofire(let error):
            if error != nil {
                print("网络异常:\n\(error!)")
            }
            return error
        default:
            return nil
        }
    }
}
extension ZKError {
    var APIError: SYHeadMessage? {
        switch self {
        case .API(let error):
            return error
        default:
            return nil
        }
    }
    func headMessage() -> SYHeadMessage? {
        guard let headMessage = APIError else {
            print("没有headMessage,看看是不是 Alamofire Error : \n\(AlamofireError!)")
            return nil }
        return headMessage
    }
}

//MARK:- API
class API {

    /// GET方法 -- 参数以JSON格式编码
    ///
    ///     API.get(url: ZKURL.userRegister.api(), parameters: dic, success:   { (response) in
    ///
    ///     }, failed: { (error) in
    ///
    ///     }) {
    ///
    ///     }
    ///
    /// - Parameter url: 接口地址
    /// - Parameter parameters: 参数列表
    /// - Parameter success: 请求成功回调block
    /// - Parameter failed: 请求失败回调block
    /// - Parameter completion: 请求完成回调block
    class func get(url: String, parameters: [String: Any]?, success: @escaping (_ response: SYResponse?) ->Void, failed: @escaping (ZKError?) -> Void, completion: @escaping () ->Void) {
        
        let newParameters = API.add(oldParameters: parameters)
        
        let headers:HTTPHeaders = ["Content-Type" : "application/json"]
        //        headers["Authorization"] = ""
        
        Alamofire.request(url, method: .get, parameters: newParameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            print(String(describing: response.request?.url))
            if response.result.isSuccess { // 成功
                
                let responseData = Mapper<SYResponse>().map(JSONObject: response.result.value)
                if responseData?.head?.rspCode == "0" { // 成功
                    success(responseData)
                    completion()
                }else { // 失败
                    guard let head = responseData?.head else {
                        failed(ZKError.Alamofire(response.error))
                        completion()
                        return
                    }
                    failed(ZKError.API(head))
                    completion()
                }
            }else { // 失败
                
                failed(ZKError.Alamofire(response.error))//response.error)
                completion()
            }
        }
    }
    
    
    
    class func get(url: String, parameters: [String: Any]?, success: @escaping (_ response: SYResponse?) ->Void) throws {
        
        let newParameters = API.add(oldParameters: parameters)
        
        let headers:HTTPHeaders = ["Content-Type" : "application/json"]
        //        headers["Authorization"] = ""
        
        Alamofire.request(url, method: .get, parameters: newParameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            print(String(describing: response.request?.url))
            if response.result.isSuccess { // 成功
                
                let responseData = Mapper<SYResponse>().map(JSONObject: response.result.value)
                if responseData?.head?.rspCode == "0" { // 成功
                    success(responseData)
                }else { // 失败
                    
                    guard let head = responseData?.head else {

                        return
                    }
                }
            }else { // 失败
                
            }
        }
    }
    
    
    /// POST方法 -- 参数以JSON格式编码
    ///
    ///     API.post(url: url, parameters: newParameters) { (response) in
    ///         print(response?.body, response?.head?.rspMsg)
    ///     }
    ///
    /// - Parameter url: 接口地址
    /// - Parameter parameters: 参数列表
    /// - Parameter completionHandle: 请求回调block
    class func post(url: String, parameters: [String: Any]?, success: @escaping (_ response: SYResponse?) ->Void, failed: @escaping (Error?) -> Void, completion: @escaping () ->Void) {
        
        let newParameters = API.add(oldParameters: parameters)
        
        let headers:HTTPHeaders = ["Content-Type" : "application/json"]
        //        headers["Authorization"] = ""
        
        // 其中encoding表示编码方式，默认是url明码编码，可以变成JSON编码还有Plist编码
        Alamofire.request(url, method: .post, parameters: newParameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            
            if response.result.isSuccess { // 成功
                
                let responseData = Mapper<SYResponse>().map(JSONObject: response.result.value)

                if responseData?.head?.rspCode == "0" { // 成功
                    success(responseData)
                    completion()
                }else { // 失败
                    guard let head = responseData?.head else {
                        failed(ZKError.Alamofire(response.error))
                        completion()
                        return
                    }
                    failed(ZKError.API(head))
                    completion()
                }
            }else { // 失败
                
                failed(ZKError.Alamofire(response.error))//response.error)
                completion()
            }
//            if response.result.isSuccess { // 成功
//                
//                let responseData = Mapper<SYResponse>().map(JSONObject: response.result.value)
//                success(responseData)
//                completion()
//                
//            }else { // 失败
//                
//                failed(response.error)
//                completion()
//            }
        }
    }
    
    
    /// Upload多张图片方法 -- 该方法可以增加请求头信息
    ///
    ///     API.upload(images: images, parameters: dic, to: path) { (response) in
    ///         if let msg = response?.head?.rspMsg {
    ///             print(msg)
    ///         }
    ///     }
    ///
    /// - Parameter images: 上传的图片数组 -- 不可为空
    /// - Parameter parameters: 参数列表
    /// - Parameter headers: 请求头信息
    /// - Parameter to: 上传的接口名
    /// - Parameter completionHandle: 请求回调block
    class func upload(images: [UIImage], parameters: [String:Any]?, headers: [String: String]?, to: String, completionHandle: @escaping (_ response: SYResponse?) ->Void) {
        
        var headers: HTTPHeaders? = nil
//        let headers:HTTPHeaders = ["Content-Type" : "application/json"]
        //        headers["Authorization"] = ""
        
        if let headersDic = headers {
            headers = HTTPHeaders()
            for (key, value) in headersDic {
                headers?[key] = value
            }
        }
        
        let newParameters = API.add(oldParameters: parameters)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in

            // 拼接参数
            if let existParameters = newParameters {
                
                for (key, value) in existParameters {
                    
                    if let valueData = (value as AnyObject).data(using: String.Encoding.utf8.rawValue) {
                        multipartFormData.append(valueData, withName: key)
                    }
                }
            }
            
            // 拼接图片
            for image in images {
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                if let existImageData = imageData {
                    multipartFormData.append(existImageData, withName: "file", fileName: "image.jpeg", mimeType: "image/jpeg")
                }
            }
            
        }, usingThreshold: UInt64.init(), to: to, method: .post, headers: headers) { (result) in
            switch result {
            case .success(let request, _, _):
                request.responseJSON(completionHandler: { (response) in
                    
                    let responseData = Mapper<SYResponse>().map(JSONObject: response.result.value)
                    
                    completionHandle(responseData)
                    
                })
            case .failure(let error):
                print(error.localizedDescription)
                completionHandle(nil) // 表示上传失败
            }
        }
    }
    
    
    
    
    /// Upload多张图片方法
    ///
    ///     API.upload(images: images, parameters: dic, to: path) { (response) in
    ///         if let msg = response?.head?.rspMsg {
    ///             print(msg)
    ///         }
    ///     }
    ///
    /// - Parameter images: 上传的图片数组 -- 不可为空
    /// - Parameter parameters: 参数列表
    /// - Parameter to: 上传的接口名
    /// - Parameter completionHandle: 请求回调block
    class func upload(images:[UIImage], parameters:[String:Any]?, to: String, success: @escaping (SYResponse?) ->Void, failed: ((Error?) -> Void)?, completion: (() ->Void)?) {
    
        let newParameters = API.add(oldParameters: parameters)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in

            // 拼接参数
            if let existParameters = newParameters {

                for (key, value) in existParameters {

                    if let valueData = (value as AnyObject).data(using: String.Encoding.utf8.rawValue) {
                        multipartFormData.append(valueData, withName: key)
                    }
                }
            }

            // 拼接图片
            for image in images {
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                if let existImageData = imageData {
                    multipartFormData.append(existImageData, withName: "file", fileName: "image.jpeg", mimeType: "image/jpeg")
                }
            }

        }, to: to) { (result) in
            switch result {
            case .success(let request, _, _):
                request.responseJSON(completionHandler: { (response) in
                    
                    if response.result.isSuccess { // 成功
                        
                        let responseData = Mapper<SYResponse>().map(JSONObject: response.result.value)
                        success(responseData)
                        
                        if let complet = completion {
                            complet()
                        }
                        
                    }else { // 失败
                        
                        if let fail = failed {
                            fail(response.error)
                        }
                        if let complet = completion {
                            complet()
                        }
                    }
                    
                })
            case .failure(let error):
                print(error.localizedDescription)
                if let complet = completion {
                    complet()
                }
            }
        }
    }
    
    /// 可用网络类型
    enum SYUsableNetworkType {
        /// 数据网
        case wwan
        /// 无线网
        case wifi
    }
    
    /// 是否没有网络
    class func networkStatus(usable: ((SYUsableNetworkType) -> Void)?, disabled:(() ->Void)?) {
        let manager = NetworkReachabilityManager()
        manager?.listener = { status in
            print("Network Status Changed: \(status)")
            switch status {
            case .notReachable:
                print("没有网络")
                if let failed = disabled {
                    failed()
                }
            case .reachable(.wwan):
                print("数据网")
                if let success = usable {
                    success(.wwan)
                }
            case .reachable(.ethernetOrWiFi):
                print("无线网")
                if let success = usable {
                    success(.wifi)
                }
            default:
                print("未知")
                if let failed = disabled {
                    failed()
                }
            }

        }
    }
}



/// API类的扩展
extension API {
    
    
    /// 添加网络请求中的公用参数
    ///
    ///     let newParameters = API.add(oldParameters: parameters!)
    ///
    /// - Parameter oldParameters: 旧参数列表
    /// - Returns: 添加公用参数后的参数列表
    class func add(oldParameters: [String: Any]?) -> [String: Any]? {
        
        let newParameters: [String: Any]? = oldParameters
        //        // 设备类型
        //        var deviceType: String? = nil
        //        if UIDevice.current.userInterfaceIdiom == .pad {
        //            deviceType = "iospad"
        //        }else {
        //            deviceType = "iosphone"
        //        }
        //        newParameters["platform"] = deviceType
        //
        //        // app版本
        //        //        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        //        newParameters["version"] = "3.6.4"
        //
        //        // 语言环境
        //        let isChinese: Bool = true
        //        if isChinese {
        //            newParameters["language"] = "zh_CN"
        //        }else {
        //            newParameters["language"] = "en_CN"
        //        }
        //
        //        // 时间戳
        //        //        let stamp = Date.init().timeIntervalSince1970
        //        //        newParameters["time_stamp"] = stamp
        //        
        //        //        newParameters["time_stamp"] = "1477364533.808948"

        
        return newParameters
    }

}




/// 响应模型 -- 网络请求响应JSON数据转模型
class SYResponse: Mappable {
    
    var body: Any?  // 可用数据
    var head: SYHeadMessage?  // head信息
    
    required init?(map: Map) {

    }
    
    func mapping(map: Map) {
        body <- map["body"]
        head <- map["head"]
    }
    
    func bodyDict() -> Dictionary<String, Any> {
        guard let dict = body as? Dictionary<String, Any> else {
            assertionFailure("错了,自己対数据去")
            return [:]
        }
        return dict
    }
    
    func bodyArr() -> Array<Any> {
        guard let arr = body as? Array<Any> else {
            assertionFailure("错了,自己対数据去")
            return []
        }
        return arr
    }
}

/// head模型 -- 响应数据中的head转模型
class SYHeadMessage: Mappable {
    
    var appVersion    : String?   // 应用版本
    var dataVersion   : String?   // 数据版本
    var deployVersion : String?   // 部署版本
    var msgCount      : String?   // 消息数量
    var rspCode       : String?      // 状态码
    var rspMsg        : String?   // 状态信息
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        appVersion     <- map["appVersion"]
        dataVersion    <- map["dataVersion"]
        deployVersion  <- map["deployVersion"]
        msgCount       <- map["msgCount"]
        rspCode        <- map["rspCode"]
        rspMsg         <- map["rspMsg"]
    }

}



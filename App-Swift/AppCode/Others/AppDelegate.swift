//
//  AppDelegate.swift
//  App-Swift
//
//  Created by 谷胜亚 on 2017/6/15.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

import UIKit
import Alamofire


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        
        
        // 开启网络状态监控
        startNetworkingMonitoring()
        
        
        return true
    }

    /// 网络状况监视
    func startNetworkingMonitoring() {
        let manager = NetworkReachabilityManager()
        manager?.listener = { status in
            print("Network Status Changed: \(status)")
            switch status {
            case .notReachable:
                print("没有网络")
            case .reachable(.wwan):
                print("数据网")
            case .reachable(.ethernetOrWiFi):
                print("无线网")
            default:
                print("未知")
            }
        }
        manager?.startListening()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    // MARK:- <-----------  友盟集成  ----------->
    fileprivate func UMSetting() {
        UMSocialManager.default().openLog(true)
        
        // 设置友盟appKey
        UMSocialManager.default().umSocialAppkey = umengAppKey
        
        // 设置微信appKey和appSecret
        UMSocialManager.default().setPlaform(UMSocialPlatformType.wechatSession, appKey: weichatAppKey, appSecret: weichatAppSecret, redirectURL: redirectURL)
        
        
        // 设置QQappKey和appSecret
        UMSocialManager.default().setPlaform(UMSocialPlatformType.QQ, appKey: qqAppKey, appSecret: qqAppSecret, redirectURL: redirectURL)
        
        // 设置QQ空间appKey和appSecret
        UMSocialManager.default().setPlaform(UMSocialPlatformType.qzone, appKey: qqAppKey, appSecret: qqAppSecret, redirectURL: redirectURL)
        
        // 设置微博appKey和appSecret
        UMSocialManager.default().setPlaform(UMSocialPlatformType.sina, appKey: weiboAppKey, appSecret: weiboAppSecret, redirectURL: redirectURL)
        
        
        // 删除不显示的第三方
        var removePlatform = [Any]()
        
        //        removePlatform.append(convert(type: .sina))               //新浪
        //        removePlatform.append(convert(type: .wechatSession))      //微信聊天
        //        removePlatform.append(convert(type: .wechatTimeLine))     //微信朋友圈
        //        removePlatform.append(convert(type: .wechatFavorite))     //微信收藏
        //        removePlatform.append(convert(type: .QQ))                 //QQ聊天页面
        //        removePlatform.append(convert(type: .qzone))              //qq空间
        removePlatform.append(convert(type: .tencentWb))          //腾讯微博
        removePlatform.append(convert(type: .alipaySession))      //支付宝聊天页面
        removePlatform.append(convert(type: .yixinSession))       //易信聊天页面
        removePlatform.append(convert(type: .yixinTimeLine))      //易信朋友圈
        removePlatform.append(convert(type: .yixinFavorite))      //易信收藏
        removePlatform.append(convert(type: .laiWangSession))     //点点虫（原来往）聊天页面
        removePlatform.append(convert(type: .laiWangTimeLine))    //点点虫动态
        removePlatform.append(convert(type: .sms))                //短信
        removePlatform.append(convert(type: .email))              //邮件
        removePlatform.append(convert(type: .renren))             //人人
        removePlatform.append(convert(type: .facebook))           //Facebook
        removePlatform.append(convert(type: .twitter))            //Twitter
        removePlatform.append(convert(type: .douban))             //豆瓣
        removePlatform.append(convert(type: .kakaoTalk))          //KakaoTalk
        removePlatform.append(convert(type: .pinterest))          //Pinteres
        removePlatform.append(convert(type: .line))               //Line
        removePlatform.append(convert(type: .linkedin))           //领英
        removePlatform.append(convert(type: .flickr))             //Flickr
        removePlatform.append(convert(type: .tumblr))             //Tumblr
        removePlatform.append(convert(type: .instagram))          //Instagram
        removePlatform.append(convert(type: .whatsapp))           //Whatsapp
        removePlatform.append(convert(type: .dingDing))           //钉钉
        removePlatform.append(convert(type: .youDaoNote))         //有道云笔记
        removePlatform.append(convert(type: .everNote))           //印象笔记
        removePlatform.append(convert(type: .googlePlus))         //Google+
        removePlatform.append(convert(type: .pocket))             //Pocket
        removePlatform.append(convert(type: .dropBox))            //dropbox
        removePlatform.append(convert(type: .vKontakte))          //vkontakte
        removePlatform.append(convert(type: .faceBookMessenger))  //FaceBookMessenger
        removePlatform.append(convert(type: .tim))                // Tencent TIM
        
        UMSocialManager.default().removePlatformProvider(withPlatformTypes: removePlatform)
    }
    
    /// Int类型转NSNumber类型
    func convert(type: UMSocialPlatformType) ->NSNumber {
        
        let num = NSNumber.init(value: type.rawValue)
        
        return num
    }
    
    // 支持所有iOS系统
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
        let result = UMSocialManager.default().handleOpen(url, sourceApplication: sourceApplication, annotation: annotation)
        
        if !result {
            // 其他如支付等SDK的回调
        }
        
        return result
    }
    // 注：以上为建议使用的系统openURL回调，且 新浪（完整版） 平台仅支持以上回调。还有以下两种回调方式，如果开发者选取以下回调，也请补充相应的函数调用。
    
    
    // 仅支持iOS9以上系统，iOS8及以下系统不会回调
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
        let result = UMSocialManager.default().handleOpen(url, options: options)
        
        if !result {
            // 其他如支付等SDK的回调
        }
        
        return result
    }
    
    // 2.支持目前所有iOS系统
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
        let result = UMSocialManager.default().handleOpen(url)
        
        if !result {
            // 其他如支付等SDK的回调
        }
        
        return result
    }
}


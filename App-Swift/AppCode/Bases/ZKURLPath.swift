//
//  ZKURLPath_swift.swift
//  WoLiveVideo
//
//  Created by 孤少 on 2017/5/31.
//  Copyright © 2017年 ZhangKuLianDong. All rights reserved.
//  所有的接口都在这里

import Foundation
/// 接口
///
/// - baseServiceAddress: 后台地址
/// - imgBaseServiceAddress: 图片的服务器地址
/// - userLogin: 密码登录
/// - thirdLogin: 第三方登录
/// - logout: 退出登录
/// - userRegister: 用户注册
/// - userProfile: 获取用户信息
/// - versionInfo: 应用版本信息
/// - userEditProfile: 编辑用户信息
/// - userGetFriendList: 获取好友列表
/// - userChangeFriendName: 修改好友昵称
/// - userDelFriend: 删除好友
/// - feedback: 意见反馈
/// - code: 获取验证码
/// - uploadIcon: 上传头像
/// - updatePwd: 修改密码
/// - indexGetVfDicType: 首页频道分类
/// - search: 搜索
/// - historyAndHot: 搜索历史和热门搜索
/// - indexChangeByModule: 换一换
/// - vfGetVfListByType: 频k道资源(首页切换频道等
enum ZKURL : String {
    /// 联调地址
//    case baseServiceAddress   = "http://172.16.2.153:8080/wsp-web-restservice/"
    /// 外网测试
//    case baseServiceAddress   = "http://59.108.59.67:8080/wsp-web-restservice/"
    /// 内网测试
    case baseServiceAddress   = "http://172.16.2.37:8080/wsp-web-restservice/"
    /// 正式地址
//    case baseServiceAddress   = ""
    
// <---------------------------------------------->
    /// 图片服务器IP
    case imgBaseServiceAddress  = "http:111.206.135.50:8080"
// <---------------------------------------------->
    
    //MARK:- 用户注册
    /// 密码登录
    case userLogin              = "mblUser/login"
    /// 第三方登录
    case thirdLogin             = "mblUser/third/login"
    /// 退出登录
    case logout                 = "mblUser/logout"
    /// 用户注册
    case userRegister           = "mblUser/register"
    /// 获取用户信息
    case userProfile            = "mblUser/profile"
    /// 编辑用户信息
    case userEditProfile        = "mblUser/editProfile"
    /// 获取好友列表
    case userGetFriendList      = "mblUser/getFriendList"
    /// 修改好友昵称
    case userChangeFriendName   = "mblUser/changeFriendName"
    /// 删除好友
    case userDelFriend          = "mblUser/delFriend"
    /// 意见反馈
    case feedback               = "mblUser/opinion"
    /// 获取验证码
    case code                   = "mblUser/code"
    /// 上传头像
    case uploadIcon             = "mblUser/uploadHead"
    /// 修改密码
    case updatePwd              = "mblUser/upPass"
    
    // MARK:- 用户信息
    /// 我的信息
    case myComments             = "mblUser/myComments"
    /// 删除我的信息
    case deleteMessage          = "mblUser/delComments"
    /// 应用版本信息
    case versionInfo            = "mblVersion/getVersionInfo"
    /// 获取好友请求列表
    case zk_getFriendRequest    = "mblUser/checkFriendMessage"
    /// 搜索好友
    case zk_searchFriends       = "mblUser/searchFriend"
    /// 接受/拒绝 好友请求
    case zk_acceptFriendReq     = "mblUser/handleFriendAdd"
    /// 添加好友
    case zk_addFriend           = "mblUser/addFriend"
    
    //MARK:- 首页资源
    /// 首页频道分类
    case indexGetVfDicType      = "mblIndex/getVfDicType"
    /// 换一换
    case indexChangeByModule    = "mblIndex/changeByModule" // 换一换
    /// 搜索
    case search                 = "mblVf/getVfByName"
    /// 搜索历史和热门搜索
    case historyAndHot          = "mblVf/getHistoryAndHot"
    
    //MARK:- 频道资源相关
    /// 频道资源
    case vfGetVfListByType      = "mblVf/getVfListByType/v2"
    /// 拿到频道列表, 根据property 0.央视, 1.卫视, 2.地方, -1全部
    case zk_getTVStationList    = "mblLive/getLivesByProperty"
    /// 拿到 对应频道, 对应时间 的 节目列表
    case zk_getPrograms         = "mblLive/getEpgsByLvId"
    /// 根据节目ID, 请求回看节目
    case zk_getLookBackProgram  = "mblLive/getEpgsBackUrl"
    /// 订阅和取消订阅
    case zk_subscribeProgram    = "mblLive/appointEpg"
    /// 获取收藏列表
    case zk_getCollectedList    = "mblCollection/collList"
    /// 获取详情页推荐列表
    case zk_getRecommendList    = "mblVf/getRecommendListByVfTag"
    /// 获取资源详情
    case zk_getResourceDetail   = "mblVf/getVfInfo"
    /// 获取能播放的模型
    case zk_getPlayableModel    = "mblVf/getPlaysListByVf"
    /// 保存历史记录
    case zk_saveHistory         = "mblVf/addHit"
    /// 获取剧集列表
    case zk_getEpsodesList      = "mblVf/getPlaysListIncludeMzByVf"
    /// 获取播放历史记录
    case zk_getHistoryPlay      = "mblUserRecord/getUserRecord"
    /// 收藏 和 取消收藏
    case zk_collectOne          = "mblCollection/saveMyColl"
    /// 获取评论列表
    case zk_getCommentList      = "mblVf/viewComment"
    /// 发表评论
    case zk_sendComment         = "mblVf/addComment"
    /// 获取预约列表
    case zk_getSubscribeList    = "mblLive/getAppointEpgList"
    /// 根据频道ID获取频道详情
    case zk_getStationByID      = "mblLive/getLivesByTvId"
    /// 删除历史记录
    case zk_deleteRecord        = "mblUserRecord/delUserRecord"
    /// 删除收藏
    case zk_deleteCollect       = "mblCollection/cancelMyColls"
    
    // MARK: 包间相关接口
    /// 获取全部包间接口 "包间中"
    case zk_getAllRooms         = "mblRoom/getRoomList"
    /// 创建包间
    case zk_createRoom          = "mblRoom/addRoom"
    /// 获取包间用户
    case zk_getRoomPersons      = "mblRoom/listRoomUser"
    /// 搜索包间
    case zk_searchingRooms      = "mblRoom/searchRoom"
    /// 包间添加成员
    case zk_addMemberInRoom     = "mblRoom/addRoomUser"
    
    // MARK: 竞猜相关
    /// 获取竞猜列表
    case zk_getGuessList        = "mblRoom/getRoomGuessByRoomId"
    /// 创建包间竞猜
    case zk_CreateGuess         = "mblRoom/addRoomGuess"
    /// 参与竞猜接口
    case zk_jionInGuess         = "mblRoom/addGuessUserAnswer"
    /// 获取竞猜详情页竞猜列表
    case zk_getGuessedList      = "mblRoom/getGuessUserAnswerList"
    /// 获取CDNUrl
    case zk_getCDNUrl           = "mblIndex/getPlayVideoURL"

    // MARK:- 畅视接口
    /// 搜索畅视用户数据
    case cs_SearchUserDate      = "mblOrderRelation/search"
    /// 畅视的APP列表
    case orderGetList           = "mblOrder/getList"
    /// 畅视获取短信验证码
    case cs_orderSendSmsCode    = "mblOrder/sendSmsCode"
    /// 短信取号接口
    case cs_orderSmsNumber      = "mblOrder/smsNumber"
    /// 订购/退订
    case cs_orderSmsOrder       = "mblOrder/smsOrder"
    /// 激活
    case cs_orderSmsActive      = "mblOrder/smsActive"
    
    
    // MARK:-
    /// 接口地址
    ///
    /// - Returns: 拼接完的接口 String
    func api() -> String {
        switch self {
        case .baseServiceAddress:
            return self.rawValue
        case .imgBaseServiceAddress:
            assert(false, "api不能拼接图片服务器地址")
            return self.rawValue
        default:break
        }
        return ZKURL.baseServiceAddress.rawValue + self.rawValue
    }
    
    /// 图片的地址
    ///
    /// - Returns: 拼接完的图片地址
    func picture(img: String?) -> String {
        guard let img = img else { return self.rawValue }
        switch self {
        case .baseServiceAddress:
            assert(false, "picture不能拼接接口服务器地址")
            return self.rawValue
        case .imgBaseServiceAddress:
            if img.hasPrefix("http") {
                return img
            }
            return ZKURL.imgBaseServiceAddress.rawValue + img//self.rawValue
        default:
            assert(false, "picture只是用来拼接图片地址的")
            return self.rawValue
        }
    }
    
}

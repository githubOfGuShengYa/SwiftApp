//
//  SYM3U8Player.h
//  AFNTest
//
//  Created by 谷胜亚 on 2017/6/16.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//  基于AVPlayer的自定义播放器

/** 整个流程
 1. 首先得到视频资源的url
 2. 根据得到的url创建AVPlayerItem
 3. 把AVPlayerItem提供给AVPlayer从而创建AVPlayer
 4. 根据AVPlayer创建AVPlayerLayer从而显示视频
 5. AVPlayer来控制视频的播放、暂停、跳转
 6. 播放过程中获取缓存进度播放进度
 7. 视频播放完毕之后的操作, 暂停、重播、还是获取最后一帧图像
 */


#import <UIKit/UIKit.h>



//
///// 播放器将要去执行的操作
//typedef NS_ENUM(NSUInteger, SYPlayerWillToDoType) {
//    /// 播放器将要去执行全屏操作
//    SYPlayerWillToDoFullScreen,
//    /// 播放器将要去执行退出全屏操作
//    SYPlayerWillToDoExitFullScreen,
//};

/// 播放器加载资源状态
typedef NS_ENUM(NSUInteger, SYLoadResourcesState) {
    /// 加载中
    SYLoadResourcesLoading,
    /// 成功
    SYLoadResourcesSuccess,
    /// 失败
    SYLoadResourcesFailed,
};



@class SYM3U8Player;
@protocol SYM3U8PlayerDelegate <NSObject>

/// 该播放器即将取消静音
//- (void)m3u8PlayerWillCancelMute:(SYM3U8Player *)m3u8Player;

/// 全屏按钮点击触发代理回调, 回调该播放器以及 将要实施的操作 -- 全屏或退出全屏
//- (void)m3u8Player:(SYM3U8Player *)m3u8Player willToDo:(SYPlayerWillToDoType)type;

/// 播放器取消静音是否成功 -- 成功切换全屏  失败打开隐藏的幕布
- (void)m3u8Player:(SYM3U8Player *)player cancelMuteSuccess:(BOOL)isSuccess;

@end



/// 加载资源状态回调block
typedef void(^SYLoadResourcesStateBlock)(SYLoadResourcesState loadState);

@interface SYM3U8Player : UIView


#pragma mark <-----------  属性  ----------->

/// 是否静音
@property (nonatomic, assign, getter=isMuted) BOOL mute;

/// 原始frame
@property (nonatomic, assign) CGRect originalFrame;

/// 设置完资源url的回调block
@property (nonatomic, copy, readonly) SYLoadResourcesStateBlock completedHandleBlock;

/// 代理属性
@property (nonatomic, weak) id<SYM3U8PlayerDelegate> delegate;



#pragma mark <-----------  方法  ----------->
/**
 *  设置资源播放url 并获得该资源的第一帧画面
 *
 *  @param url 资源链接url
 *
 *  @param autoPlay 是否视频加载失败之后自动重新加载播放
 *
 *  @param completedHandle 完成设置资源url的回调block
 */
- (void)setupSourceURL:(NSString *)url autoPlayAfterLoadFailed:(BOOL)autoPlay completedHandle:(SYLoadResourcesStateBlock)completedHandle;


/// 更新播放器layer的frame
- (void)updatePlayerLayerFrameWithFrame:(CGRect)frame;


@end

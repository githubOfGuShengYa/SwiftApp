//
//  SYPlayerViewController.m
//  AFNTest
//
//  Created by 谷胜亚 on 2017/6/21.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

#import "SYPlayerViewController.h"
#import "SYM3U8Player.h"
#import <Masonry/Masonry.h>
#import <MediaPlayer/MediaPlayer.h> // 音量调整用到

/// 利用手势改变的状态
typedef NS_ENUM(NSUInteger, SYGesturesChangeType) {
    /// 利用手势改变系统音量
    SYGesturesChangeSystemVolume,
    /// 利用手势改变屏幕亮度
    SYGesturesChangeScreenLight,
};


#define topToolHeight 40 // 顶部工具条的高度
#define bottomToolHeight 40 // 底部工具条的高度
#define beginPlayBtnWidth 30 // 开始播放按钮/全屏按钮的宽度
#define globalAlphaValue 0.4 // 遮板的透明度

#define leastDistance 10 // 最小判定移动距离
#define baseDivisor 480 // 手势移动距离所除的基数 -- 音量和屏幕亮度

@interface SYPlayerViewController ()<SYM3U8PlayerDelegate>
{
    SYM3U8Player *_currentFullScreenPlayer; // 当前全屏的播放器
    
    
    
    
    CGPoint _touchBeginPoint; // 滑动初始点
    CGFloat _lastTimeVoiceValue; // 上次音量值
    BOOL _judgedWhichOperation; // 是否已经判断出哪种操作 -- 音量/亮度/进度
    SYGesturesChangeType _currentType; // 将要改变的类型
    
    CGFloat _beginScreenLight; // 刚开始屏幕的亮度
    
    /// 持有系统音量显示slider
    UISlider *_systemSlider;
}
/// 保存添加的播放器
@property (nonatomic, strong) NSMutableArray *addedPlayers;

#pragma mark <-----------  视图属性  ----------->
@property (nonatomic, strong) UIView *topToolBar; // 上侧工具条
@property (nonatomic, strong) UIView *bottomToolBar; // 下侧工具条
@property (nonatomic, strong) UILabel *titleLabel; // 上侧工具条上的名称label
@property (nonatomic, strong) UIButton *whetherFullScreenBtn; // 全屏按钮
@property (nonatomic, strong) UIButton *beginPlayBtn; // 开始播放按钮


// 用于隐藏工具条
@property (nonatomic, strong) NSTimer *hiddenToolBarTimer;
@end

@implementation SYPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _beginScreenLight = [UIScreen mainScreen].brightness;
    NSLog(@"刚开始屏幕的亮度----->%f", _beginScreenLight);
}

/// 上侧工具条
- (void)createTopToolBar
{
    UIView *topToolBar = [[UIView alloc] init];
    topToolBar.backgroundColor = [UIColor clearColor];
    topToolBar.hidden = YES;
    [self.view addSubview:topToolBar];
    self.topToolBar = topToolBar;
    
    [topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(topToolHeight);
    }];
    
    // 遮板
    UIView *cover = [[UIView alloc] init];
    [topToolBar addSubview:cover];
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = globalAlphaValue;
    
    [cover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
    
    // 返回按钮
    UIButton *goback = [[UIButton alloc] init];
    goback.imageView.contentMode = UIViewContentModeCenter;
    [goback setImage:[UIImage imageNamed:@"返回白色"] forState:UIControlStateNormal];
    [goback addTarget:self action:@selector(gobackClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [topToolBar addSubview:goback];
    [goback mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(topToolBar.mas_centerY);
        make.left.mas_equalTo(0);
        make.width.height.mas_equalTo(30);
    }];
    
    // 视频的名称
    UILabel *videoName = [[UILabel alloc] init];
    self.titleLabel = videoName;
    [topToolBar addSubview:videoName];
    videoName.textColor = [UIColor whiteColor];
    videoName.font = [UIFont systemFontOfSize:13];
    videoName.text = @"这里是视频的标题";
    
    [videoName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(goback.mas_right).mas_offset(10);
        make.centerY.mas_equalTo(topToolBar);
        make.right.mas_equalTo(-15);
    }];
    
    [self.view bringSubviewToFront:topToolBar];
}

/// 创建下侧工具条
- (void)createBottomToolBar
{
    // 下侧工具条
    UIView *bottomToolBar = [[UIView alloc] init];
    bottomToolBar.backgroundColor = [UIColor clearColor];
    bottomToolBar.hidden = YES;
    [self.view addSubview:bottomToolBar];
    self.bottomToolBar = bottomToolBar;
    
    [bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(bottomToolHeight);
    }];
    
    // 遮板
    UIView *cover = [[UIView alloc] init];
    [bottomToolBar addSubview:cover];
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = globalAlphaValue;
    
    [cover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
    
    // 全屏播放按钮
    UIButton *whetherFullScreenBtn = [[UIButton alloc] init];
    [whetherFullScreenBtn setImage:[UIImage imageNamed:@"CDPZoomIn"] forState:UIControlStateNormal];
    [whetherFullScreenBtn setImage:[UIImage imageNamed:@"CDPZoomOut"] forState:UIControlStateSelected];
    [whetherFullScreenBtn addTarget:self action:@selector(whetherFullScreen:) forControlEvents:UIControlEventTouchUpInside];
    whetherFullScreenBtn.imageView.contentMode = UIViewContentModeCenter;
    [bottomToolBar addSubview:whetherFullScreenBtn];
    self.whetherFullScreenBtn = whetherFullScreenBtn;
    
    [whetherFullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(bottomToolBar);
        make.width.mas_equalTo(beginPlayBtnWidth);
        make.height.mas_equalTo(beginPlayBtnWidth);
    }];
    
    
    
    
    // 开始播放按钮
    UIButton *beginPlayBtn = [[UIButton alloc] init];
    [beginPlayBtn setImage:[UIImage imageNamed:@"CDPPlay"] forState:UIControlStateNormal]; // 普通状态为已暂停
    [beginPlayBtn setImage:[UIImage imageNamed:@"CDPPause"] forState:UIControlStateSelected]; // 选中状态为已播放
    [beginPlayBtn addTarget:self action:@selector(beginPlayAction:) forControlEvents:UIControlEventTouchUpInside];
    beginPlayBtn.imageView.contentMode = UIViewContentModeCenter;
    [bottomToolBar addSubview:beginPlayBtn];
    self.beginPlayBtn = beginPlayBtn;
    
    [beginPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(bottomToolBar);
        make.width.mas_equalTo(beginPlayBtnWidth);
        make.height.mas_equalTo(beginPlayBtnWidth);
    }];
    
    [self.view bringSubviewToFront:bottomToolBar];
}

#pragma mark <-----------  按钮的点击事件  ----------->
// 全屏按钮点击事件
- (void)whetherFullScreen:(UIButton *)button
{
    NSLog(@"全屏按钮点击事件");
}

// 开始按钮点击事件
- (void)beginPlayAction:(UIButton *)button
{
    NSLog(@"开始按钮点击事件");
}

- (void)gobackClickAction:(UIButton *)button
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


/**
 *  判断是否隐藏工具条 -- 情况有: 1.刚开始点击播放按钮 2.刚开始拉动滑块 3.由隐藏状态变为显示状态 4.点击全屏按钮
 */
- (void)createHiddenToolBarTimer
{
    self.hiddenToolBarTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hiddenToolBarTimerRunning) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.hiddenToolBarTimer forMode:UITrackingRunLoopMode];
}

static NSInteger lastTime = 0;

- (void)hiddenToolBarTimerRunning
{
    if (lastTime)
    {
        lastTime--;
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            // 1. 让上下的工具条隐藏
            self.bottomToolBar.hidden = YES;
            self.topToolBar.hidden = YES;
        }];
        
        // 停止计时器
        [self.hiddenToolBarTimer invalidate];
        self.hiddenToolBarTimer = nil;
    }
}

- (void)setSourceURLArray:(NSArray *)sourceURLArray
{
    _sourceURLArray = sourceURLArray;
    
    // 循环创建播放器并设置好布局
    for (int i = 0; i < sourceURLArray.count; i++) {
        
        CGRect frame;
        
        if (i == 0) {
            // 第一个播放器全屏
            CGFloat x = 0; CGFloat y = 0;
            CGFloat w = self.view.bounds.size.height;
            CGFloat h = self.view.bounds.size.width;
            frame = CGRectMake(x, y, w, h);
        }else {
            CGFloat w = (self.view.bounds.size.height - 2) / 3;
            CGFloat x = (w + 1) * (i - 1);
            CGFloat h = w * 9 / 16;
            CGFloat y = self.view.bounds.size.width - h;
            frame = CGRectMake(x, y, w, h);
        }
        
        // 创建播放器
        SYM3U8Player *player = [[SYM3U8Player alloc] initWithFrame:frame];
        player.delegate = self;
        player.originalFrame = frame;
        // 除了第一个添加的播放器都静音
        player.mute = i == 0 ? NO : YES;
        [player setupSourceURL:sourceURLArray[i] autoPlayAfterLoadFailed:YES completedHandle:^(SYLoadResourcesState loadState) {
            switch (loadState) {
                case SYLoadResourcesLoading:
                {
                    NSLog(@"1加载中");
                }
                    
                    break;
                    
                case SYLoadResourcesSuccess:
                    NSLog(@"1加载成功");
                    break;
                    
                case SYLoadResourcesFailed:
                {
                    NSLog(@"1加载失败");
                }
                    
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self.view addSubview:player];
        
        // 保存添加的播放器
        [self.addedPlayers addObject:player];
        NSLog(@"添加的播放器%@", player);
    }
    
    _currentFullScreenPlayer = self.addedPlayers.firstObject;
    
    
    [self createTopToolBar];
    [self createBottomToolBar];
}

#pragma mark <-----------  代理方法  ----------->

// 全屏按钮点击触发代理回调, 回调该播放器以及 将要实施的操作 -- 全屏或退出全屏
//- (void)m3u8Player:(SYM3U8Player *)m3u8Player willToDo:(SYPlayerWillToDoType)type
//{
//    if (type == SYPlayerWillToDoFullScreen) { // 准备全屏
//        
//        // 把该播放器视图提到最上层
//        [self.view bringSubviewToFront:m3u8Player];
//        
//        // 获得全屏frame
//        CGRect fullFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//        
//        [m3u8Player updatePlayerLayerFrameWithFrame:fullFrame];
//        
//    }else if (type == SYPlayerWillToDoExitFullScreen) { // 准备退出全屏
//        
//        [m3u8Player updatePlayerLayerFrameWithFrame:m3u8Player.originalFrame];
//        
//    }
//}

// 该播放器即将取消静音
//- (void)m3u8PlayerWillCancelMute:(SYM3U8Player *)m3u8Player
//{
//    // 遍历保存的播放器数组
//    for (SYM3U8Player *player in self.addedPlayers) {
//        if (![player isEqual:m3u8Player]) {
//            // 如果不是取消静音的播放器 就把该播放器静音
//            player.mute = YES;
//        }
//    }
//    
//    // 使用动画的形式切换播放器
//    CGRect smallScreen = m3u8Player.originalFrame;
//    CGRect fullScreen = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//    [UIView animateWithDuration:0.3 animations:^{
//        // 让小屏播放器切换为全屏  让全屏的播放器切换为小屏
////        m3u8Player.frame = fullScreen;
//        [m3u8Player updatePlayerLayerFrameWithFrame:fullScreen];
////        _currentFullScreenPlayer.frame = smallScreen;
//        [_currentFullScreenPlayer updatePlayerLayerFrameWithFrame:smallScreen];
//        [self.view sendSubviewToBack:m3u8Player];
//    } completion:^(BOOL finished) {
//        if (finished) {
//            _currentFullScreenPlayer.originalFrame = smallScreen;
//            _currentFullScreenPlayer = m3u8Player;
//        }
//    }];
//}

// 播放器取消静音是否成功 -- 成功切换全屏  失败打开隐藏的幕布
- (void)m3u8Player:(SYM3U8Player *)player cancelMuteSuccess:(BOOL)isSuccess
{
    if (isSuccess) {
        // 遍历保存的播放器数组
        for (SYM3U8Player *newPlayer in self.addedPlayers) {
            if (![newPlayer isEqual:player]) {
                // 如果不是取消静音的播放器 就把该播放器静音
                newPlayer.mute = YES;
            }
        }
        
        // 使用动画的形式切换播放器
        CGRect smallScreen = player.originalFrame;
        CGRect fullScreen = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [UIView animateWithDuration:0.3 animations:^{
            // 让小屏播放器切换为全屏  让全屏的播放器切换为小屏
            [player updatePlayerLayerFrameWithFrame:fullScreen];
            [_currentFullScreenPlayer updatePlayerLayerFrameWithFrame:smallScreen];
            [self.view sendSubviewToBack:player];
            
        } completion:^(BOOL finished) {
            if (finished) {
                _currentFullScreenPlayer.originalFrame = smallScreen;
                _currentFullScreenPlayer = player;
            }
        }];
    }else {
        // 1. 判断此时上下工具条是否是隐藏状态
        if (lastTime) // 表示未隐藏
        {
            [UIView animateWithDuration:0.5 animations:^{
                
                self.bottomToolBar.hidden = YES;
                self.topToolBar.hidden = YES;
            }];
            
            // 让lastTime清零
            lastTime = 0;
            
            // 关闭计时器
            [self.hiddenToolBarTimer invalidate];
            self.hiddenToolBarTimer = nil;
        }
        else // 已隐藏
        {
            [UIView animateWithDuration:0.5 animations:^{
                
                self.bottomToolBar.hidden = NO;
                self.topToolBar.hidden = NO;
            }];
            
            // 让lastTime=3
            lastTime = 3;
            
            // 打开计时器
            [self createHiddenToolBarTimer];
        }
    }
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES]; // 变为全屏
//}
//
//
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES]; // 变为全屏
//}
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
////    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES]; // 变为全屏
//    [self dismissViewControllerAnimated:YES completion:^{
////    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES]; // 变为全屏
//    }];
//}
//
//- (BOOL)shouldAutorotate
//{
//    return NO;
//}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAll;
//}

//// 同时支持Portrait和Landscape方向，但想优先显示Landscape方向，那软件启动的时候就会先显示Landscape，在手机切换旋转方向的时候仍然可以在Portrait和Landscape之间切换；
//// 返回现在正在显示的用户界面方向
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationLandscapeRight;
//};


#pragma mark <-----------  测试  ----------->

- (BOOL)shouldAutorotate

{
    
    return NO;
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations

{
    
    return UIInterfaceOrientationMaskLandscape;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation

{
    
    return UIInterfaceOrientationLandscapeRight;
    
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark <-----------  Get / Set  ----------->
- (NSMutableArray *)addedPlayers
{
    if (!_addedPlayers) {
        _addedPlayers = [NSMutableArray array];
    }
    
    return _addedPlayers;
}


#pragma mark 进度控制/音量控制/亮度控制, 进行相应计算
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@触摸开始", self);

    // 1. 判断如果多个手指点击则不作反应
    UITouch *touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1)
    {
        return;
    }

    // 3. 触摸开始的时候, 初始化一些值
    _judgedWhichOperation = NO;
    
    _touchBeginPoint = [touches.anyObject locationInView:self.view];
    
    if (_systemSlider == nil) {
        MPVolumeView  *volumeView = [[MPVolumeView alloc] init];
        
        for (UIView *view in volumeView.subviews)
        {
            if ([view.class.description isEqualToString:@"MPVolumeSlider"])
            {
                _systemSlider = (UISlider *)view;
                break;
            }
        }
    }
    NSObject *ob = [_systemSlider valueForKeyPath:@"volumeController"];
    _lastTimeVoiceValue = [[ob valueForKey:@"volumeValue"] floatValue];
    NSLog(@"+++++++++++++系统当前音量%f", _lastTimeVoiceValue);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 1. 判断如果多个手指点击则不作反应
    UITouch *touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1)
    {
        return;
    }

    // 3. 如果移动的距离太小, 则判定为未移动
    CGPoint tempPoint = [touches.anyObject locationInView:self.view];
    if (fabs(tempPoint.x - _touchBeginPoint.x) < leastDistance && fabs(tempPoint.y - _touchBeginPoint.y) < leastDistance)
    {
        NSLog(@"移动距离太小判定为未移动");
        return;
    }
    
    // 如果还没有判断出该手势使用什么操作, 就进行判断
    if (!_judgedWhichOperation) // 还未判断出
    {
        // 1. 计算出当前滑动到的点与初始值连线的tan(正切 -- 对边/临边)值
        float tan = fabs(tempPoint.y - _touchBeginPoint.y) / fabs(tempPoint.x - _touchBeginPoint.x);
        
        // 2. 判断正切值
        if (tan > sqrt(3)) // 滑动角度大于60度的时候, 表示音量/亮度
        {
            // 屏幕左侧表示亮度
            if (_touchBeginPoint.x < self.view.bounds.size.width / 2)
            {
                _currentType = SYGesturesChangeScreenLight;
                NSLog(@"--------------------屏幕亮度(2)---------%@,%@",NSStringFromCGPoint(_touchBeginPoint),NSStringFromCGPoint(tempPoint));
            }
            else // 屏幕右侧表示音量
            {
                _currentType = SYGesturesChangeSystemVolume;
                NSLog(@"--------------------系统音量(3)---------%@,%@",NSStringFromCGPoint(_touchBeginPoint),NSStringFromCGPoint(tempPoint));
            }
            
            _judgedWhichOperation = YES;
        }
        else // 在30度到60度之间的暂时不做任何操作
        {
            return;
        }
    }
    
    switch (_currentType)
    {
        case SYGesturesChangeScreenLight: // 改变屏幕的亮度
        {
            // 1. 获取当前屏幕的亮度
            CGFloat currentLight = [UIScreen mainScreen].brightness;
            
            NSLog(@"当前屏幕亮度%f",currentLight);
            
            // 2. 根据
            CGFloat result = (_touchBeginPoint.y - tempPoint.y) / (baseDivisor * 10) + currentLight;
            
            // 3. 更改屏幕亮度
            [UIScreen mainScreen].brightness = result < 0 ? 0 : result > 1 ? 1 : result;
        }
            break;
            
        case SYGesturesChangeSystemVolume: // 改变系统的音量
        {
            CGFloat result = (_touchBeginPoint.y - tempPoint.y) / baseDivisor / 4 + _lastTimeVoiceValue;
            _lastTimeVoiceValue = result;
            _systemSlider.value = result < 0 ? 0 : result > 1 ? 1 : result ;
        }
            break;
            
        default:
            break;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

}

-  (void)dealloc
{
    [UIScreen mainScreen].brightness = _beginScreenLight;
    NSLog(@"多屏控制器被销毁");
}

@end

//
//  SYM3U8Player.m
//  AFNTest
//
//  Created by 谷胜亚 on 2017/6/16.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

#import "SYM3U8Player.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
//#import <MediaPlayer/MediaPlayer.h> // 音量调整用到


#define topToolHeight 40 // 顶部工具条的高度
#define bottomToolHeight 40 // 底部工具条的高度
//#define beginPlayBtnWidth 30 // 开始播放按钮/全屏按钮的宽度
//#define globalAlphaValue 0.4 // 遮板的透明度

//#define leastDistance 10 // 最小判定移动距离
//#define baseDivisor 480 // 手势移动距离所除的基数 -- 音量和屏幕亮度

@interface SYM3U8Player ()<UIGestureRecognizerDelegate>
{
    NSString *_url; // 资源url
    
    BOOL _autoPlay; // 播放失败之后重新自动播放
    
    CGRect _initFrame; // 初始化时frame
    
//    CGPoint _touchBeginPoint; // 滑动初始点
//    CGFloat _lastTimeVoiceValue; // 上次音量值
//    BOOL _judgedWhichOperation; // 是否已经判断出哪种操作 -- 音量/亮度/进度
//    SYGesturesChangeType _currentType; // 将要改变的类型
//    
//    CGFloat _beginScreenLight; // 刚开始屏幕的亮度
//    
//    /// 持有系统音量显示slider
//    UISlider *_systemSlider;
}

/// 播放器 (相应层) -- 相当于MVC中的Controller
@property (nonatomic, strong) AVPlayer *myPlayer;

/// 信息源 (信息层) -- 相当于MVC中的Model
@property (nonatomic, strong) AVPlayerItem *myPlayerItem;

/// 播放图层 (显示层) -- 相当于MVC中View
@property (nonatomic, strong) AVPlayerLayer *myPlayerLayer;

/// 设置完资源url的回调block
@property (nonatomic, copy) SYLoadResourcesStateBlock completedHandleBlock;

// 用于隐藏工具条
//@property (nonatomic, strong) NSTimer *hiddenToolBarTimer;

/// 是否正在播放
@property (nonatomic, assign) BOOL isPlaying;

#pragma mark <-----------  视图属性  ----------->
//@property (nonatomic, strong) UIView *topToolBar; // 上侧工具条
@property (nonatomic, strong) UIView *touchView; // 用于接收手势的view
//@property (nonatomic, strong) UIView *bottomToolBar; // 下侧工具条
//@property (nonatomic, strong) UIButton *whetherFullScreenBtn; // 全屏按钮
//@property (nonatomic, strong) UIButton *beginPlayBtn; // 开始播放按钮

@end
@implementation SYM3U8Player

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _initFrame = frame;
        
        // 创建AVPlayer
        AVPlayer *player = [[AVPlayer alloc] init];
        self.myPlayer = player;
        
        // 由于AVPlayer本身并不能显示视频, 显示视频的是AVPlayerLayer, 需要把AVPlayerLayer添加到某个layer上显示
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        playerLayer.frame = self.bounds;
        
        // 设置视频显示模式
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect; // 是按原视频比例显示，是竖屏的就显示出竖屏的，两边留黑

//        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; // 是以原比例拉伸视频，直到两边屏幕都占满，但视频内容有部分就被切割了
//        
//        playerLayer.videoGravity = AVLayerVideoGravityResize; // 是拉伸视频内容达到边框占满，但不按原比例拉伸，这里明显可以看出宽度被拉伸了
        
        [self.layer addSublayer:playerLayer];
        self.myPlayerLayer = playerLayer;
        
        // 设置背景颜色为黑色
        UIImage *image = [UIImage imageNamed:@"视频播放图"];
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.f);
        [image drawInRect:self.bounds];
        UIImage *lastImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.backgroundColor = [UIColor colorWithPatternImage:lastImage];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 0.5;
        
        [self setupNotification];
        
//        [self createTopToolBar];
        [self createCenterTouchView];
//        [self createBottomToolBar];
    }
    
    return self;
}


// 更新播放器layer的frame
- (void)updatePlayerLayerFrameWithFrame:(CGRect)frame
{
//    [UIView animateWithDuration:0.3 animations:^{
        self.frame = frame;
        self.myPlayerLayer.frame = self.bounds;
//    }];
}


#pragma mark <-----------  视图处理  ----------->
///// 上侧工具条
//- (void)createTopToolBar
//{
//    UIView *topToolBar = [[UIView alloc] init];
//    topToolBar.backgroundColor = [UIColor clearColor];
//    topToolBar.hidden = YES;
//    [self addSubview:topToolBar];
//    self.topToolBar = topToolBar;
//    
//    [topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(0);
//        make.top.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//        make.height.mas_equalTo(topToolHeight);
//    }];
//    
//    // 遮板
//    UIView *cover = [[UIView alloc] init];
//    [topToolBar addSubview:cover];
//    cover.backgroundColor = [UIColor blackColor];
//    cover.alpha = globalAlphaValue;
//    
//    [cover mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.bottom.right.mas_equalTo(0);
//    }];
//    
//    // 视频的名称
//    UILabel *videoName = [[UILabel alloc] init];
//    [topToolBar addSubview:videoName];
//    videoName.textColor = [UIColor whiteColor];
//    videoName.font = [UIFont systemFontOfSize:13];
//    videoName.text = @"这里是视频的标题";
//    
//    [videoName mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(5);
//        make.centerY.mas_equalTo(topToolBar);
//        make.right.mas_equalTo(-5);
//        make.top.mas_equalTo(5);
//    }];
//}

/// 创建中间接收手势的view
- (void)createCenterTouchView
{
    UIView *touchView = [[UIView alloc] init];
    touchView.backgroundColor = [UIColor clearColor];
    [self addSubview:touchView];
    self.touchView = touchView;
    
    [touchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topToolHeight);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(-bottomToolHeight);
        make.right.mas_equalTo(0);
    }];
    
    [self settingGesture];
}

#pragma mark 添加手势
//static NSInteger lastTime = 0;

- (void)settingGesture
{
    // 单指双击
    UITapGestureRecognizer *twiceTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twiceTouchAction:)];
    twiceTouch.numberOfTapsRequired = 2; // 点按几次
    twiceTouch.numberOfTouchesRequired = 1; // 手指数
    twiceTouch.delegate = self;
    [self.touchView addGestureRecognizer:twiceTouch];
    
    // 单指单击
    UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTouchAction:)];
    singleTouch.numberOfTapsRequired = 1; // 点按几次
    singleTouch.numberOfTouchesRequired = 1; // 手指数
    singleTouch.delegate = self;
    [self.touchView addGestureRecognizer:singleTouch];
    
    // 当同时存在单击与双击的的时候，需要加上这句话，否则会先调用单击事件然后调用双击事件
    [singleTouch requireGestureRecognizerToFail:twiceTouch];
    
    // 平移手势
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
//    
//    [self.touchView addGestureRecognizer:pan];
}

/// 双击
- (void)twiceTouchAction:(UITapGestureRecognizer *)gesture
{
    NSLog(@"双击");
}

/// 单击
- (void)singleTouchAction:(UITapGestureRecognizer *)gesture
{
    if (self.isMuted == YES) { // 如果是静音状态, 让该播放器取消静音
        self.mute = NO; // 此时不是静音状态
//        if (self.delegate && [self.delegate respondsToSelector:@selector(m3u8PlayerWillCancelMute:)]) {
//            [self.delegate m3u8PlayerWillCancelMute:self];
//        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(m3u8Player:cancelMuteSuccess:)]) {
            [self.delegate m3u8Player:self cancelMuteSuccess:YES];
        }
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(m3u8Player:cancelMuteSuccess:)]) {
        [self.delegate m3u8Player:self cancelMuteSuccess:NO];
    }
    
    
//    // 1. 判断此时上下工具条是否是隐藏状态
//    if (lastTime) // 表示未隐藏
//    {
//        [UIView animateWithDuration:0.5 animations:^{
//            
//            self.bottomToolBar.hidden = YES;
//            self.topToolBar.hidden = YES;
//        }];
//        
//        // 让lastTime清零
//        lastTime = 0;
//        
//        // 关闭计时器
//        [self.hiddenToolBarTimer invalidate];
//        self.hiddenToolBarTimer = nil;
//    }
//    else // 已隐藏
//    {
//        [UIView animateWithDuration:0.5 animations:^{
//            
//            self.bottomToolBar.hidden = NO;
//            self.topToolBar.hidden = NO;
//        }];
//        
//        // 让lastTime=5
//        lastTime = 5;
//        
//        // 打开计时器
//        [self createHiddenToolBarTimer];
//    }
}

// 平移手势
- (void)panAction:(UIPanGestureRecognizer *)gesture
{
//    // 只有全屏状态才可以改变音量 / 亮度
//    if (!self.whetherFullScreenBtn.isSelected) { // 非全屏
//        return;
//    }
//    
//    CGPoint point = [gesture translationInView:self.touchView];
//    
//    NSLog(@"%@", NSStringFromCGPoint(point));
    
    //    sender.view.transform = CGAffineTransformMake(1, 0, 0, 1, point.x, point.y);
    
    //平移一共两种移动方式
    //第一种移动方法:每次移动都是从原来的位置移动
    //    sender.view.transform = CGAffineTransformMakeTranslation(point.x, point.y);
    
    //第二种移动方式:以上次的位置为标准(移动方式 第二次移动加上第一次移动量)
//    gesture.view.transform = CGAffineTransformTranslate(sender.view.transform, point.x, point.y);
    //增量置为o
//    [sender setTranslation:CGPointZero inView:sender.view];
    
//    _testView.backgroundColor = [UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:1];
}

///**
// *  判断是否隐藏工具条 -- 情况有: 1.刚开始点击播放按钮 2.刚开始拉动滑块 3.由隐藏状态变为显示状态 4.点击全屏按钮
// */
//- (void)createHiddenToolBarTimer
//{
//    self.hiddenToolBarTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hiddenToolBarTimerRunning) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.hiddenToolBarTimer forMode:UITrackingRunLoopMode];
//}
//
//- (void)hiddenToolBarTimerRunning
//{
//    if (lastTime)
//    {
//        lastTime--;
//    }
//    else
//    {
//        [UIView animateWithDuration:0.5 animations:^{
//            
//            // 1. 让上下的工具条隐藏
//            self.bottomToolBar.hidden = YES;
//            self.topToolBar.hidden = YES;
//        }];
//        
//        // 停止计时器
//        [self.hiddenToolBarTimer invalidate];
//        self.hiddenToolBarTimer = nil;
//    }
//}

///// 创建下侧工具条
//- (void)createBottomToolBar
//{
//    // 下侧工具条
//    UIView *bottomToolBar = [[UIView alloc] init];
//    bottomToolBar.backgroundColor = [UIColor clearColor];
//    bottomToolBar.hidden = YES;
//    [self addSubview:bottomToolBar];
//    self.bottomToolBar = bottomToolBar;
//    
//    [bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(0);
//        make.bottom.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//        make.height.mas_equalTo(bottomToolHeight);
//    }];
//    
//    // 遮板
//    UIView *cover = [[UIView alloc] init];
//    [bottomToolBar addSubview:cover];
//    cover.backgroundColor = [UIColor blackColor];
//    cover.alpha = globalAlphaValue;
//    
//    [cover mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.bottom.right.mas_equalTo(0);
//    }];
//    
//    // 全屏播放按钮
//    UIButton *whetherFullScreenBtn = [[UIButton alloc] init];
//    [whetherFullScreenBtn setImage:[UIImage imageNamed:@"CDPZoomIn"] forState:UIControlStateNormal];
//    [whetherFullScreenBtn setImage:[UIImage imageNamed:@"CDPZoomOut"] forState:UIControlStateSelected];
//    [whetherFullScreenBtn addTarget:self action:@selector(whetherFullScreen:) forControlEvents:UIControlEventTouchUpInside];
//    whetherFullScreenBtn.imageView.contentMode = UIViewContentModeCenter;
//    [bottomToolBar addSubview:whetherFullScreenBtn];
//    self.whetherFullScreenBtn = whetherFullScreenBtn;
//    
//    [whetherFullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(0);
//        make.centerY.mas_equalTo(bottomToolBar);
//        make.width.mas_equalTo(beginPlayBtnWidth);
//        make.height.mas_equalTo(beginPlayBtnWidth);
//    }];
//    
//    
//    
//    
//    // 开始播放按钮
//    UIButton *beginPlayBtn = [[UIButton alloc] init];
//    [beginPlayBtn setImage:[UIImage imageNamed:@"CDPPlay"] forState:UIControlStateNormal]; // 普通状态为已暂停
//    [beginPlayBtn setImage:[UIImage imageNamed:@"CDPPause"] forState:UIControlStateSelected]; // 选中状态为已播放
//    [beginPlayBtn addTarget:self action:@selector(beginPlayAction:) forControlEvents:UIControlEventTouchUpInside];
//    beginPlayBtn.imageView.contentMode = UIViewContentModeCenter;
//    [bottomToolBar addSubview:beginPlayBtn];
//    self.beginPlayBtn = beginPlayBtn;
//
//    [beginPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(0);
//        make.centerY.mas_equalTo(bottomToolBar);
//        make.width.mas_equalTo(beginPlayBtnWidth);
//        make.height.mas_equalTo(beginPlayBtnWidth);
//    }];
//    
//}

//#pragma mark <-----------  按钮的点击事件  ----------->
//// 全屏按钮点击事件
//- (void)whetherFullScreen:(UIButton *)button
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(m3u8Player:willToDo:)]) {
//        [self.delegate m3u8Player:self willToDo:button.isSelected ? SYPlayerWillToDoExitFullScreen : SYPlayerWillToDoFullScreen]; // 准备全屏
//        
//        button.selected = !button.selected;
//        
//        if (!button.isSelected) {
//            [UIView animateWithDuration:0.3 animations:^{
////                [UIScreen mainScreen].brightness = _beginScreenLight;
//            }];
//        }
//    }
//}
//
//// 开始按钮点击事件
//- (void)beginPlayAction:(UIButton *)button
//{
//    // 如果按钮此时是选中状态YES -- 图片是等待暂停 则 isPlaying要变为NO
//    self.isPlaying = !button.isSelected;
//}


#pragma mark <-----------  播放器播放加载播放资源方法  ----------->
- (void)setupSourceURL:(NSString *)url autoPlayAfterLoadFailed:(BOOL)autoPlay completedHandle:(SYLoadResourcesStateBlock)completedHandle
{
    _url = url;
    _autoPlay = autoPlay;
    
    self.completedHandleBlock = completedHandle;
    
    [self callbackCompletedHandleBlockWithType:SYLoadResourcesLoading];
    
    // 设置资源url
    [self replacePlayerItemBySourceURL:url];
    
    // 设置初始化时是否是静音状态
//    self.myPlayer.volume = self.isMuted ? 0.0 : 1.0;
}

/**
 *  替换AVPlayer的AVPlayerItem属性
 *
 *  @param url 资源链接url
 */
- (void)replacePlayerItemBySourceURL:(NSString *)url
{
    
    // 把原来的KVO观察者清除
    [self observeDelete];
    
    // 首先获得一个url之后创建AVPlayerItem
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
    self.myPlayerItem = playerItem;
    
    // 注意: 由于初始化item之后其属性并不是马上就可以使用的, 所有和网络扯上关系的都会需要时间去加载, 因此需要设置观察者来观察其属性何时可以使用
    // AVPlayerItem的属性需要status值为ReadyToPlay的时候才可以使用 -- 观察status属性
    // 设置监视KVO
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew context:nil];
    
    
    
    
    // 替换掉AVPlayerItem
    [self.myPlayer replaceCurrentItemWithPlayerItem:self.myPlayerItem];
}

// 设置是否静音
- (void)setMute:(BOOL)mute
{
    _mute = mute;
    
    if (mute) { // 如果静音
        
        self.myPlayer.volume = 0.0;
        NSLog(@"%@静音", self);
        
    }else { // 不静音
        
        self.myPlayer.volume = 1.0;
        NSLog(@"%@取消静音", self);
        
    }
}


#pragma mark <-----------  观察者方法  ----------->
// 观察者属性变化之后调用该方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    // 把object转化为AVPlayerItem对象
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    // 判断观察的对象时哪个
    if ([keyPath isEqualToString:@"status"]) { // 状态
        
        // 获取播放状态
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        
        // 判断状态类型
        switch (status) {
            case AVPlayerStatusReadyToPlay: // 准备播放
            {
                // 获取视频的长度
                CMTime duration = playerItem.duration;
                
                if (duration.flags == 17) { // 表示不确定值 该枚举包含值为2、4、8的选项
                    NSLog(@"没有时间数据");
                }else { // 有确定的时间
                    CGFloat durationTime = CMTimeGetSeconds(duration);
                    NSLog(@"%f", durationTime);
                    
                    // 设置视频的时间
                }
                
                // 开始播放
                [self.myPlayer play];
                self.isPlaying = YES;
                
                // 回到播放状态
                [self callbackCompletedHandleBlockWithType:SYLoadResourcesSuccess];
            }
                break;
                
            case AVPlayerStatusFailed: // 失败
            {
                [self callbackCompletedHandleBlockWithType:SYLoadResourcesFailed];
            }
                break;
                
            case AVPlayerStatusUnknown: // 未知
                
                break;
                
            default:
                break;
        }
        
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) { // 缓存进度
//        NSLog(@"缓冲进度");
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        NSLog(@"--------------缓冲空了");
    }else if ([keyPath isEqualToString:@"playbackBufferFull"]) {
        NSLog(@"--------------缓冲满了");
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) // AVPlayerItem的视频播放因为各种情况停止的时候
    {
        // 1. 暂停播放 2.自定义等待播放动画开始运行
        NSLog(@"------------>因为某些原因播放停止");
        if (_isPlaying) // 播放状态
        {
            [self.myPlayer play];
        }
        
    }else if ([keyPath isEqualToString:@"presentationSize"]) // 获取到视频的大小的时候调用
    {
        CGSize videoSize = self.myPlayer.currentItem.presentationSize; // 视频的宽度和高度
        
        NSLog(@"%@",NSStringFromCGSize(videoSize));
        
    }else {
        NSLog(@"++++++++++++++++++++");
    }
}

#pragma mark <-----------  设置AVPlayer通知  ----------->
- (void)setupNotification
{
    // 项目的当前时间已经改变了
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentTimeChanged:) name:AVPlayerItemTimeJumpedNotification object:nil];
    
    // 已经播放到结束时间
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playToEndSuccessed:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    // 播放到结束时间失败
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playToEndFailed:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    
    // 媒体没有及时赶到继续播放 -- 缓冲没有在规定时间到达可以播放的程度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStalled:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    
    // 一个新的访问日志条目已被添加
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newAccessLogAdd:) name:AVPlayerItemNewAccessLogEntryNotification object:nil];
    
    // 一个新的错误日志条目已被添加
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newErrorLogAdd:) name:AVPlayerItemNewErrorLogEntryNotification object:nil];
}

// 项目的当前时间已经改变了
- (void)currentTimeChanged:(NSNotification *)not
{
//    NSLog(@"%@项目的当前时间已经改变了",NSStringFromSelector(_cmd));
}

// 已经播放到结束时间
- (void)playToEndSuccessed:(NSNotification *)not
{
    NSLog(@"%@已经播放到结束时间",NSStringFromSelector(_cmd));
}

// 播放到结束时间失败
- (void)playToEndFailed:(NSNotification *)not
{
    NSLog(@"%@播放到结束时间失败",NSStringFromSelector(_cmd));
    [self callbackCompletedHandleBlockWithType:SYLoadResourcesFailed];
}

// 媒体没有及时赶到继续播放 -- 缓冲没有在规定时间到达可以播放的程度
- (void)playbackStalled:(NSNotification *)not
{
    NSLog(@"%@媒体没有及时赶到继续播放 -- 缓冲没有在规定时间到达可以播放的程度",NSStringFromSelector(_cmd));
    [self callbackCompletedHandleBlockWithType:SYLoadResourcesFailed];
}

// 一个新的访问日志条目已被添加
- (void)newAccessLogAdd:(NSNotification *)not
{
//    NSLog(@"%@一个新的访问日志条目已被添加",NSStringFromSelector(_cmd));
}

// 一个新的错误日志条目已被添加
- (void)newErrorLogAdd:(NSNotification *)notic
{
//    NSLog(@"%@一个新的错误日志条目已被添加",NSStringFromSelector(_cmd));
}

#pragma mark <-----------  调用block  ----------->
- (void)callbackCompletedHandleBlockWithType:(SYLoadResourcesState)state
{
    // 判断状态是否是失败状态
    if (state == SYLoadResourcesFailed) {
        if (_autoPlay) {
            // 判断是否是播放错误之后自动加载播放
            [self setupSourceURL:_url autoPlayAfterLoadFailed:_autoPlay completedHandle:self.completedHandleBlock];
        }
    }
    
    
    if (self.completedHandleBlock) {
        self.completedHandleBlock(state);
    }
}

#pragma mark <-----------  该类销毁方法  ----------->
- (void)dealloc
{
    [self observeDelete];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"SYM3U8Player被销毁");
}

- (void)observeDelete
{
    if (self.myPlayerItem) {
        // 移除观察者对象
        [self.myPlayerItem removeObserver:self forKeyPath:@"status"];
        [self.myPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.myPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.myPlayerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
        [self.myPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [self.myPlayerItem removeObserver:self forKeyPath:@"presentationSize"];
        
        // 移除AVPlayerItem
        [self.myPlayer replaceCurrentItemWithPlayerItem:nil];
    }
}

- (void)setIsPlaying:(BOOL)isPlaying
{
    _isPlaying = isPlaying;
    
    // 同时设置播放器的播放按钮的显示状态 -- 正在播放状态按钮显示selected图片
//    self.beginPlayBtn.selected = isPlaying;
    
    if (isPlaying) { // 如果将要变为播放状态
        [self.myPlayer play];
    }else {
        [self.myPlayer pause];
    }
}

//#pragma mark 进度控制/音量控制/亮度控制, 进行相应计算
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"%@触摸开始", self);
//    // 只有全屏状态才可以改变音量 / 亮度
//    if (self.whetherFullScreenBtn.isSelected) { // 全屏
//        
//        // 0. 让定时器停止
////        [self.hiddenToolBarTimer invalidate];
////        self.hiddenToolBarTimer = nil;
//        
//        // 让工具条显示出来
//        self.bottomToolBar.hidden = NO;
//        self.topToolBar.hidden = NO;
//        
//        // 1. 判断如果多个手指点击则不作反应
//        UITouch *touch = (UITouch *)touches.anyObject;
//        if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1)
//        {
//            return;
//        }
//        
//        // 2. 判断点击的是否是本视图, 如果不是则不作反应
//        if (![[(UITouch *)touches.anyObject view] isEqual:self.touchView])
//        {
//            return; //  && ![[(UITouch *)touches.anyObject view] isEqual:self]
//        }
////        [super touchesBegan:touches withEvent:event];
//        
//        // 3. 触摸开始的时候, 初始化一些值
//        _judgedWhichOperation = NO;
//
//        _touchBeginPoint = [touches.anyObject locationInView:self];
//        
//        _beginScreenLight = [UIScreen mainScreen].brightness;
//        NSLog(@"刚开始屏幕的亮度----->%f", _beginScreenLight);
//        
//        if (_systemSlider == nil) {
//            MPVolumeView  *volumeView = [[MPVolumeView alloc] init];
//            
//            for (UIView *view in volumeView.subviews)
//            {
//                if ([view.class.description isEqualToString:@"MPVolumeSlider"])
//                {
//                    _systemSlider = (UISlider *)view;
//                    break;
//                }
//            }
//        }
//        NSObject *ob = [_systemSlider valueForKeyPath:@"volumeController"];
//        _lastTimeVoiceValue = [[ob valueForKey:@"volumeValue"] floatValue];
//        NSLog(@"+++++++++++++系统当前音量%f", _lastTimeVoiceValue);
//    }
//}
//
//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    // 只有全屏状态才可以改变音量 / 亮度
//    if (!self.whetherFullScreenBtn.isSelected) { // 非全屏
//        return;
//    }
//    
//    // 1. 判断如果多个手指点击则不作反应
//    UITouch *touch = (UITouch *)touches.anyObject;
//    if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1)
//    {
//        return;
//    }
//    
//    // 2. 判断点击的是否是本视图, 如果不是则不作反应
//    if (![[(UITouch *)touches.anyObject view] isEqual:self.touchView])
//    {
//        return; //  && ![[(UITouch *)touches.anyObject view] isEqual:self]
//    }
////    [super touchesMoved:touches withEvent:event];
//    
//    // 3. 如果移动的距离太小, 则判定为未移动
//    CGPoint tempPoint = [touches.anyObject locationInView:self];
//    if (fabs(tempPoint.x - _touchBeginPoint.x) < leastDistance && fabs(tempPoint.y - _touchBeginPoint.y) < leastDistance)
//    {
//        return;
//    }
//    
//    // 如果还没有判断出该手势使用什么操作, 就进行判断
//    if (!_judgedWhichOperation) // 还未判断出
//    {
//        // 1. 计算出当前滑动到的点与初始值连线的tan(正切 -- 对边/临边)值
//        float tan = fabs(tempPoint.y - _touchBeginPoint.y) / fabs(tempPoint.x - _touchBeginPoint.x);
//        
//        // 2. 判断正切值
//        if (tan > sqrt(3)) // 滑动角度大于60度的时候, 表示音量/亮度
//        {
//            // 屏幕左侧表示亮度
//            if (_touchBeginPoint.x < self.bounds.size.width / 2)
//            {
//                _currentType = SYGesturesChangeScreenLight;
//                NSLog(@"--------------------屏幕亮度(2)---------%@,%@",NSStringFromCGPoint(_touchBeginPoint),NSStringFromCGPoint(tempPoint));
//            }
//            else // 屏幕右侧表示音量
//            {
//                _currentType = SYGesturesChangeSystemVolume;
//                NSLog(@"--------------------系统音量(3)---------%@,%@",NSStringFromCGPoint(_touchBeginPoint),NSStringFromCGPoint(tempPoint));
//            }
//            
//            _judgedWhichOperation = YES;
//        }
//        else // 在30度到60度之间的暂时不做任何操作
//        {
//            return;
//        }
//    }
//    
//    switch (_currentType)
//    {
//        case SYGesturesChangeScreenLight: // 改变屏幕的亮度
//        {
//            // 1. 获取当前屏幕的亮度
//            CGFloat currentLight = [UIScreen mainScreen].brightness;
//            
//            NSLog(@"当前屏幕亮度%f",currentLight);
//            
//            // 2. 根据
//            CGFloat result = (_touchBeginPoint.y - tempPoint.y) / (baseDivisor * 10) + currentLight;
//            
//            // 3. 更改屏幕亮度
//            [UIScreen mainScreen].brightness = result < 0 ? 0 : result > 1 ? 1 : result;
//        }
//            break;
//            
//        case SYGesturesChangeSystemVolume: // 改变系统的音量
//        {
////            MPVolumeView  *volumeView = [[MPVolumeView alloc] init];
////            UISlider *slider;
////            for (UIView *view in volumeView.subviews)
////            {
////                if ([view isKindOfClass:[UISlider class]])
////                {
////                    slider = (UISlider *)view;
////                    break;
////                }
////            }
//            
//
//            CGFloat result = (_touchBeginPoint.y - tempPoint.y) / baseDivisor / 4 + _lastTimeVoiceValue;
//            _lastTimeVoiceValue = result;
//            _systemSlider.value = result < 0 ? 0 : result > 1 ? 1 : result ;
//        }
//            break;
//            
//        default:
//            break;
//    }
//}
//
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    // 只有全屏状态才可以改变音量 / 亮度
//    if (!self.whetherFullScreenBtn.isSelected) { // 非全屏
//        return;
//    }
//    
//    // 0. 开启定时器
////    [self createHiddenToolBarTimer];
//    
//}



@end

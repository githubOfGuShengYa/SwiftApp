//
//  NormalMJRefreshGifHeader.m
//  AFNTest
//
//  Created by 谷胜亚 on 2017/3/6.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

#import "NormalMJRefreshGifHeader.h"

@implementation NormalMJRefreshGifHeader

+ (instancetype)headerWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock
{
    NormalMJRefreshGifHeader *gifHeader = [super headerWithRefreshingBlock:refreshingBlock];
    
//    // 1. 设置不同状态的动画
//    [gifHeader setImages:@[[UIImage imageNamed:@"refresh1"]] forState:MJRefreshStateIdle]; // 普通闲置状态
//    [gifHeader setImages:@[[UIImage imageNamed:@"refresh1"],[UIImage imageNamed:@"refresh2"],[UIImage imageNamed:@"refresh3"]] forState:MJRefreshStatePulling]; // 松开就可以刷新的状态
//    [gifHeader setImages:@[[UIImage imageNamed:@"refresh1"],[UIImage imageNamed:@"refresh2"],[UIImage imageNamed:@"refresh3"]] forState:MJRefreshStateRefreshing]; // 正在刷新状态
    
//    //随机生成文字
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"RefreshTitleList" ofType:@"plist"];
//    NSArray * titleListArray = [NSArray arrayWithContentsOfFile:path];
//    // 随机获取索引
//    NSInteger index = arc4random()%20;
//    
//    [gifHeader setTitle:[titleListArray objectAtIndex:index] forState:MJRefreshStateIdle];
//    [gifHeader setTitle:[titleListArray  objectAtIndex:index] forState:MJRefreshStatePulling];
//    [gifHeader setTitle:[titleListArray  objectAtIndex:index] forState:MJRefreshStateRefreshing];
    
    // 设置字体,设置刷新文字在MJRefreshStateHeader里面了，因为要随机生成文字
    gifHeader.stateLabel.font = [UIFont systemFontOfSize:11];
    gifHeader.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:13];
//    gifHeader.lastUpdatedTimeLabel.hidden = YES; // 隐藏刷新时间显示
    
    // 设置颜色
    gifHeader.stateLabel.textColor = [UIColor blackColor];
    gifHeader.lastUpdatedTimeLabel.textColor = [UIColor blackColor];
    
    gifHeader.backgroundColor = [UIColor clearColor];
    

    
    return gifHeader;
}

@end

//
//  NormalMJRefreshGifHeader.h
//  AFNTest
//
//  Created by 谷胜亚 on 2017/3/6.
//  Copyright © 2017年 谷胜亚. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>

@interface NormalMJRefreshGifHeader : MJRefreshGifHeader

+ (instancetype)headerWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock;

@end

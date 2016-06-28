//
//  InspiretionListViewControllerV.h
//  weddingTime
//
//  Created by 默默 on 15/9/23.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "BaseViewController.h"
#import "PSCollectionView.h"
@interface WTInspiretionListViewController : BaseViewController<PSCollectionViewDelegate,PSCollectionViewDataSource,UIScrollViewDelegate>
@property (strong, nonatomic) PSCollectionView *dataCollectionView;
@property (nonatomic,assign) BOOL         showWithLike;
@property (nonatomic,strong) NSString     *searchTag;
@property (nonatomic,strong) NSDictionary *searchColor;
@property (nonatomic,assign) BOOL         isFromSearch;

//仅供外部搜索调用
- (void)beginSearchWithsearchTag:(NSString *)searchTag;
@end

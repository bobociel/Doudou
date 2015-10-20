//
//  ListingLoadingStatusView.h
//  nihao
//
//  Created by 刘志 on 15/6/2.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LoadingStatus) {
    Loading,
    NetErr,
    Done,
    Empty
};

#define NO_SEARCH_CONTENT CGSizeMake(123,68)
#define NO_CONTACT CGSizeMake(75,75)
#define NO_SHOP CGSizeMake(81,76)
#define NO_DYNAMIC CGSizeMake(105,97)
#define NO_LIKE CGSizeMake(83,78)
#define NO_ANSWER CGSizeMake(85,73)
#define NO_COMMENT CGSizeMake(109,75)
#define NO_MESSAGE CGSizeMake(84,75)

@interface ListingLoadingStatusView : UIView

/**
 *  根据列表当前的状态显示不同的内容
 *
 *  @param status
 */
- (void) showWithStatus : (LoadingStatus) status;

@property (nonatomic,copy) void (^refresh)(void);

/**
 *  设置内容为空的图片和文字提示
 *
 *  @param imageName    图片名字
 *  @param emptyContent 文字提示
 */
- (void) setEmptyImage : (NSString *) imageName emptyContent : (NSString *) emptyContent imageSize : (CGSize) imageSize;

@end

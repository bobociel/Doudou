//
//  WTDetailCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTSupplier.h"
#import "WTWeddingCard.h"
#define youku @"http://player.youku.com/embed/"
@interface WTImageDetailCell : UITableViewCell <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *TopView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UIView *videoBG;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (nonatomic,strong) WTPostImage   *postImage;
@property (nonatomic,strong) WTWeddingCardImage *cardImage;
@property (nonatomic,strong) NSDictionary   *hotelInfo;
- (void)setCellWithPostImage:(WTPostImage *)postImage andVideoPath:(NSString *)path;
+ (CGFloat)cellHeight:(NSObject *)object;
@end

@interface UITableView (WTImageDetailCell)
- (WTImageDetailCell *)WTImageDetailCell;
@end
//
//  WTImageCell.h
//  weddingTime
//
//  Created by wangxiaobo on 15/12/11.
//  Copyright © 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTImageCell;
@protocol WTImageCellDelegate <NSObject>
- (void)WTImageCell:(WTImageCell *)cell didClickWithAsset:(ALAsset *)asset;
@end

@interface WTImageCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *markImageView;
@property (weak, nonatomic) IBOutlet UIButton	 *selectButton;
@property (weak, nonatomic) IBOutlet UILabel     *timeLabel;
@property (weak, nonatomic) IBOutlet UIView      *dimingView;
@property (weak, nonatomic) IBOutlet UIView      *iconVideoView;
@property (weak, nonatomic) IBOutlet UIView      *timeView;
@property (nonatomic, assign) id<WTImageCellDelegate> delegate;
@property (nonatomic, strong) ALAsset *asset;
@end

//
//  WTWeddingCardCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/12.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "PSCollectionViewCell.h"
#import "PSCollectionView.h"
#import "WTWeddingCard.h"
@class WTWeddingCardCell;
@protocol WTWeddingCardCellDelegate <NSObject>
- (void)cardCell:(WTWeddingCardCell *)cell didClick:(UIControl *)control;
@end

@interface WTWeddingCardCell : PSCollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cardImageView;
@property (weak, nonatomic) IBOutlet UILabel *cardName;
@property (weak, nonatomic) IBOutlet UILabel *cardPrice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardViewHeight;
@property (nonatomic, assign)id <WTWeddingCardCellDelegate>delegate;
@property (nonatomic,strong) WTWeddingCard *card;
+ (CGFloat)cellHeightWithCard:(WTWeddingCard *)card;
@end

@interface PSCollectionView (WTWeddingCardCell)
- (WTWeddingCardCell *)WTWeddingCardCell;
@end

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
@interface WTWeddingCardCell : PSCollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cardImageView;
@property (weak, nonatomic) IBOutlet UILabel *cardName;
@property (weak, nonatomic) IBOutlet UILabel *cardPrice;
@property (nonatomic,strong) WTWeddingCard *card;
@end

@interface PSCollectionView (WTWeddingCardCell)
- (WTWeddingCardCell *)WTWeddingCardCell;
@end

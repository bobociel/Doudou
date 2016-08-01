//
//  InspirationViewCell.h
//  weddingTime
//
//  Created by 默默 on 15/9/23.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCollectionViewCell.h"
#import "PSCollectionView.h"
@protocol InspirationViewCellDelegate <NSObject>
- (void)doFav:(int)listid :(UIButton*)btn;
-(void)setBtn:(int)listid :(UIButton *)btn;
@end

@interface InspirationViewCell : PSCollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UIButton *doFav;
@property(nonatomic,weak)id<InspirationViewCellDelegate>delegate;
@property (weak, nonatomic) id infos;
-(void)setInfo:(id)info;
@end

@interface PSCollectionView(InspirationViewCell)
- (InspirationViewCell *) InspirationViewCell;
@end
//
//  WeddingHomePageMusicCell.h
//  lovewith
//
//  Created by imqiuhang on 15/5/13.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "CommTableViewCell.h"
#import "UUAVAudioPlayer.h"
@protocol WeddingHomePageMusicCellDelegate <NSObject>

- (void)didChooseMusicWithIndex:(int)index;
- (void)cancelChooseMusic;

@end

@interface WeddingHomePageMusicCell : CommTableViewCell

@property (nonatomic,weak)id<WeddingHomePageMusicCellDelegate>delegate;
@property int index;
@property (weak, nonatomic) IBOutlet UILabel *musicNamelable;
@property (weak, nonatomic) IBOutlet UIImageView *selectimage;
@property (weak, nonatomic) IBOutlet UIImageView *lineView;
- (void)setInfo:(id)info withSelectedId:(NSInteger)selectedId;
@property (weak, nonatomic) IBOutlet UIImageView *selectedLine;
@end


@interface UITableView(WeddingHomePageMusicCell)

- (WeddingHomePageMusicCell *) WeddingHomePageMusicCell;

@end
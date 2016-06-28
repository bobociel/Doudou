//
//  WeddingHomePageMusicCell.h
//  lovewith
//
//  Created by imqiuhang on 15/5/13.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "UUAVAudioPlayer.h"
#import "WTWeddingTheme.h"
@interface WeddingHomePageMusicCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *musicNamelable;
@property (weak, nonatomic) IBOutlet UIImageView *selectimage;
@property (weak, nonatomic) IBOutlet UIImageView *lineView;
- (void)setInfo:(WTWeddingTheme *)theme withSelectedId:(NSString *)selectedId;
@end


@interface UITableView(WeddingHomePageMusicCell)

- (WeddingHomePageMusicCell *) WeddingHomePageMusicCell;

@end
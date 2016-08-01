//
//  WeddingHomePageMusicCell.m
//  lovewith
//
//  Created by imqiuhang on 15/5/13.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WeddingHomePageMusicCell.h"

@implementation UITableView(WeddingHomePageMusicCell)

- (WeddingHomePageMusicCell *)WeddingHomePageMusicCell{
    
    static NSString *CellIdentifier = @"WeddingHomePageMusicCell";
    
    WeddingHomePageMusicCell * cell = (WeddingHomePageMusicCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        
        UINib *nib = [UINib nibWithNibName:CellIdentifier bundle:nil];
        [self registerNib:nib forCellReuseIdentifier:CellIdentifier];
        cell = (WeddingHomePageMusicCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    return cell;
}
@end

@implementation WeddingHomePageMusicCell
- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.selectimage.hidden = YES;
    self.musicNamelable.textColor = subTitleLableColor;

    [LWAssistUtil imageViewSetAsLineView:self.lineView color:rgba(221, 221, 221, 1)];
}

- (void)setInfo:(WTWeddingTheme *)theme withSelectedId:(NSString *)selectedId
{
    self.musicNamelable.text = [LWUtil getString:theme.name andDefaultStr:@"音乐"];
	self.selectimage.hidden = ![selectedId isEqualToString:theme.ID];
	self.musicNamelable.textColor = [selectedId isEqualToString:theme.ID] ? [WeddingTimeAppInfoManager instance].baseColor : subTitleLableColor ;
}

@end

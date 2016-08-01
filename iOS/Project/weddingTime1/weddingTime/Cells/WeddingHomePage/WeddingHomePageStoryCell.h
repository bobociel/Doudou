//
//  WeddingHomePageStoryCell.h
//  lovewith
//
//  Created by imqiuhang on 15/5/14.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "CommTableViewCell.h"
#import "WTWeddingStory.h"
@class WeddingHomePageStoryCell;
@protocol WeddingHomePageStoryCellDelegate <NSObject>
- (void)WeddingHomePageStringDidBeignEdit:(WeddingHomePageStoryCell *)cell;
- (void)WeddingHomePageStringDidEndEdit:(WeddingHomePageStoryCell *)cell;
@end

@interface WeddingHomePageStoryCell : CommTableViewCell <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView   *headImage;
@property (weak, nonatomic) IBOutlet UIImageView   *lineView;
@property (weak, nonatomic) IBOutlet UITextView		*textView;
@property (nonatomic, assign) id <WeddingHomePageStoryCellDelegate> delegate;
@property (nonatomic, strong) WTWeddingStory *stroy;
@end

@interface UITableView(WeddingHomePageStoryCell)

- (WeddingHomePageStoryCell *) WeddingHomePageStoryCell;

@end
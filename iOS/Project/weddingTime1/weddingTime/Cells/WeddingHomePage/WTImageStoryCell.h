//
//  WeddingHomePageStoryCell.h
//  lovewith
//
//  Created by imqiuhang on 15/5/14.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "CommTableViewCell.h"
#import "WTWeddingStory.h"
@class WTImageStoryCell;
@protocol WeddingHomePageStoryCellDelegate <NSObject>
- (void)WeddingHomePageStringDidBeignEdit:(WTImageStoryCell *)cell;
- (void)WeddingHomePageStringDidEndEdit:(WTImageStoryCell *)cell;
- (void)WTImageStoryCell:(WTImageStoryCell *)cell didSelectedDelete:(UIControl *)sender;
@end

@interface WTImageStoryCell : CommTableViewCell <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView   *headImage;
@property (weak, nonatomic) IBOutlet UIImageView   *lineView;
@property (weak, nonatomic) IBOutlet UITextView		*textView;
@property (weak, nonatomic) IBOutlet UIControl *deleteControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewRight;
@property (nonatomic, assign) id <WeddingHomePageStoryCellDelegate> delegate;
@property (nonatomic, strong) WTWeddingStory *stroy;
@property (nonatomic,assign) BOOL isEdit;
@end

@interface UITableView(WeddingHomePageStoryCell)

- (WTImageStoryCell *) WeddingHomePageStoryCell;

@end
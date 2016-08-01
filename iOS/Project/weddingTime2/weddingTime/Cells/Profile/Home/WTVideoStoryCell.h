//
//  WTWebViewCell.h
//  weddingTime
//
//  Created by wangxiaobo on 15/12/11.
//  Copyright © 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTWeddingStory.h"
@class WTVideoStoryCell;
@protocol WTWebViewCellDelegate <NSObject>
-(void)WTVideoStoryCellDidSelected:(WTVideoStoryCell *)cell andVideoURL:(NSURL *)videoURL;
@end

@interface WTVideoStoryCell : UITableViewCell <UIWebViewDelegate>
@property (nonatomic, strong) WTWeddingStory *story;
@property (nonatomic, assign) id <WTWebViewCellDelegate> delegate;
+ (WTVideoStoryCell *)webCellWithTableView:(UITableView *)tableView;
@end

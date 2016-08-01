//
//  WTWebViewCell.h
//  weddingTime
//
//  Created by wangxiaobo on 15/12/11.
//  Copyright © 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTWeddingStory.h"
@class WTWebViewCell;
@protocol WTWebViewCellDelegate <NSObject>
-(void)WTWebCellDidSelected:(WTWebViewCell *)cell andVideoURL:(NSURL *)videoURL;

@end

@interface WTWebViewCell : UITableViewCell <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *videoImage;
@property (nonatomic, strong) WTWeddingStory *story;
@property (nonatomic, assign) id <WTWebViewCellDelegate> delegate;
+ (WTWebViewCell *)webCellWithTableView:(UITableView *)tableView;
@end

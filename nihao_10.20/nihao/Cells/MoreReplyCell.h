//
//  MoreReplyCell.h
//  nihao
//
//  Created by HelloWorld on 8/10/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Comment;

@protocol MoreReplyCellDelegate <NSObject>

- (void)showMoreReplyFromIndexPath:(NSIndexPath *)indexPath;

@end

@interface MoreReplyCell : UITableViewCell

@property (nonatomic, assign) id <MoreReplyCellDelegate> delegate;

- (void)configureCellWithAnswer:(Comment *)answer forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

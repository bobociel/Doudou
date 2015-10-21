//
//  AnswerReplyCell.h
//  nihao
//
//  Created by HelloWorld on 8/10/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Comment;

@protocol AnswerReplyCellDelegate <NSObject>

- (void)deleteReplyAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface AnswerReplyCell : UITableViewCell

- (void)configureCellWithReply:(Comment *)reply forRowAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, assign) id <AnswerReplyCellDelegate> delegate;

@end

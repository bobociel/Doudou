//
//  PostCommentCell.h
//  nihao
//
//  Created by HelloWorld on 6/23/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Comment;

@interface PostCommentCell : UITableViewCell

- (void)configureCellWithInfo:(Comment *)comment forRowAtIndexPath:(NSIndexPath *)indexPath;

// 点击删除按钮Block
@property (nonatomic,copy) void(^deleteComment)(NSIndexPath *indexPath);
@property (nonatomic,copy) void(^clickUserIcon)(NSIndexPath *indexPath);

@end

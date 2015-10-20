//
//  AskAnswerCell.h
//  nihao
//
//  Created by HelloWorld on 7/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Comment;

@protocol AskAnswerCellDelegate <NSObject>

- (void)showAnswerOperationsWithCurrentCellIndexPath:(NSIndexPath *)indexPath;
- (void)clickedDeleteBtnForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)clickedUserIconAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface AskAnswerCell : UITableViewCell

@property (nonatomic, assign) id<AskAnswerCellDelegate> delegate;

- (void)configureCellWithAnswer:(Comment *)answer questionUserID:(NSString *)userID forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

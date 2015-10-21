//
//  MCommentCell.h
//  nihao
//
//  Created by HelloWorld on 8/13/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MerchantComment;

typedef NS_ENUM(NSUInteger, MCommentContentType) {
	MCommentContentTypeSummary = 0,
	MCommentContentTypeDetail,
};

@interface MCommentCell : UITableViewCell

- (void)configureCellWithMerchantComment:(MerchantComment *)comment commentContentType:(NSInteger)commentContentType;

// 点击用户头像
@property (nonatomic, copy) void(^clickedUserIcon)(MerchantComment *comment);

@end

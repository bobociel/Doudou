//
//  UserInfoDynamicTableViewCell.h
//  nihao
//
//  Created by 刘志 on 15/8/25.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
@class UserPost;

@protocol PostPhotoBrowerClickDelegate <NSObject>

- (void) postPhotoClickAtIndex : (NSUInteger) photoIndex cellIndexPath : (NSIndexPath *) indexPath;

@end

@interface UserInfoDynamicTableViewCell : UITableViewCell

- (void) configureUserInfoDynamic : (UserPost *) post indexPath : (NSIndexPath *) indexPath;

@property (nonatomic,weak) id<PostPhotoBrowerClickDelegate> delegate;

@end

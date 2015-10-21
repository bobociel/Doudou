//
//  TopUserCell.h
//  nihao
//
//  Created by HelloWorld on 6/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TopUser;

@interface TopUserCell : UICollectionViewCell

@property (nonatomic, copy) void(^followUserForRowAtIndexPath)(NSIndexPath *indexPath, BOOL isFollow);

- (void)configureCellWithUserInfo:(TopUser *)user forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

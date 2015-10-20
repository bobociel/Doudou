//
//  AddFriendsViewController.h
//  nihao
//
//  Created by YW on 15/7/2.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "BaseViewController.h"

@protocol AddDelegate <NSObject>


@end

@interface AddFriendsViewController : BaseViewController

@property (nonatomic, weak) id<AddDelegate> delegate;

@end

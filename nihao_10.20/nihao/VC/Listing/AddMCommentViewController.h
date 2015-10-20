//
//  AddMCommentViewController.h
//  nihao
//
//  Created by HelloWorld on 8/17/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseViewController.h"

@interface AddMCommentViewController : BaseViewController

//@property (nonatomic, copy) NSString *merchantName;
@property (nonatomic, copy) NSString *merchantID;

@property (nonatomic, copy) void(^submitReviewSuccess)();

@end

//
//  AskDetailViewController.h
//  nihao
//
//  Created by HelloWorld on 7/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseViewController.h"
@class AskContent;

@interface AskDetailViewController : BaseViewController

@property (nonatomic, strong) AskContent *askContent;
@property (nonatomic, copy) NSString *questionID;

@property (nonatomic, copy) void(^deletedAsk)();

@end

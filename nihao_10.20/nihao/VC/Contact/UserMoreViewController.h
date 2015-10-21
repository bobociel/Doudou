//
//  UserMoreViewController.h
//  nihao
//
//  Created by 吴梦婷 on 15/9/23.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlackListView.h"
#import "RemarksView.h"
#import "NihaoContact.h"

@interface UserMoreViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,RemarksBtnDelegate,BlackListBtnDelegate>

@property (nonatomic, strong) NihaoContact *contact;
@property (nonatomic, assign) NSInteger uid;
@end
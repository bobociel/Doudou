//
//  LikeChildViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/19.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef enum {
    firstLoad    = 0,
    reLoad,
}loadType;



@interface WTLikeChildViewController : BaseViewController

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger row;

@end

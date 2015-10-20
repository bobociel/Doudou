//
//  NotificationCenterViewController.m
//  nihao
//
//  Created by 刘志 on 15/8/14.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "NotificationCenterViewController.h"
#import "NotificationCenterTableViewCell.h"
#import "CustomBadge.h"
#import "LikeNotificationsController.h"
#import "CommentsNotificationsViewController.h"
#import "ChargeFailViewController.h"
#import "AsksNotificationsViewController.h"

@interface NotificationCenterViewController ()<UITableViewDelegate,UITableViewDataSource,MessageReadDelegate> {
    NSArray *_titleArray;
    NSArray *_imgArray;
    UITableView *_table;
    NSMutableArray *_unreadNumArray;
}

@end

@implementation NotificationCenterViewController

static NSString *const IDENTIFIER = @"notificationCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Notifications";
    [self dontShowBackButtonTitle];
    [self initViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void) initViews {
    _titleArray = @[@"Like",@"Comment",@"Answer"];
    NSArray *numsArray = @[[NSNumber numberWithInteger:_unreadLikeNum],[NSNumber numberWithInteger:_unreadCommentNum],[NSNumber numberWithInteger:_unreadAnswerNum]];
    _unreadNumArray = [NSMutableArray arrayWithArray:numsArray];
    _imgArray = @[@"icon_notification_like",@"icon_notification_comment",@"icon_notification_ask"];
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180) style:UITableViewStylePlain];
    [_table registerNib:[UINib nibWithNibName:@"NotificationCenterTableViewCell" bundle:nil] forCellReuseIdentifier:IDENTIFIER];
    _table.delegate = self;
    _table.dataSource = self;
    _table.rowHeight = 60.0f;
    _table.scrollEnabled = NO;
    [self.view addSubview:_table];
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *controller;
    switch (indexPath.row) {
        case 0:{
            controller = [[LikeNotificationsController alloc] init];
            ((LikeNotificationsController *) controller).delegate = self;
        }
            break;
        case 1: {
            controller = [[CommentsNotificationsViewController alloc] init];
            ((CommentsNotificationsViewController *) controller).delegate = self;
        }
            break;
        case 2: {
            controller = [[AsksNotificationsViewController alloc] init];
            ((AsksNotificationsViewController *) controller).delegate = self;
        }
            break;
        default:
            break;
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    cell.titleLabel.text = _titleArray[indexPath.row];
    cell.titleImageView.image = ImageNamed(_imgArray[indexPath.row]);
    NSUInteger unreadNum = [_unreadNumArray[indexPath.row] integerValue];
    if(unreadNum > 0) {
        NSString *badgeValue = (unreadNum > 99) ? @"99+" : [NSString stringWithFormat:@"%ld",unreadNum];
        CustomBadge *badge = [CustomBadge customBadgeWithString:badgeValue];
        [cell.badgeView addSubview:badge];
    } else {
        for(UIView *view in cell.badgeView.subviews) {
            [view removeFromSuperview];
        }
    }
    return cell;
}

- (void) messageReaded:(MESSAGE_TYPE)type {
    [_unreadNumArray replaceObjectAtIndex:type withObject:[NSNumber numberWithInteger:0]];
    [_table reloadData];
    
    //判断profile页面的notifications小红点是否消失
    BOOL isClearRedPoint = YES;
    for(NSNumber *number in _unreadNumArray) {
        if(number.integerValue != 0) {
            isClearRedPoint = NO;
            break;
        }
    }
    if(isClearRedPoint && _delegate) {
        [_delegate clearNotificationRedPoint];
    }
}

@end

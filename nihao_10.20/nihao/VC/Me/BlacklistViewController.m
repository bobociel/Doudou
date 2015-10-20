//
//  BlacklistViewController.m
//  nihao
//
//  Created by 吴梦婷 on 15/10/9.
//  Copyright (c) 2015年 boru. All rights reserved.
//

#import "BlacklistViewController.h"
#import "Masonry.h"
#import "ContactCell.h"
#import "NihaoContact.h"
#import "HttpManager.h"
#import "AppConfigure.h"
#import "IChatManagerBuddy.h"
#import "ListingLoadingStatusView.h"

@interface BlacklistViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    /*! 黑名单数组*/
    NSArray *blackList;
    
    UITableView *blackTable;
    
    /*! 用户详情数组*/
    NSMutableArray *blackerInfo;
    
    /*! 列表加载状态*/
    ListingLoadingStatusView *_statusView;
}

@end

@implementation BlacklistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Blacklist";
    blackerInfo = [[NSMutableArray alloc] init];
    _statusView = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    [self dontShowBackButtonTitle];
    [self getBlackList];
    [self initTableView];
    [self.view addSubview:_statusView];
   }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dontShowBackButtonTitle {
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
}
//获取黑名单列表
-(void) getBlackList{
    EMError *error = nil;
    NSArray *blockedList = [[NSArray alloc] init];
    blockedList = [[EaseMob sharedInstance].chatManager fetchBlockedList:&error];
        if (!error) {
            blackList = blockedList;
            if (blockedList) {
                [self initData];
            }else{
                [_statusView showWithStatus:Empty];
                [_statusView setEmptyImage:@"icon_no_dynamic" emptyContent:@"No blacklist" imageSize:NO_CONTACT];
            }
        }else{
            [_statusView showWithStatus:NetErr];
        }
        NSLog(@"blackList == %@",blackList);
}
-(void) initData{
    NSString * usernames = blackList[0] ;
    for (int i=1 ; i<blackList.count ; i++) {
        NSLog(@"%@",blackList[i]);
        usernames = [usernames stringByAppendingString:[NSString stringWithFormat:@",%@",blackList[i]]];
    }
    [self reqUserInfoByUsername:usernames];
}
-(void) initTableView{
    blackTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-70*blackerInfo.count)];
    [footView setBackgroundColor:ColorF4F4F4];
    blackTable.tableFooterView = footView;
    blackTable.dataSource = self;
    blackTable.delegate = self;
    [blackTable registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    [self.view addSubview:blackTable];
}
#pragma mark  - TableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return blackerInfo.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        static NSString *identifier = @"ContactCell";
        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        if(cell == nil)
        {
            cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        [_statusView showWithStatus:Done];
        [cell loadData:blackerInfo[indexPath.row]];
        cell.icon_locate.hidden = YES;
        return cell;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath      //当在Cell上滑动时会调用此函数

{
    return   UITableViewCellEditingStyleDelete;  //返回此值时,Cell会做出响应显示Delete按键,点击Delete后会调用下面的函数,别给传递UITableViewCellEditingStyleDelete参数
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"点击了删除");
        EMError *error = [[EaseMob sharedInstance].chatManager unblockBuddy:blackList[indexPath.row]];
        if (!error) {
            [blackerInfo removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
            NSLog(@"删除成功");
        }
    }];
    deleteRowAction.backgroundColor = ColorWithRGB(255, 95, 95);
    return @[deleteRowAction];
}
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //对选中的Cell根据editingStyle进行操作
}
-(NihaoContact *)changeNil:(NihaoContact *)contact{
    if (contact.city_name_en == nil) {
        contact.city_name_en = @"";
    }
    if (contact.country_name_en == nil) {
        contact.country_name_en = @"";
    }
    return contact;
}
#pragma mark - 网络请求
- (void) reqUserInfoByUsername:(NSString *)username {
    [_statusView showWithStatus:Loading];
    [HttpManager requestUserInfosByUserNames:username success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success");
        if([responseObject[@"code"] integerValue] == 0) {
            NSDictionary *result = responseObject[@"result"];
            NSLog(@"result == %@",result);
            NSArray *items = result[@"items"];
            NSLog(@"items == %@",items);
            for (NSDictionary *item in items) {
                NSLog(@"item == %@",item);
                NihaoContact *contact = [[NihaoContact alloc] init];
                contact.ci_nikename = item[@"ci_nikename"];
                contact.ci_header_img = item[@"ci_header_img"];
                contact.ci_sex = [item[@"ci_sex"] integerValue];
                contact.ci_username = item[@"ci_username"];
                contact.ci_id = [item[@"ci_id"] integerValue];
                contact.ci_type = [item[@"ci_type"]integerValue];
                contact = [self changeNil:contact];
                [blackerInfo addObject:contact];
                NSLog(@"%@",contact);
            }
            [blackTable reloadData];
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"faild");
        [_statusView showWithStatus:NetErr];
    }];
}
@end

//
//  GroupsMessageView.m
//  nihoo
//
//  Created by 刘志 on 15/5/7.
//  Copyright (c) 2015年 nihoo. All rights reserved.
//

#import "GroupsMessageView.h"
#import "SwipeView.h"
#import "GroupChatCell.h"
#import "CustomBadge.h"
#import "AppDelegate.h"
#import "MessageDetailController.h"

#define CURSOR_SELECTED_COLOR [UIColor colorWithRed:74/255.0 green:183/255.0 blue:253/255.0 alpha:1]
#define CURSOR_NORMAL_COLOR [UIColor colorWithRed:120.0 / 255 green:120.0 / 255 blue:120.0 / 255 alpha:1]

@interface GroupsMessageView()<SwipeViewDelegate,SwipeViewDataSource,UITableViewDelegate,UITableViewDataSource> {
    UIView *_cursor;
    UITableView *_cityChatsTable;
    UITableView *_groupsChatsTable;
    NSArray *_cityChatData;
    NSArray *_groupChatData;
    UITableView *_cityTable;
    UITableView *_groupTable;
    
    UILabel *_cityChatsLabel;
    UILabel *_groupChatsLabel;
    SwipeView *_swipeView;
}

@end

@implementation GroupsMessageView

static NSString *identifier = @"GroupChatCellIdentifier";

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.frame = frame;
        [self initCursorView];
        [self initSwipeView];
        [self initTable];
    }
    return self;
}

- (void) initCursorView {
    UIView *cursorContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 41)];
    cursorContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:cursorContainer];
    
    //city chats
    UIControl *cityChatsControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, (CGRectGetWidth(cursorContainer.frame) - 1) / 2, 41)];
    cityChatsControl.backgroundColor = [UIColor whiteColor];
    [cityChatsControl addTarget:self action:@selector(cityChatsClicked) forControlEvents:UIControlEventTouchUpInside];
    _cityChatsLabel = [[UILabel alloc] init];
    _cityChatsLabel.font = FontNeveLightWithSize(16.0);
    _cityChatsLabel.textColor = CURSOR_SELECTED_COLOR;
    _cityChatsLabel.text = @"City Chats";
    [_cityChatsLabel sizeToFit];
    _cityChatsLabel.frame = CGRectMake(CGRectGetWidth(cityChatsControl.frame) / 2 - CGRectGetWidth(_cityChatsLabel.frame) / 2, CGRectGetHeight(cityChatsControl.frame) / 2 - CGRectGetHeight(_cityChatsLabel.frame) / 2, CGRectGetWidth(_cityChatsLabel.frame), CGRectGetHeight(_cityChatsLabel.frame));
    [cityChatsControl addSubview:_cityChatsLabel];
    [cursorContainer addSubview:cityChatsControl];
    
    //my groups
    UIControl *groupChatsControl = [[UIControl alloc] initWithFrame:CGRectMake((CGRectGetWidth(cursorContainer.frame) + 1) / 2, 0, (CGRectGetWidth(cursorContainer.frame) - 1) / 2, 41)];
    groupChatsControl.backgroundColor = [UIColor whiteColor];
    [groupChatsControl addTarget:self action:@selector(groupsClicked) forControlEvents:UIControlEventTouchUpInside];
    _groupChatsLabel = [[UILabel alloc] init];
    _groupChatsLabel.font = FontNeveLightWithSize(16.0);
    _groupChatsLabel.textColor = CURSOR_NORMAL_COLOR;
    _groupChatsLabel.text = @"My Groups";
    [_groupChatsLabel sizeToFit];
    _groupChatsLabel.frame = CGRectMake(CGRectGetWidth(groupChatsControl.frame) / 2 - CGRectGetWidth(_groupChatsLabel.frame) / 2, CGRectGetHeight(groupChatsControl.frame) / 2 - CGRectGetHeight(_groupChatsLabel.frame) / 2, CGRectGetWidth(_groupChatsLabel.frame), CGRectGetHeight(_groupChatsLabel.frame));
    [groupChatsControl addSubview:_groupChatsLabel];
    [cursorContainer addSubview:groupChatsControl];
    
    //底部的线
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(cursorContainer.frame), 0.5)];
    bottomLine.backgroundColor = [UIColor colorWithRed:200.0 / 255 green:199.0 / 255 blue:204.0 / 255 alpha:1];
    [cursorContainer addSubview:bottomLine];
    
    //中间的线
    UIView *middleLine = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 - 0.5, 8, 0.5, CGRectGetHeight(cursorContainer.frame) - 16)];
    middleLine.backgroundColor = [UIColor colorWithRed:200.0 / 255 green:199.0 / 255 blue:204.0 / 255 alpha:1];
    [cursorContainer addSubview:middleLine];
    
    //底部的游标
    _cursor = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(cursorContainer.frame) - 3, self.bounds.size.width / 2, 3)];
    _cursor.backgroundColor = CURSOR_SELECTED_COLOR;
    [cursorContainer addSubview:_cursor];
}

- (void) initSwipeView {
    _swipeView = [[SwipeView alloc] initWithFrame:CGRectMake(0, 41, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - 41)];
    [self addSubview:_swipeView];
    NSArray *tables = [[NSArray alloc] initWithObjects:_cityChatsTable,_groupsChatsTable,nil];
    for(NSInteger i = 0 ; i < tables.count ; i++) {
        UITableView *table = tables[i];
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_swipeView.frame), CGRectGetHeight(_swipeView.frame)) style:UITableViewStylePlain];
        [table registerNib:[UINib nibWithNibName:@"MessageCell" bundle:nil] forCellReuseIdentifier:identifier];
        table.showsVerticalScrollIndicator = NO;
    }
    
    _swipeView.pagingEnabled = YES;
    _swipeView.dataSource = self;
    _swipeView.delegate = self;
}

- (void) initTable {
    _cityChatData = [self readTxt:@"city_chart" key:@"city_chart"];
    _groupChatData = [self readTxt:@"group_chart" key:@"group_chart"];
    
    _groupsChatsTable = [[UITableView alloc] initWithFrame:_swipeView.bounds style:UITableViewStylePlain];
    _cityChatsTable = [[UITableView alloc] initWithFrame:_swipeView.bounds style:UITableViewStylePlain];
    [_groupsChatsTable registerNib:[UINib nibWithNibName:@"GroupChatCell" bundle:nil] forCellReuseIdentifier:identifier];
    [_cityChatsTable registerNib:[UINib nibWithNibName:@"GroupChatCell" bundle:nil] forCellReuseIdentifier:identifier];
    _groupsChatsTable.delegate = self;
    _groupsChatsTable.dataSource = self;
    _groupsChatsTable.tableFooterView = [[UIView alloc] init];
    _cityChatsTable.delegate = self;
    _cityChatsTable.dataSource = self;
    _cityChatsTable.tableFooterView = [[UIView alloc] init];
    
}

- (NSArray *) readTxt : (NSString *) filename key : (NSString *) key {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@".txt"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
    NSArray *array = dic[key];
    return array;
}

- (void) cursorMove : (NSInteger) page{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _cursor.frame;
        frame.origin.x = (page == 0) ? 0 : CGRectGetWidth(_swipeView.frame) / 2;
        _cursor.frame = frame;
    } completion:^(BOOL finished) {
        if(page == 0) {
            [_cityChatsLabel setTextColor:CURSOR_SELECTED_COLOR];
            [_groupChatsLabel setTextColor:CURSOR_NORMAL_COLOR];
        } else {
            [_cityChatsLabel setTextColor:CURSOR_NORMAL_COLOR];
            [_groupChatsLabel setTextColor:CURSOR_SELECTED_COLOR];
        }
    }];
}

#pragma mark - swipeview delegate
- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    [self cursorMove:swipeView.currentPage];
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView {
    return swipeView.bounds.size;
}

#pragma mark - swipeview datasource
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return 2;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    if(index == 0) {
        return _cityChatsTable;
    } else {
        return _groupsChatsTable;
    }
}

- (void)cityChatsClicked {
    if(_swipeView.currentPage == 0) {
        return;
    }
    [_swipeView scrollToPage:0 duration:0.3];
    [self cursorMove : 0];
}

- (void)groupsClicked {
    if(_swipeView.currentPage == 1) {
        return;
    }
    [_swipeView scrollToPage:1 duration:0.3];
    [self cursorMove : 1];
}

#pragma mark - uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    UITabBarController *tabbarController = (UITabBarController *)delegate.window.rootViewController;
    UINavigationController *navigationController = [[tabbarController viewControllers] objectAtIndex:1];
    MessageDetailController *controller = [[MessageDetailController alloc] init];
    [navigationController pushViewController:controller animated:YES];
}

#pragma mark - uitableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == _cityChatsTable) {
        return _cityChatData.count;
    } else {
        return _groupChatData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(tableView == _cityChatsTable) {
        NSDictionary *item = _cityChatData[indexPath.row];
        NSString *title = item[@"title"];
        NSString *logo = item[@"logo"];
        NSString *content = item[@"content"];
        NSString *time = item[@"time"];
        NSString *badge = item[@"badge"];
        BOOL joined = [item[@"joined"] integerValue];
        
        cell.title.text = title;
        cell.logo.image = [UIImage imageNamed:logo];
        if(!joined) {
            cell.content.text = content;
            cell.time.text = time;
            [cell.badge addSubview:[CustomBadge customBadgeWithString:badge]];
            cell.addGroup.hidden = YES;
        } else {
            cell.content.hidden = YES;
            cell.time.hidden = YES;
            cell.badge.hidden = YES;
            //cell.titleTopConstraint.constant = 23;
            //[cell.title sizeToFit];
        }
    } else {
        NSDictionary *item = _groupChatData[indexPath.row];
        NSString *title = item[@"title"];
        NSString *logo = item[@"logo"];
        NSString *content = item[@"content"];
        NSString *time = item[@"time"];
        NSString *badge = item[@"badge"];
        cell.title.text = title;
        cell.logo.image = [UIImage imageNamed:logo];
        cell.content.text = content;
        cell.time.text = time;
        [cell.badge addSubview:[CustomBadge customBadgeWithString:badge]];
        cell.addGroup.hidden = YES;
    }
    return cell;
}


@end

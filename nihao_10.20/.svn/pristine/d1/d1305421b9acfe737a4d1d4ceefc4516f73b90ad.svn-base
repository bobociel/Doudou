
//
//  UserBaseInfoViewController.m
//  nihao
//
//  Created by 刘志 on 15/8/26.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "UserBaseInfoViewController.h"
#import "ProfileCell.h"

@interface UserBaseInfoViewController () <UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    NSArray *_titleArray;
    NSArray *_contentArray;
}

@end

@implementation UserBaseInfoViewController

static NSString *identifier = @"identifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _nickname;
    [self dontShowBackButtonTitle];
    [self initTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) initTableView {
    _titleArray = @[@"Nationality",@"Region",@"Birthday"];
    _contentArray = @[_nationality,_region,_birthday];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44 * _titleArray.count) style:UITableViewStylePlain];
    _tableView.tableHeaderView = [[UIView alloc] init];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    [_tableView registerNib:[UINib nibWithNibName:@"ProfileCell" bundle:nil] forCellReuseIdentifier:identifier];
    [self.view addSubview:_tableView];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.cellDescriptionLabel.text = _titleArray[indexPath.row];
    cell.cellValueLabel.text = _contentArray[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArray.count;
}


@end

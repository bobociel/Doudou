//
//  GenderViewController.m
//  nihao
//
//  Created by 刘志 on 15/9/19.
//  Copyright © 2015年 jiazhong. All rights reserved.
//

#import "GenderViewController.h"

@interface GenderViewController () <UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) UITableView *table;

@end

@implementation GenderViewController

static NSString *const identifier = @"identifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Gender";
    [self dontShowBackButtonTitle];
    
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44 * 3) style:UITableViewStylePlain];
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    _table.delegate = self;
    _table.dataSource = self;
    _table.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_table];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - uitableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.genderChoosed) {
        self.genderChoosed(indexPath.row);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - uitableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(indexPath.row == 0) {
        cell.textLabel.text = @"All";
    } else if(indexPath.row == 1){
        cell.textLabel.text = @"Female";
    } else {
        cell.textLabel.text = @"Male";
    }
    
    cell.textLabel.font = FontNeveLightWithSize(16.0);
    cell.textLabel.textColor = ColorWithRGB(120, 120, 120);
    return cell;
}

@end
